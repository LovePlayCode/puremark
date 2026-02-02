import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/heading.dart';
import 'outline_item.dart';

/// 大纲侧边栏 Widget。
///
/// 显示文档的大纲结构，支持折叠和标题点击。
///
/// 使用示例：
/// ```dart
/// OutlineSidebar(
///   headings: [
///     Heading(id: '1', text: '简介', level: 1),
///     Heading(id: '2', text: '安装', level: 2),
///   ],
///   activeHeadingId: '1',
///   onHeadingTap: (heading) => scrollToHeading(heading),
///   isCollapsed: false,
///   onToggleCollapse: () => toggleSidebar(),
/// )
/// ```
class OutlineSidebar extends StatelessWidget {
  /// 创建一个大纲侧边栏。
  const OutlineSidebar({
    super.key,
    required this.headings,
    this.activeHeadingId,
    this.onHeadingTap,
    this.isCollapsed = false,
    this.onToggleCollapse,
  });

  /// 标题列表
  final List<Heading> headings;

  /// 当前活动标题 ID
  final String? activeHeadingId;

  /// 标题点击回调
  final void Function(Heading heading)? onHeadingTap;

  /// 是否折叠
  final bool isCollapsed;

  /// 折叠切换回调
  final VoidCallback? onToggleCollapse;

  /// 侧边栏宽度
  static const double width = 220;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // 背景颜色
    final backgroundColor =
        isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface;

    // 边框颜色
    final borderColor =
        isDark ? AppColors.darkBorderPrimary : AppColors.lightBorderPrimary;

    // 文字颜色
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (isCollapsed) {
      return _buildCollapsedSidebar(
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        textColor: textColor,
      );
    }

    return Container(
      key: const Key('outlineSidebar'),
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题栏
          _buildHeader(
            textColor: textColor,
            secondaryTextColor: secondaryTextColor,
          ),
          // 分割线
          Divider(
            height: 1,
            thickness: 1,
            color: borderColor,
          ),
          // 标题列表
          Expanded(
            child: headings.isEmpty
                ? _buildEmptyState(secondaryTextColor)
                : _buildHeadingList(),
          ),
        ],
      ),
    );
  }

  /// 构建折叠状态的侧边栏。
  Widget _buildCollapsedSidebar({
    required Color backgroundColor,
    required Color borderColor,
    required Color textColor,
  }) {
    return Container(
      key: const Key('outlineSidebar_collapsed'),
      width: 44,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          right: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          IconButton(
            key: const Key('expandButton'),
            icon: Icon(
              Icons.chevron_right,
              color: textColor,
              size: 20,
            ),
            onPressed: onToggleCollapse,
            tooltip: '展开大纲',
          ),
        ],
      ),
    );
  }

  /// 构建标题栏。
  Widget _buildHeader({
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Container(
      key: const Key('outlineHeader'),
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Text(
            '大纲',
            key: const Key('outlineTitle'),
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          IconButton(
            key: const Key('collapseButton'),
            icon: Icon(
              Icons.chevron_left,
              color: secondaryTextColor,
              size: 20,
            ),
            onPressed: onToggleCollapse,
            tooltip: '折叠大纲',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 28,
              minHeight: 28,
            ),
          ),
        ],
      ),
    );
  }

  /// 构建空状态。
  Widget _buildEmptyState(Color textColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          '暂无大纲',
          key: const Key('emptyOutlineText'),
          style: TextStyle(
            color: textColor,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  /// 构建标题列表。
  Widget _buildHeadingList() {
    return ListView.builder(
      key: const Key('outlineList'),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      itemCount: headings.length,
      itemBuilder: (context, index) {
        final heading = headings[index];
        return OutlineItem(
          heading: heading,
          isActive: heading.id == activeHeadingId,
          onTap: onHeadingTap,
        );
      },
    );
  }
}
