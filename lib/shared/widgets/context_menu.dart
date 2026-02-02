import 'dart:ui';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 右键菜单项数据类。
class ContextMenuItem {
  /// 创建一个菜单项。
  const ContextMenuItem({
    required this.label,
    this.icon,
    this.id,
  });

  /// 菜单项标签
  final String label;

  /// 可选的图标
  final IconData? icon;

  /// 可选的唯一标识符
  final String? id;
}

/// 毛玻璃效果的右键菜单组件。
///
/// 使用示例：
/// ```dart
/// ContextMenu(
///   items: [
///     ContextMenuItem(label: 'Copy', icon: Icons.copy),
///     ContextMenuItem(label: 'Paste', icon: Icons.paste),
///   ],
///   onItemSelected: (item) => print('Selected: ${item.label}'),
/// )
/// ```
class ContextMenu extends StatelessWidget {
  /// 创建一个右键菜单。
  const ContextMenu({
    super.key,
    required this.items,
    this.onItemSelected,
  });

  /// 菜单项列表
  final List<ContextMenuItem> items;

  /// 菜单项选中回调
  final ValueChanged<ContextMenuItem>? onItemSelected;

  /// 菜单圆角
  static const double borderRadius = 12.0;

  /// 菜单项高度
  static const double itemHeight = 36.0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      key: const Key('context_menu_clip'),
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        key: const Key('context_menu_blur'),
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          key: const Key('context_menu_container'),
          constraints: const BoxConstraints(
            minWidth: 150,
            maxWidth: 250,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBgElevated.withValues(alpha: 0.8)
                : AppColors.lightBgElevated.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            key: const Key('context_menu_items'),
            mainAxisSize: MainAxisSize.min,
            children: items.map((item) {
              return _ContextMenuItemWidget(
                key: Key('context_menu_item_${item.id ?? item.label}'),
                item: item,
                onTap: () => onItemSelected?.call(item),
                isDark: isDark,
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

/// 菜单项组件。
class _ContextMenuItemWidget extends StatefulWidget {
  const _ContextMenuItemWidget({
    super.key,
    required this.item,
    required this.onTap,
    required this.isDark,
  });

  final ContextMenuItem item;
  final VoidCallback onTap;
  final bool isDark;

  @override
  State<_ContextMenuItemWidget> createState() => _ContextMenuItemWidgetState();
}

class _ContextMenuItemWidgetState extends State<_ContextMenuItemWidget> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          height: ContextMenu.itemHeight,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? (widget.isDark
                    ? AppColors.darkBgSurface.withValues(alpha: 0.5)
                    : AppColors.lightBgSurface.withValues(alpha: 0.5))
                : Colors.transparent,
          ),
          child: Row(
            children: [
              if (widget.item.icon != null) ...[
                Icon(
                  widget.item.icon,
                  size: 16,
                  color: widget.isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.item.label,
                style: TextStyle(
                  fontSize: 13,
                  color: widget.isDark
                      ? AppColors.darkTextPrimary
                      : AppColors.lightTextPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 显示右键菜单的辅助函数。
Future<ContextMenuItem?> showContextMenu({
  required BuildContext context,
  required Offset position,
  required List<ContextMenuItem> items,
}) async {
  final overlay = Overlay.of(context);
  ContextMenuItem? selectedItem;

  final entry = OverlayEntry(
    builder: (context) => Positioned(
      left: position.dx,
      top: position.dy,
      child: Material(
        color: Colors.transparent,
        child: ContextMenu(
          items: items,
          onItemSelected: (item) {
            selectedItem = item;
          },
        ),
      ),
    ),
  );

  overlay.insert(entry);

  // 等待用户操作后移除
  await Future<void>.delayed(const Duration(milliseconds: 100));

  return selectedItem;
}
