import 'package:flutter/material.dart';

/// PureMark 应用的颜色和尺寸常量定义。
///
/// 包含深色主题、浅色主题的颜色定义，以及 macOS 风格的交通灯颜色
/// 和常用的尺寸常量。
///
/// 使用示例：
/// ```dart
/// Container(
///   color: AppColors.darkBgPrimary,
///   child: Text(
///     'Hello',
///     style: TextStyle(color: AppColors.darkTextPrimary),
///   ),
/// )
/// ```
class AppColors {
  /// 私有构造函数，防止类被实例化。
  AppColors._();

  // ============================================
  // 深色主题背景色
  // ============================================

  /// 深色主题主背景色
  static const Color darkBgPrimary = Color(0xFF1A1A1C);

  /// 深色主题表面背景色
  static const Color darkBgSurface = Color(0xFF242426);

  /// 深色主题提升层背景色
  static const Color darkBgElevated = Color(0xFF2A2A2C);

  // ============================================
  // 深色主题文字色
  // ============================================

  /// 深色主题主要文字色
  static const Color darkTextPrimary = Color(0xFFF5F5F0);

  /// 深色主题次要文字色
  static const Color darkTextSecondary = Color(0xFF6E6E70);

  /// 深色主题第三级文字色
  static const Color darkTextTertiary = Color(0xFF4A4A4C);

  // ============================================
  // 深色主题边框色
  // ============================================

  /// 深色主题主要边框色
  static const Color darkBorderPrimary = Color(0xFF3A3A3C);

  /// 深色主题分割线色
  static const Color darkBorderDivider = Color(0xFF2A2A2C);

  // ============================================
  // 浅色主题背景色
  // ============================================

  /// 浅色主题主背景色
  static const Color lightBgPrimary = Color(0xFFFFFFFF);

  /// 浅色主题表面背景色
  static const Color lightBgSurface = Color(0xFFF5F5F7);

  /// 浅色主题提升层背景色
  static const Color lightBgElevated = Color(0xFFEAEAEC);

  // ============================================
  // 浅色主题文字色
  // ============================================

  /// 浅色主题主要文字色
  static const Color lightTextPrimary = Color(0xFF1D1D1F);

  /// 浅色主题次要文字色
  static const Color lightTextSecondary = Color(0xFF6E6E73);

  /// 浅色主题第三级文字色
  static const Color lightTextTertiary = Color(0xFFAEAEB2);

  // ============================================
  // 浅色主题边框色
  // ============================================

  /// 浅色主题主要边框色
  static const Color lightBorderPrimary = Color(0xFFD1D1D6);

  /// 浅色主题分割线色
  static const Color lightBorderDivider = Color(0xFFD1D1D6);

  // ============================================
  // 强调色
  // ============================================

  /// 深色主题主要强调色
  static const Color accentPrimary = Color(0xFF8B9EFF);

  /// 深色主题次要强调色
  static const Color accentSecondary = Color(0xFF6E9E6E);

  /// 浅色主题主要强调色
  static const Color lightAccentPrimary = Color(0xFF6366F1);

  /// 浅色主题次要强调色
  static const Color lightAccentSecondary = Color(0xFF22C55E);

  // ============================================
  // macOS 红绿灯颜色
  // ============================================

  /// macOS 窗口关闭按钮颜色（红色）
  static const Color trafficRed = Color(0xFFFF5F57);

  /// macOS 窗口最小化按钮颜色（黄色）
  static const Color trafficYellow = Color(0xFFFEBC2E);

  /// macOS 窗口最大化按钮颜色（绿色）
  static const Color trafficGreen = Color(0xFF28C840);

  // ============================================
  // 尺寸常量
  // ============================================

  /// 窗口圆角半径
  static const double windowRadius = 16.0;

  /// 卡片圆角半径
  static const double cardRadius = 12.0;

  /// 按钮圆角半径
  static const double buttonRadius = 8.0;
}
