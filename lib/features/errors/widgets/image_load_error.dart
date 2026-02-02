import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 图片加载错误 Widget。
///
/// 当图片加载失败时显示此 Widget。
/// 显示错误图标、错误消息、图片 URL 和重试按钮。
///
/// 使用示例：
/// ```dart
/// ImageLoadError(
///   imageUrl: 'https://example.com/image.png',
///   onRetry: () {
///     // 重新加载图片
///   },
///   width: 300,
///   height: 200,
/// )
/// ```
class ImageLoadError extends StatelessWidget {
  /// 创建一个图片加载错误 Widget。
  const ImageLoadError({
    super.key,
    required this.imageUrl,
    this.onRetry,
    this.width = 200,
    this.height = 150,
  });

  /// 加载失败的图片 URL
  final String imageUrl;

  /// 重试回调
  final VoidCallback? onRetry;

  /// 占位符宽度
  final double width;

  /// 占位符高度
  final double height;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const Key('imageLoadErrorContainer'),
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface,
        borderRadius: BorderRadius.circular(AppColors.cardRadius),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorderPrimary
              : AppColors.lightBorderPrimary,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 错误图标
          Icon(
            Icons.broken_image_outlined,
            key: const Key('brokenImageIcon'),
            size: 32,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          const SizedBox(height: 8),
          // 错误消息
          Text(
            '图片加载失败',
            key: const Key('errorMessage'),
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 4),
          // 图片 URL（截断显示）
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Tooltip(
              message: imageUrl,
              child: Text(
                imageUrl,
                key: const Key('imageUrl'),
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: 'monospace',
                  color: isDark
                      ? AppColors.darkTextTertiary
                      : AppColors.lightTextTertiary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 重试按钮
          TextButton.icon(
            key: const Key('retryButton'),
            onPressed: onRetry,
            icon: Icon(
              Icons.refresh,
              size: 16,
              color: isDark
                  ? AppColors.accentPrimary
                  : AppColors.lightAccentPrimary,
            ),
            label: Text(
              '重试',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.accentPrimary
                    : AppColors.lightAccentPrimary,
              ),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
