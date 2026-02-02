import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/file_watcher_service.dart';
import 'file_provider.dart';

/// 文件监听状态。
///
/// 包含监听状态、当前路径和最后事件信息。
class FileWatcherState {
  /// 创建一个文件监听状态。
  const FileWatcherState({
    this.isWatching = false,
    this.currentPath,
    this.lastEvent,
  });

  /// 是否正在监听
  final bool isWatching;

  /// 当前监听的文件路径
  final String? currentPath;

  /// 最后一个文件事件
  final FileWatchEvent? lastEvent;

  /// 创建状态的副本。
  FileWatcherState copyWith({
    bool? isWatching,
    String? currentPath,
    FileWatchEvent? lastEvent,
  }) {
    return FileWatcherState(
      isWatching: isWatching ?? this.isWatching,
      currentPath: currentPath ?? this.currentPath,
      lastEvent: lastEvent ?? this.lastEvent,
    );
  }

  @override
  String toString() {
    return 'FileWatcherState(isWatching: $isWatching, currentPath: $currentPath, lastEvent: $lastEvent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FileWatcherState &&
        other.isWatching == isWatching &&
        other.currentPath == currentPath &&
        other.lastEvent == lastEvent;
  }

  @override
  int get hashCode => Object.hash(isWatching, currentPath, lastEvent);
}

/// 文件监听服务 Provider。
///
/// 提供全局的文件监听服务实例。
final fileWatcherServiceProvider = Provider<FileWatcherService>((ref) {
  final service = FileWatcherService();
  ref.onDispose(() {
    service.dispose();
  });
  return service;
});

/// 文件监听状态 Provider。
///
/// 使用 StateNotifierProvider 管理文件监听状态，
/// 并与 FileProvider 配合使用，在文件变化时自动刷新内容。
///
/// 使用示例：
/// ```dart
/// // 读取当前监听状态
/// final watcherState = ref.watch(fileWatcherProvider);
///
/// // 开始监听文件
/// await ref.read(fileWatcherProvider.notifier).startWatching('/path/to/file.md');
///
/// // 停止监听
/// ref.read(fileWatcherProvider.notifier).stopWatching();
/// ```
final fileWatcherProvider =
    StateNotifierProvider<FileWatcherNotifier, FileWatcherState>((ref) {
  return FileWatcherNotifier(ref);
});

/// 文件监听状态 Notifier。
///
/// 管理文件监听的开始、停止操作，并响应文件变化事件。
class FileWatcherNotifier extends StateNotifier<FileWatcherState> {
  /// 创建一个文件监听状态 Notifier。
  FileWatcherNotifier(this._ref) : super(const FileWatcherState()) {
    _service = _ref.read(fileWatcherServiceProvider);
    _setupEventListener();
  }

  final Ref _ref;
  late final FileWatcherService _service;
  StreamSubscription<FileWatchEvent>? _eventSubscription;

  /// 设置事件监听器。
  void _setupEventListener() {
    _eventSubscription = _service.events.listen(_handleFileEvent);
  }

  /// 处理文件事件。
  void _handleFileEvent(FileWatchEvent event) {
    state = state.copyWith(lastEvent: event);

    // 根据事件类型处理
    switch (event.type) {
      case FileWatchEventType.modified:
        // 文件被修改，重新加载内容
        _refreshFileContent(event.path);
      case FileWatchEventType.deleted:
        // 文件被删除，通知上层处理
        // 状态已更新，上层可以通过 lastEvent 获取删除事件
        break;
    }
  }

  /// 刷新文件内容。
  Future<void> _refreshFileContent(String path) async {
    final fileNotifier = _ref.read(fileProvider.notifier);
    await fileNotifier.openFile(path);
  }

  /// 开始监听指定路径的文件。
  ///
  /// [path] 要监听的文件路径
  Future<void> startWatching(String path) async {
    await _service.startWatching(path);
    state = FileWatcherState(
      isWatching: true,
      currentPath: path,
    );
  }

  /// 停止监听。
  void stopWatching() {
    _service.stopWatching();
    state = const FileWatcherState();
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
