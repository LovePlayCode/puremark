import 'package:flutter/material.dart';

import 'app_colors.dart';

/// PureMark 应用的主题配置。
///
/// 提供深色和浅色两种主题，遵循 Material Design 3 规范，
/// 同时融入 macOS 风格的设计元素。
///
/// 使用示例：
/// ```dart
/// MaterialApp(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeMode.system,
/// )
/// ```
class AppTheme {
  /// 私有构造函数，防止类被实例化。
  AppTheme._();

  /// 字体名称
  static const String _fontFamily = 'Inter';

  /// 深色主题配置
  ///
  /// 使用深色背景和浅色文字，适合低光环境使用。
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBgPrimary,
      colorScheme: const ColorScheme.dark(
        brightness: Brightness.dark,
        primary: AppColors.accentPrimary,
        onPrimary: AppColors.darkBgPrimary,
        surface: AppColors.darkBgSurface,
        onSurface: AppColors.darkTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBgPrimary,
        foregroundColor: AppColors.darkTextPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkBgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorderDivider,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.darkTextSecondary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          color: AppColors.darkTextPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          color: AppColors.darkTextSecondary,
        ),
      ),
    );
  }

  /// 浅色主题配置
  ///
  /// 使用浅色背景和深色文字，适合明亮环境使用。
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBgPrimary,
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: AppColors.lightAccentPrimary,
        onPrimary: AppColors.lightBgPrimary,
        surface: AppColors.lightBgSurface,
        onSurface: AppColors.lightTextPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightBgPrimary,
        foregroundColor: AppColors.lightTextPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightBgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorderDivider,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.lightTextSecondary,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(
          fontFamily: _fontFamily,
          color: AppColors.lightTextPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: _fontFamily,
          color: AppColors.lightTextPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: _fontFamily,
          color: AppColors.lightTextSecondary,
        ),
      ),
    );
  }
}
