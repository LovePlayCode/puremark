import 'dart:async';

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 文件同步通知 Toast 组件。
///
/// 显示文件同步状态，自动消失。
///
/// 使用示例：
/// ```dart
/// SyncToast(
///   message: 'File synced successfully',
///   icon: Icons.check_circle,
///   duration: const Duration(seconds: 2),
///   onDismiss: () => print('Toast dismissed'),
/// )
/// ```
class SyncToast extends StatefulWidget {
  /// 创建一个同步 Toast。
  const SyncToast({
    super.key,
    required this.message,
    this.icon,
    this.duration = const Duration(seconds: 2),
    this.onDismiss,
  });

  /// 消息文本
  final String message;

  /// 可选的图标
  final IconData? icon;

  /// 显示持续时间
  final Duration duration;

  /// 消失回调
  final VoidCallback? onDismiss;

  /// Toast 圆角
  static const double borderRadius = 8.0;

  @override
  State<SyncToast> createState() => _SyncToastState();
}

class _SyncToastState extends State<SyncToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();
    _startDismissTimer();
  }

  void _startDismissTimer() {
    _dismissTimer = Timer(widget.duration, _dismiss);
  }

  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss?.call();
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SlideTransition(
      key: const Key('sync_toast_slide'),
      position: _slideAnimation,
      child: FadeTransition(
        key: const Key('sync_toast_fade'),
        opacity: _fadeAnimation,
        child: Container(
          key: const Key('sync_toast_container'),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkBgElevated
                : AppColors.lightBgElevated,
            borderRadius: BorderRadius.circular(SyncToast.borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            key: const Key('sync_toast_content'),
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  key: const Key('sync_toast_icon'),
                  size: 18,
                  color: isDark
                      ? AppColors.accentPrimary
                      : AppColors.lightAccentPrimary,
                ),
                const SizedBox(width: 8),
              ],
              Text(
                widget.message,
                key: const Key('sync_toast_message'),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark
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

/// 显示同步 Toast 的辅助函数。
OverlayEntry showSyncToast({
  required BuildContext context,
  required String message,
  IconData? icon,
  Duration duration = const Duration(seconds: 2),
}) {
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (context) => Positioned(
      top: 60,
      left: 0,
      right: 0,
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: SyncToast(
            message: message,
            icon: icon,
            duration: duration,
            onDismiss: () => entry.remove(),
          ),
        ),
      ),
    ),
  );

  Overlay.of(context).insert(entry);
  return entry;
}
