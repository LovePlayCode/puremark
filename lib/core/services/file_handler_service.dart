import 'dart:async';

import 'package:flutter/services.dart';

/// 系统层「打开文件」事件服务（macOS 双击 .md 等）。
///
/// 采用双层缓冲：原生层未就绪时由 Swift 缓存；Dart 层在无订阅者时
/// 将事件存入 [_pendingFiles]，订阅者注册时先处理待处理文件再监听 Stream。
class FileHandlerService {
  FileHandlerService._();

  static const MethodChannel _channel = MethodChannel('com.puremark/openFile');
  static final StreamController<String> _fileOpenController =
      StreamController<String>.broadcast();

  static final List<String> _pendingFiles = [];
  static bool _hasSubscribers = false;
  static bool _initialized = false;

  /// 初始化并设置 MethodChannel 回调，应在应用启动时调用一次。
  static void initialize() {
    if (_initialized) return;
    _initialized = true;
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  /// 订阅「打开文件」事件。若在订阅前已有事件到达，会先通过 [onData] 处理这些待处理文件。
  static StreamSubscription<String> subscribe(void Function(String path) onData) {
    _hasSubscribers = true;

    if (_pendingFiles.isNotEmpty) {
      Future.microtask(() {
        for (final path in _pendingFiles) {
          onData(path);
        }
        _pendingFiles.clear();
      });
    }

    return _fileOpenController.stream.listen(onData);
  }

  static Future<dynamic> _handleMethodCall(MethodCall call) async {
    if (call.method == 'openFile') {
      String path = call.arguments as String? ?? '';

      if (path.startsWith('file://')) {
        path = Uri.decodeComponent(path.substring(7));
      }
      path = path.trim();
      if (path.isEmpty) return null;

      if (!_hasSubscribers) {
        _pendingFiles.add(path);
      } else {
        _fileOpenController.add(path);
      }
    }
    return null;
  }
}
