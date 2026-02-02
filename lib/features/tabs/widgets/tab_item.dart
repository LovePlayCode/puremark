import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 标签页项 Widget。
///
/// 显示单个标签页，包含文件名和关闭按钮。
/// 支持点击切换和悬停时显示关闭按钮。
///
/// 使用示例：
/// ```dart
/// TabItemWidget(
///   title: 'README.md',
///   isActive: true,
///   onTap: () => print('Tab clicked'),
///   onClose: () => print('Close clicked'),
/// )
/// ```
class TabItemWidget extends StatefulWidget {
  /// 创建一个标签页项 Widget。
  const TabItemWidget({
    super.key,
    required this.title,
    this.isActive = false,
    this.onTap,
    this.onClose,
  });

  /// 标签页标题（文件名）
  final String title;

  /// 是否为活动标签页
  final bool isActive;

  /// 点击标签页回调
  final VoidCallback? onTap;

  /// 关闭标签页回调
  final VoidCallback? onClose;

  @override
  State<TabItemWidget> createState() => _TabItemWidgetState();
}

class _TabItemWidgetState extends State<TabItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 背景色
    final backgroundColor = widget.isActive
        ? (isDark ? AppColors.darkBgPrimary : AppColors.lightBgPrimary)
        : (isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated);

    // 文字颜色
    final textColor = widget.isActive
        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary);

    // 关闭按钮颜色
    final closeButtonColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          key: const Key('tabItemContainer'),
          height: 36,
          constraints: const BoxConstraints(
            minWidth: 100,
            maxWidth: 200,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 文件名
              Flexible(
                child: Text(
                  widget.title,
                  key: const Key('tabItemTitle'),
                  style: TextStyle(
                    fontSize: 13,
                    color: textColor,
                    fontWeight:
                        widget.isActive ? FontWeight.w500 : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 8),
              // 关闭按钮
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _isHovered || widget.isActive ? 1.0 : 0.0,
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    key: const Key('tabItemCloseButton'),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: _isHovered
                          ? (isDark
                              ? AppColors.darkBgSurface
                              : AppColors.lightBgSurface)
                          : Colors.transparent,
                    ),
                    child: Center(
                      child: Text(
                        '×',
                        style: TextStyle(
                          fontSize: 16,
                          color: closeButtonColor,
                          height: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
