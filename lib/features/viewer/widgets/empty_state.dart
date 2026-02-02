import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 空状态 Widget。
///
/// 当没有打开任何文件时显示此 Widget。
/// 显示 Logo、应用名称和拖放提示。
///
/// 使用示例：
/// ```dart
/// EmptyState(
///   onFileDropped: (path) {
///     print('File dropped: $path');
///   },
///   onOpenFile: () {
///     // 打开文件选择器
///   },
/// )
/// ```
class EmptyState extends StatefulWidget {
  /// 创建一个空状态 Widget。
  const EmptyState({
    super.key,
    this.onFileDropped,
    this.onOpenFile,
  });

  /// 文件拖放回调
  final void Function(String path)? onFileDropped;

  /// 打开文件回调
  final VoidCallback? onOpenFile;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo 容器
          Container(
            key: const Key('logoContainer'),
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkBgSurface
                  : AppColors.lightBgSurface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(
                Icons.description_outlined,
                size: 40,
                color: isDark
                    ? AppColors.accentPrimary
                    : AppColors.lightAccentPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // 标题
          Text(
            'PureMark',
            key: const Key('title'),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          // 提示文字
          Text(
            '拖拽 Markdown 文件至此',
            key: const Key('hint'),
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 32),
          // 拖放区域
          DragTarget<String>(
            onWillAcceptWithDetails: (details) {
              setState(() => _isDragOver = true);
              return true;
            },
            onLeave: (_) {
              setState(() => _isDragOver = false);
            },
            onAcceptWithDetails: (details) {
              setState(() => _isDragOver = false);
              widget.onFileDropped?.call(details.data);
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                key: const Key('dragArea'),
                width: 300,
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isDragOver
                        ? (isDark
                            ? AppColors.accentPrimary
                            : AppColors.lightAccentPrimary)
                        : (isDark
                            ? AppColors.darkBorderPrimary
                            : AppColors.lightBorderPrimary),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                  color: _isDragOver
                      ? (isDark
                          ? AppColors.darkBgSurface.withValues(alpha: 0.5)
                          : AppColors.lightBgSurface.withValues(alpha: 0.5))
                      : Colors.transparent,
                ),
                child: CustomPaint(
                  painter: DashedBorderPainter(
                    color: isDark
                        ? AppColors.darkBorderPrimary
                        : AppColors.lightBorderPrimary,
                    strokeWidth: 2,
                    dashWidth: 8,
                    dashSpace: 4,
                    radius: 12,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.upload_file,
                          size: 32,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '拖放文件到这里',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          key: const Key('openFileButton'),
                          onPressed: widget.onOpenFile,
                          style: TextButton.styleFrom(
                            foregroundColor: isDark
                                ? AppColors.accentPrimary
                                : AppColors.lightAccentPrimary,
                          ),
                          child: const Text('或点击选择文件'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 虚线边框绘制器。
class DashedBorderPainter extends CustomPainter {
  /// 创建一个虚线边框绘制器。
  DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashSpace,
    required this.radius,
  });

  /// 边框颜色
  final Color color;

  /// 边框宽度
  final double strokeWidth;

  /// 虚线宽度
  final double dashWidth;

  /// 虚线间距
  final double dashSpace;

  /// 圆角半径
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          Radius.circular(radius),
        ),
      );

    // 绘制虚线
    final dashPath = _createDashedPath(path);
    canvas.drawPath(dashPath, paint);
  }

  Path _createDashedPath(Path source) {
    final result = Path();
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final nextDistance = distance + dashWidth;
        result.addPath(
          metric.extractPath(
            distance,
            nextDistance > metric.length ? metric.length : nextDistance,
          ),
          Offset.zero,
        );
        distance = nextDistance + dashSpace;
      }
    }
    return result;
  }

  @override
  bool shouldRepaint(DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        strokeWidth != oldDelegate.strokeWidth ||
        dashWidth != oldDelegate.dashWidth ||
        dashSpace != oldDelegate.dashSpace ||
        radius != oldDelegate.radius;
  }
}
