import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/file_state.dart';

/// 文件状态 Provider。
///
/// 使用 AsyncNotifierProvider 管理文件的打开、加载和关闭状态。
///
/// 使用示例：
/// ```dart
/// // 读取当前文件状态
/// final fileState = ref.watch(fileProvider);
///
/// // 打开文件
/// await ref.read(fileProvider.notifier).openFile('/path/to/file.md');
///
/// // 关闭文件
/// ref.read(fileProvider.notifier).closeFile();
/// ```
final fileProvider = AsyncNotifierProvider<FileNotifier, FileState>(() {
  return FileNotifier();
});

/// 文件状态 Notifier。
///
/// 管理文件的打开、内容更新和关闭操作。
class FileNotifier extends AsyncNotifier<FileState> {
  @override
  Future<FileState> build() async {
    return FileState.empty();
  }

  /// 打开指定路径的文件。
  ///
  /// [path] 文件路径
  ///
  /// 打开过程：
  /// 1. 设置状态为 loading
  /// 2. 读取文件内容
  /// 3. 设置状态为 loaded 或 error
  /// 骨架屏最少展示时间（毫秒），避免加载过快时用户看不到骨架屏。
  static const int _minLoadingDisplayMs = 400;

  Future<void> openFile(String path) async {
    // 设置加载状态（此时 UI 会显示骨架屏）
    state = AsyncValue.data(FileState.loading(path));

    try {
      // 确保骨架屏至少展示一段时间，便于用户看到加载反馈
      await Future.delayed(
        const Duration(milliseconds: _minLoadingDisplayMs),
      );

      final file = File(path);

      // 检查文件是否存在
      if (!await file.exists()) {
        state = AsyncValue.data(
          FileState.error(
            filePath: path,
            errorMessage: '文件不存在: $path',
          ),
        );
        return;
      }

      // 读取文件内容
      final content = await file.readAsString();

      // 设置加载完成状态
      state = AsyncValue.data(
        FileState.loaded(
          filePath: path,
          content: content,
        ),
      );
    } catch (e) {
      // 设置错误状态
      state = AsyncValue.data(
        FileState.error(
          filePath: path,
          errorMessage: '读取文件失败: $e',
        ),
      );
    }
  }

  /// 更新文件内容。
  ///
  /// [content] 新的文件内容
  ///
  /// 仅当文件处于 loaded 状态时有效。
  void setContent(String content) {
    final currentState = state.valueOrNull;
    if (currentState == null || currentState.status != FileStatus.loaded) {
      return;
    }

    state = AsyncValue.data(
      currentState.copyWith(content: content),
    );
  }

  /// 关闭当前文件。
  ///
  /// 将状态重置为 empty。
  void closeFile() {
    state = AsyncValue.data(FileState.empty());
  }
}
