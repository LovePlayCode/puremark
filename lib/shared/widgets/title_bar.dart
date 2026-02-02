import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// macOS 风格的窗口标题栏组件。
///
/// 包含三个红绿灯按钮（关闭、最小化、全屏），
/// 可选显示文件名（居中）。
///
/// 使用示例：
/// ```dart
/// TitleBar(
///   fileName: 'README.md',
///   onClose: () => print('Close'),
///   onMinimize: () => print('Minimize'),
///   onFullscreen: () => print('Fullscreen'),
/// )
/// ```
class TitleBar extends StatelessWidget {
  /// 创建一个 macOS 风格的标题栏。
  const TitleBar({
    super.key,
    this.fileName,
    this.onClose,
    this.onMinimize,
    this.onFullscreen,
    this.onDragStart,
    this.onDragUpdate,
  });

  /// 可选的文件名，居中显示
  final String? fileName;

  /// 点击关闭按钮的回调
  final VoidCallback? onClose;

  /// 点击最小化按钮的回调
  final VoidCallback? onMinimize;

  /// 点击全屏按钮的回调
  final VoidCallback? onFullscreen;

  /// 拖拽开始回调
  final GestureDragStartCallback? onDragStart;

  /// 拖拽更新回调
  final GestureDragUpdateCallback? onDragUpdate;

  /// 标题栏高度
  static const double height = 40.0;

  /// 红绿灯按钮大小
  static const double buttonSize = 12.0;

  /// 按钮间距
  static const double buttonSpacing = 8.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('title_bar_drag_area'),
      onPanStart: onDragStart,
      onPanUpdate: onDragUpdate,
      child: Container(
        key: const Key('title_bar_container'),
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.darkBgPrimary
              : AppColors.lightBgPrimary,
        ),
        child: Stack(
          children: [
            // 红绿灯按钮
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Row(
                key: const Key('traffic_light_buttons'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TrafficLightButton(
                    key: const Key('close_button'),
                    color: AppColors.trafficRed,
                    onTap: onClose,
                  ),
                  const SizedBox(width: buttonSpacing),
                  _TrafficLightButton(
                    key: const Key('minimize_button'),
                    color: AppColors.trafficYellow,
                    onTap: onMinimize,
                  ),
                  const SizedBox(width: buttonSpacing),
                  _TrafficLightButton(
                    key: const Key('fullscreen_button'),
                    color: AppColors.trafficGreen,
                    onTap: onFullscreen,
                  ),
                ],
              ),
            ),
            // 文件名（居中）
            if (fileName != null)
              Center(
                child: Text(
                  fileName!,
                  key: const Key('title_bar_file_name'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 红绿灯按钮组件。
class _TrafficLightButton extends StatelessWidget {
  const _TrafficLightButton({
    super.key,
    required this.color,
    this.onTap,
  });

  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: TitleBar.buttonSize,
        height: TitleBar.buttonSize,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
