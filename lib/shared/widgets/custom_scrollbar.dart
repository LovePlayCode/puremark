import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 自定义浮动胶囊样式滚动条组件。
///
/// 滚动时显示，静止后淡出。
///
/// 使用示例：
/// ```dart
/// final scrollController = ScrollController();
///
/// CustomScrollbar(
///   controller: scrollController,
///   fadeOutDuration: const Duration(seconds: 1),
///   child: ListView.builder(
///     controller: scrollController,
///     itemBuilder: (context, index) => Text('Item $index'),
///   ),
/// )
/// ```
class CustomScrollbar extends StatefulWidget {
  /// 创建一个自定义滚动条。
  const CustomScrollbar({
    super.key,
    required this.controller,
    required this.child,
    this.fadeOutDuration = const Duration(milliseconds: 800),
  });

  /// 滚动控制器
  final ScrollController controller;

  /// 子组件
  final Widget child;

  /// 淡出持续时间
  final Duration fadeOutDuration;

  /// 滚动条宽度
  static const double width = 6.0;

  /// 滚动条圆角
  static const double borderRadius = 4.0;

  @override
  State<CustomScrollbar> createState() => _CustomScrollbarState();
}

class _CustomScrollbarState extends State<CustomScrollbar> {
  bool _isVisible = false;
  Timer? _fadeTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }

    _fadeTimer?.cancel();
    _fadeTimer = Timer(widget.fadeOutDuration, () {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      key: const Key('custom_scrollbar_stack'),
      children: [
        widget.child,
        Positioned(
          right: 4,
          top: 8,
          bottom: 8,
          child: AnimatedOpacity(
            key: const Key('scrollbar_opacity'),
            opacity: _isVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              key: const Key('scrollbar_track'),
              width: CustomScrollbar.width,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkTextTertiary.withValues(alpha: 0.3)
                    : AppColors.lightTextTertiary.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(CustomScrollbar.borderRadius),
              ),
              child: _ScrollbarThumb(
                key: const Key('scrollbar_thumb'),
                controller: widget.controller,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 滚动条滑块组件。
class _ScrollbarThumb extends StatelessWidget {
  const _ScrollbarThumb({
    super.key,
    required this.controller,
    required this.color,
  });

  final ScrollController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (!controller.hasClients || !controller.position.hasContentDimensions) {
          return const SizedBox.shrink();
        }

        final viewportHeight = controller.position.viewportDimension;
        final contentHeight = controller.position.maxScrollExtent + viewportHeight;
        final scrollOffset = controller.offset;

        if (contentHeight <= viewportHeight) {
          return const SizedBox.shrink();
        }

        final thumbHeightRatio = viewportHeight / contentHeight;
        final thumbHeight = (thumbHeightRatio * viewportHeight).clamp(30.0, viewportHeight);
        final maxThumbOffset = viewportHeight - thumbHeight;
        final scrollRatio = scrollOffset / controller.position.maxScrollExtent;
        final thumbOffset = scrollRatio * maxThumbOffset;

        return Padding(
          padding: EdgeInsets.only(top: thumbOffset.clamp(0.0, maxThumbOffset)),
          child: Container(
            height: thumbHeight,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(CustomScrollbar.borderRadius),
            ),
          ),
        );
      },
    );
  }
}
