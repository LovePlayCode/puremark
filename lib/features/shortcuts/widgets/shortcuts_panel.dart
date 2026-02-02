import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 快捷键定义。
class ShortcutItem {
  /// 创建一个快捷键项。
  const ShortcutItem({
    required this.label,
    required this.keys,
  });

  /// 快捷键描述
  final String label;

  /// 快捷键组合
  final List<String> keys;
}

/// 快捷键分组。
class ShortcutGroup {
  /// 创建一个快捷键分组。
  const ShortcutGroup({
    required this.title,
    required this.shortcuts,
  });

  /// 分组标题
  final String title;

  /// 快捷键列表
  final List<ShortcutItem> shortcuts;
}

/// 快捷键面板 Widget。
///
/// 显示应用的快捷键列表，按功能分组显示。
///
/// 使用示例：
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => ShortcutsPanel(
///     onClose: () => Navigator.pop(context),
///   ),
/// );
/// ```
class ShortcutsPanel extends StatelessWidget {
  /// 创建一个快捷键面板。
  const ShortcutsPanel({
    super.key,
    this.onClose,
  });

  /// 关闭回调
  final VoidCallback? onClose;

  /// 默认快捷键分组列表。
  static const List<ShortcutGroup> defaultGroups = [
    ShortcutGroup(
      title: '文件',
      shortcuts: [
        ShortcutItem(label: '打开文件', keys: ['⌘', 'O']),
        ShortcutItem(label: '关闭标签页', keys: ['⌘', 'W']),
        ShortcutItem(label: '关闭所有标签页', keys: ['⌘', 'Shift', 'W']),
      ],
    ),
    ShortcutGroup(
      title: '视图',
      shortcuts: [
        ShortcutItem(label: '切换大纲', keys: ['⌘', 'Shift', 'O']),
        ShortcutItem(label: '专注模式', keys: ['⌘', 'Shift', 'F']),
        ShortcutItem(label: '放大', keys: ['⌘', '+']),
        ShortcutItem(label: '缩小', keys: ['⌘', '-']),
        ShortcutItem(label: '重置缩放', keys: ['⌘', '0']),
      ],
    ),
    ShortcutGroup(
      title: '搜索',
      shortcuts: [
        ShortcutItem(label: '搜索', keys: ['⌘', 'F']),
        ShortcutItem(label: '下一个匹配', keys: ['Enter']),
        ShortcutItem(label: '上一个匹配', keys: ['Shift', 'Enter']),
        ShortcutItem(label: '关闭搜索', keys: ['Esc']),
      ],
    ),
    ShortcutGroup(
      title: '导航',
      shortcuts: [
        ShortcutItem(label: '下一个标签页', keys: ['⌘', 'Tab']),
        ShortcutItem(label: '上一个标签页', keys: ['⌘', 'Shift', 'Tab']),
        ShortcutItem(label: '跳转到标签页 1-9', keys: ['⌘', '1-9']),
      ],
    ),
    ShortcutGroup(
      title: '其他',
      shortcuts: [
        ShortcutItem(label: '设置', keys: ['⌘', ',']),
        ShortcutItem(label: '快捷键帮助', keys: ['⌘', '/']),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // 颜色定义
    final backgroundColor =
        isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor =
        isDark ? AppColors.darkBorderPrimary : AppColors.lightBorderPrimary;
    final elevatedBg =
        isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated;

    return Dialog(
      key: const Key('shortcutsPanel'),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 480,
        constraints: const BoxConstraints(maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            _buildHeader(textColor, borderColor),
            // 快捷键列表
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < defaultGroups.length; i++) ...[
                      _buildGroup(
                        group: defaultGroups[i],
                        textColor: textColor,
                        secondaryTextColor: secondaryTextColor,
                        elevatedBg: elevatedBg,
                      ),
                      if (i < defaultGroups.length - 1) const SizedBox(height: 24),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建标题栏。
  Widget _buildHeader(Color textColor, Color borderColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '快捷键',
            key: const Key('shortcutsTitle'),
            style: TextStyle(
              color: textColor,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            key: const Key('closeButton'),
            icon: Icon(Icons.close, color: textColor, size: 20),
            onPressed: onClose,
            tooltip: '关闭',
          ),
        ],
      ),
    );
  }

  /// 构建快捷键分组。
  Widget _buildGroup({
    required ShortcutGroup group,
    required Color textColor,
    required Color secondaryTextColor,
    required Color elevatedBg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.title,
          key: Key('groupTitle_${group.title}'),
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        ...group.shortcuts.map(
          (shortcut) => _buildShortcutItem(
            shortcut: shortcut,
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
            elevatedBg: elevatedBg,
          ),
        ),
      ],
    );
  }

  /// 构建快捷键项。
  Widget _buildShortcutItem({
    required ShortcutItem shortcut,
    required Color textColor,
    required Color secondaryTextColor,
    required Color elevatedBg,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            shortcut.label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
            ),
          ),
          Row(
            children: [
              for (int i = 0; i < shortcut.keys.length; i++) ...[
                _buildKeyBadge(
                  key: shortcut.keys[i],
                  textColor: textColor,
                  backgroundColor: elevatedBg,
                ),
                if (i < shortcut.keys.length - 1) const SizedBox(width: 4),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// 构建键位徽章。
  Widget _buildKeyBadge({
    required String key,
    required Color textColor,
    required Color backgroundColor,
  }) {
    return Container(
      key: Key('keyBadge_$key'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        key,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}
