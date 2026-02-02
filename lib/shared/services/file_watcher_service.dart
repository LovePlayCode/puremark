import 'dart:async';
import 'dart:io';

import 'package:watcher/watcher.dart';

/// 文件监听事件类型。
enum FileWatchEventType {
  /// 文件内容已修改
  modified,

  /// 文件已删除
  deleted,
}

/// 文件监听事件。
///
/// 包含事件类型、文件路径和时间戳。
class FileWatchEvent {
  /// 创建一个文件监听事件。
  const FileWatchEvent({
    required this.type,
    required this.path,
    required this.timestamp,
  });

  /// 事件类型
  final FileWatchEventType type;

  /// 文件路径
  final String path;

  /// 事件时间戳
  final DateTime timestamp;

  @override
  String toString() {
    return 'FileWatchEvent(type: $type, path: $path, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileWatchEvent &&
        other.type == type &&
        other.path == path &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode => Object.hash(type, path, timestamp);
}

/// 文件监听服务。
///
/// 使用 watcher 包监听单个文件的变化，支持防抖处理。
///
/// 使用示例：
/// ```dart
/// final service = FileWatcherService();
///
/// // 监听文件变化
/// service.events.listen((event) {
///   if (event.type == FileWatchEventType.modified) {
///     print('文件已修改');
///   } else if (event.type == FileWatchEventType.deleted) {
///     print('文件已删除');
///   }
/// });
///
/// // 开始监听
/// await service.startWatching('/path/to/file.md');
///
/// // 停止监听
/// service.stopWatching();
///
/// // 释放资源
/// service.dispose();
/// ```
class FileWatcherService {
  /// 创建一个文件监听服务。
  ///
  /// [debounceDuration] 防抖时间，默认 500 毫秒
  FileWatcherService({
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  /// 防抖时间
  final Duration debounceDuration;

  /// 文件监听器
  FileWatcher? _watcher;

  /// 监听器订阅
  StreamSubscription<WatchEvent>? _watcherSubscription;

  /// 事件流控制器
  final StreamController<FileWatchEvent> _eventController =
      StreamController<FileWatchEvent>.broadcast();

  /// 当前监听的文件路径
  String? _currentPath;

  /// 防抖计时器
  Timer? _debounceTimer;

  /// 最后一个待处理的事件
  WatchEvent? _pendingEvent;

  /// 文件监听事件流。
  Stream<FileWatchEvent> get events => _eventController.stream;

  /// 当前监听的文件路径。
  String? get currentPath => _currentPath;

  /// 是否正在监听。
  bool get isWatching => _watcher != null && _watcherSubscription != null;

  /// 开始监听指定路径的文件。
  ///
  /// [path] 要监听的文件路径
  ///
  /// 如果已经在监听其他文件，会先停止之前的监听。
  Future<void> startWatching(String path) async {
    // 如果已经在监听同一个文件，则不需要重新启动
    if (_currentPath == path && isWatching) {
      return;
    }

    // 停止之前的监听
    stopWatching();

    _currentPath = path;

    // 检查文件是否存在
    final file = File(path);
    if (!await file.exists()) {
      _eventController.add(FileWatchEvent(
        type: FileWatchEventType.deleted,
        path: path,
        timestamp: DateTime.now(),
      ));
      return;
    }

    // 创建文件监听器
    _watcher = FileWatcher(path);

    // 订阅文件变化事件
    _watcherSubscription = _watcher!.events.listen(
      _handleWatchEvent,
      onError: (error) {
        // 监听器错误时，假设文件已被删除
        _eventController.add(FileWatchEvent(
          type: FileWatchEventType.deleted,
          path: path,
          timestamp: DateTime.now(),
        ));
      },
    );
  }

  /// 处理文件监听事件（带防抖）。
  void _handleWatchEvent(WatchEvent event) {
    _pendingEvent = event;

    // 取消之前的计时器
    _debounceTimer?.cancel();

    // 设置新的防抖计时器
    _debounceTimer = Timer(debounceDuration, () {
      if (_pendingEvent != null) {
        _processEvent(_pendingEvent!);
        _pendingEvent = null;
      }
    });
  }

  /// 处理并发送事件。
  void _processEvent(WatchEvent event) {
    final type = switch (event.type) {
      ChangeType.MODIFY => FileWatchEventType.modified,
      ChangeType.REMOVE => FileWatchEventType.deleted,
      // 对于单文件监听，ADD 事件通常不会发生
      // 但如果发生了，我们将其视为修改
      ChangeType.ADD => FileWatchEventType.modified,
      // 处理任何未知的事件类型
      _ => FileWatchEventType.modified,
    };

    _eventController.add(FileWatchEvent(
      type: type,
      path: event.path,
      timestamp: DateTime.now(),
    ));
  }

  /// 停止监听。
  void stopWatching() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _pendingEvent = null;

    _watcherSubscription?.cancel();
    _watcherSubscription = null;

    _watcher = null;
    _currentPath = null;
  }

  /// 释放资源。
  ///
  /// 调用此方法后，服务将不可再使用。
  void dispose() {
    stopWatching();
    _eventController.close();
  }
}
