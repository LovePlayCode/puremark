import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 本地存储服务。
///
/// 使用 shared_preferences 进行本地数据持久化。
///
/// 使用示例：
/// ```dart
/// final storage = StorageService(prefs);
/// await storage.setThemeMode(ThemeMode.dark);
/// final themeMode = storage.getThemeMode();
/// ```
class StorageService {
  /// 创建一个存储服务实例。
  const StorageService(this._prefs);

  final SharedPreferences _prefs;

  // ============================================
  // 存储键常量
  // ============================================

  /// 主题模式键
  static const String keyThemeMode = 'themeMode';

  /// 字号键
  static const String keyFontSize = 'fontSize';

  /// 自动刷新键
  static const String keyAutoRefresh = 'autoRefresh';

  /// 显示大纲键
  static const String keyShowOutline = 'showOutline';

  // ============================================
  // 主题模式
  // ============================================

  /// 获取主题模式。
  ///
  /// 返回 [ThemeMode.system] 如果未设置。
  ThemeMode getThemeMode() {
    final value = _prefs.getString(keyThemeMode);
    return _stringToThemeMode(value);
  }

  /// 设置主题模式。
  Future<bool> setThemeMode(ThemeMode mode) async {
    return _prefs.setString(keyThemeMode, _themeModeToString(mode));
  }

  // ============================================
  // 字号
  // ============================================

  /// 获取字号。
  ///
  /// 返回 16 如果未设置。
  int getFontSize() {
    return _prefs.getInt(keyFontSize) ?? 16;
  }

  /// 设置字号。
  Future<bool> setFontSize(int size) async {
    return _prefs.setInt(keyFontSize, size);
  }

  // ============================================
  // 自动刷新
  // ============================================

  /// 获取自动刷新设置。
  ///
  /// 返回 true 如果未设置。
  bool getAutoRefresh() {
    return _prefs.getBool(keyAutoRefresh) ?? true;
  }

  /// 设置自动刷新。
  Future<bool> setAutoRefresh(bool value) async {
    return _prefs.setBool(keyAutoRefresh, value);
  }

  // ============================================
  // 显示大纲
  // ============================================

  /// 获取显示大纲设置。
  ///
  /// 返回 true 如果未设置。
  bool getShowOutline() {
    return _prefs.getBool(keyShowOutline) ?? true;
  }

  /// 设置显示大纲。
  Future<bool> setShowOutline(bool value) async {
    return _prefs.setBool(keyShowOutline, value);
  }

  // ============================================
  // 辅助方法
  // ============================================

  /// 将 ThemeMode 转换为字符串。
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// 将字符串转换为 ThemeMode。
  ThemeMode _stringToThemeMode(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// 清除所有设置。
  Future<bool> clearAll() async {
    return _prefs.clear();
  }
}
