import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/heading.dart';

/// 大纲列表项 Widget。
///
/// 显示单个标题项，支持层级缩进和活动状态高亮。
///
/// 使用示例：
/// ```dart
/// OutlineItem(
///   heading: Heading(id: '1', text: '简介', level: 1),
///   isActive: true,
///   onTap: (heading) => print('点击了: ${heading.text}'),
/// )
/// ```
class OutlineItem extends StatelessWidget {
  /// 创建一个大纲列表项。
  const OutlineItem({
    super.key,
    required this.heading,
    this.isActive = false,
    this.onTap,
  });

  /// 标题数据
  final Heading heading;

  /// 是否为活动状态
  final bool isActive;

  /// 点击回调
  final void Function(Heading heading)? onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // 文字颜色
    final textColor = isActive
        ? AppColors.accentPrimary
        : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary);

    // 背景颜色（活动时）
    final backgroundColor = isActive
        ? AppColors.accentPrimary.withOpacity(0.1)
        : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key('outlineItem_${heading.id}'),
        onTap: onTap != null ? () => onTap!(heading) : null,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 12 + heading.indent,
            right: 12,
            top: 8,
            bottom: 8,
          ),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            heading.text,
            style: TextStyle(
              color: textColor,
              fontSize: _getFontSize(heading.level),
              fontWeight: _getFontWeight(heading.level),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }

  /// 根据标题级别获取字体大小。
  double _getFontSize(int level) {
    switch (level) {
      case 1:
        return 14;
      case 2:
        return 13;
      case 3:
        return 12;
      default:
        return 12;
    }
  }

  /// 根据标题级别获取字体粗细。
  FontWeight _getFontWeight(int level) {
    switch (level) {
      case 1:
        return FontWeight.w600;
      case 2:
        return FontWeight.w500;
      case 3:
        return FontWeight.w400;
      default:
        return FontWeight.w400;
    }
  }
}
