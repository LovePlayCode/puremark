import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// 专注模式屏幕 Widget。
///
/// 全屏显示内容，顶部有阅读进度条，底部有退出提示。
///
/// 使用示例：
/// ```dart
/// FocusScreen(
///   readingProgress: 0.5,
///   onExit: () => exitFocusMode(),
///   onProgressChanged: (progress) => updateProgress(progress),
///   child: MarkdownContent(),
/// )
/// ```
class FocusScreen extends StatelessWidget {
  /// 创建一个专注模式屏幕。
  const FocusScreen({
    super.key,
    required this.child,
    this.readingProgress = 0.0,
    this.onExit,
    this.onProgressChanged,
  });

  /// 要显示的内容
  final Widget child;

  /// 阅读进度（0.0-1.0）
  final double readingProgress;

  /// 退出回调
  final VoidCallback? onExit;

  /// 进度变化回调
  final void Function(double progress)? onProgressChanged;

  /// 内容最大宽度
  static const double maxContentWidth = 800;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // 颜色定义
    final backgroundColor =
        isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary;
    final progressBgColor =
        isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated;
    final progressColor = AppColors.accentPrimary;
    final hintTextColor =
        isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary;

    return KeyboardListener(
      focusNode: FocusNode()..requestFocus(),
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.escape) {
          onExit?.call();
        }
      },
      child: Scaffold(
        key: const Key('focusScreen'),
        backgroundColor: backgroundColor,
        body: Column(
          children: [
            // 阅读进度条
            _buildProgressBar(
              progressBgColor: progressBgColor,
              progressColor: progressColor,
            ),
            // 主内容区域
            Expanded(
              child: _buildContent(),
            ),
            // 退出提示
            _buildExitHint(hintTextColor: hintTextColor),
          ],
        ),
      ),
    );
  }

  /// 构建阅读进度条。
  Widget _buildProgressBar({
    required Color progressBgColor,
    required Color progressColor,
  }) {
    return Container(
      key: const Key('progressBar'),
      height: 3,
      width: double.infinity,
      color: progressBgColor,
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: readingProgress.clamp(0.0, 1.0),
        child: Container(
          key: const Key('progressIndicator'),
          color: progressColor,
        ),
      ),
    );
  }

  /// 构建主内容区域。
  Widget _buildContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              final metrics = notification.metrics;
              if (metrics.maxScrollExtent > 0) {
                final progress = metrics.pixels / metrics.maxScrollExtent;
                onProgressChanged?.call(progress.clamp(0.0, 1.0));
              }
            }
            return false;
          },
          child: Padding(
            key: const Key('focusContent'),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: child,
          ),
        ),
      ),
    );
  }

  /// 构建退出提示。
  Widget _buildExitHint({required Color hintTextColor}) {
    return Container(
      key: const Key('exitHint'),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'ESC to exit',
        style: TextStyle(
          color: hintTextColor,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}

/// 专注模式包装器 Widget。
///
/// 提供进入和退出专注模式的动画过渡效果。
///
/// 使用示例：
/// ```dart
/// FocusModeWrapper(
///   isEnabled: isFocusMode,
///   readingProgress: progress,
///   onExit: () => exitFocusMode(),
///   onProgressChanged: (p) => updateProgress(p),
///   normalChild: NormalView(),
///   focusChild: FocusContent(),
/// )
/// ```
class FocusModeWrapper extends StatelessWidget {
  /// 创建一个专注模式包装器。
  const FocusModeWrapper({
    super.key,
    required this.isEnabled,
    required this.normalChild,
    required this.focusChild,
    this.readingProgress = 0.0,
    this.onExit,
    this.onProgressChanged,
  });

  /// 是否启用专注模式
  final bool isEnabled;

  /// 正常模式下显示的内容
  final Widget normalChild;

  /// 专注模式下显示的内容
  final Widget focusChild;

  /// 阅读进度
  final double readingProgress;

  /// 退出回调
  final VoidCallback? onExit;

  /// 进度变化回调
  final void Function(double progress)? onProgressChanged;

  @override
  Widget build(BuildContext context) {
    if (!isEnabled) {
      return normalChild;
    }

    return FocusScreen(
      readingProgress: readingProgress,
      onExit: onExit,
      onProgressChanged: onProgressChanged,
      child: focusChild,
    );
  }
}
