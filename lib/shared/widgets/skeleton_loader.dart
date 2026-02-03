import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 骨架屏类型枚举。
enum SkeletonType {
  /// 标题骨架
  title,

  /// 段落骨架
  paragraph,

  /// 代码块骨架
  codeBlock,

  /// Mermaid 图表骨架
  mermaid,
}

/// 骨架屏加载占位组件。
///
/// 支持不同类型的骨架屏，带有渐变动画效果。
///
/// 使用示例：
/// ```dart
/// SkeletonLoader(
///   type: SkeletonType.title,
///   width: 200,
///   height: 24,
/// )
/// ```
class SkeletonLoader extends StatefulWidget {
  /// 创建一个骨架屏加载器。
  const SkeletonLoader({
    super.key,
    this.type = SkeletonType.paragraph,
    this.width,
    this.height,
  });

  /// 骨架屏类型
  final SkeletonType type;

  /// 可选的宽度
  final double? width;

  /// 可选的高度
  final double? height;

  @override
  State<SkeletonLoader> createState() => _SkeletonLoaderState();
}

class _SkeletonLoaderState extends State<SkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _borderRadius {
    switch (widget.type) {
      case SkeletonType.title:
        return 6.0;
      case SkeletonType.paragraph:
        return 4.0;
      case SkeletonType.codeBlock:
        return 12.0;
      case SkeletonType.mermaid:
        return 12.0;
    }
  }

  Size get _defaultSize {
    switch (widget.type) {
      case SkeletonType.title:
        return const Size(200, 24);
      case SkeletonType.paragraph:
        return const Size(double.infinity, 16);
      case SkeletonType.codeBlock:
        return const Size(double.infinity, 120);
      case SkeletonType.mermaid:
        return const Size(double.infinity, 200);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? AppColors.darkBgSurface
        : AppColors.lightBgSurface;
    final highlightColor = isDark
        ? AppColors.darkBgElevated
        : AppColors.lightBgElevated;

    final size = _defaultSize;
    final width = widget.width ?? size.width;
    final height = widget.height ?? size.height;

    return AnimatedBuilder(
      key: Key('skeleton_loader_${widget.type.name}'),
      animation: _animation,
      builder: (context, child) {
        final t = _animation.value.clamp(0.0, 1.0);
        final stop1 = (t - 0.35).clamp(0.0, 1.0);
        final stop2 = t;
        final stop3 = (t + 0.35).clamp(0.0, 1.0);
        final s1 = stop1;
        final s2 = stop2 > s1 ? stop2 : s1 + 0.05;
        final s3 = stop3 > s2 ? stop3 : s2 + 0.05;
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(_borderRadius),
            color: baseColor,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [baseColor, highlightColor, baseColor],
              stops: [s1, s2, s3],
            ),
          ),
        );
      },
    );
  }
}

/// 骨架屏组合组件。
///
/// 用于快速创建常见的骨架屏布局。
class SkeletonGroup extends StatelessWidget {
  /// 创建一个骨架屏组合。
  const SkeletonGroup({
    super.key,
    this.titleWidth = 200,
    this.paragraphLines = 3,
  });

  /// 标题宽度
  final double titleWidth;

  /// 段落行数
  final int paragraphLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('skeleton_group'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SkeletonLoader(
          key: const Key('skeleton_group_title'),
          type: SkeletonType.title,
          width: titleWidth,
        ),
        const SizedBox(height: 16),
        ...List.generate(
          paragraphLines,
          (index) => Padding(
            key: Key('skeleton_group_paragraph_$index'),
            padding: const EdgeInsets.only(bottom: 8),
            child: SkeletonLoader(
              type: SkeletonType.paragraph,
              width: index == paragraphLines - 1 ? 200 : double.infinity,
            ),
          ),
        ),
      ],
    );
  }
}
