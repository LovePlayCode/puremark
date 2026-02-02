import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 文件已删除错误 Widget。
///
/// 当文件被删除或移动时显示此 Widget。
/// 显示错误图标、错误消息、文件路径和两个操作按钮。
///
/// 使用示例：
/// ```dart
/// FileDeletedError(
///   filePath: '/path/to/deleted/file.md',
///   onCloseTab: () {
///     // 关闭当前标签页
///   },
///   onOpenFile: () {
///     // 打开文件选择器
///   },
/// )
/// ```
class FileDeletedError extends StatelessWidget {
  /// 创建一个文件已删除错误 Widget。
  const FileDeletedError({
    super.key,
    required this.filePath,
    this.onCloseTab,
    this.onOpenFile,
  });

  /// 被删除的文件路径
  final String filePath;

  /// 关闭标签回调
  final VoidCallback? onCloseTab;

  /// 打开其他文件回调
  final VoidCallback? onOpenFile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        key: const Key('fileDeletedErrorContainer'),
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 错误图标
            Container(
              key: const Key('errorIconContainer'),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBgSurface
                    : AppColors.lightBgSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                key: const Key('errorIcon'),
                size: 40,
                color: AppColors.trafficRed,
              ),
            ),
            const SizedBox(height: 24),
            // 错误消息
            Text(
              '文件已被删除或移动',
              key: const Key('errorMessage'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            // 文件路径
            Container(
              key: const Key('filePathContainer'),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBgSurface
                    : AppColors.lightBgSurface,
                borderRadius: BorderRadius.circular(AppColors.buttonRadius),
              ),
              child: Text(
                filePath,
                key: const Key('filePath'),
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 32),
            // 操作按钮
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 关闭标签按钮
                OutlinedButton(
                  key: const Key('closeTabButton'),
                  onPressed: onCloseTab,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.lightTextPrimary,
                    side: BorderSide(
                      color: isDark
                          ? AppColors.darkBorderPrimary
                          : AppColors.lightBorderPrimary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppColors.buttonRadius),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('关闭标签'),
                ),
                const SizedBox(width: 12),
                // 打开其他文件按钮
                FilledButton(
                  key: const Key('openFileButton'),
                  onPressed: onOpenFile,
                  style: FilledButton.styleFrom(
                    backgroundColor: isDark
                        ? AppColors.accentPrimary
                        : AppColors.lightAccentPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppColors.buttonRadius),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text('打开其他文件'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
