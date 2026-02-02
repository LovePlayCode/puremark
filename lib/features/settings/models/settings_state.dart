import 'package:flutter/material.dart';

/// 设置状态实体类。
///
/// 用于管理应用设置信息，包括主题模式、字号、自动刷新和显示大纲。
///
/// 使用示例：
/// ```dart
/// final state = SettingsState(
///   themeMode: ThemeMode.dark,
///   fontSize: 16,
///   autoRefresh: true,
///   showOutline: true,
/// );
/// ```
class SettingsState {
  /// 创建一个设置状态实例。
  const SettingsState({
    this.themeMode = ThemeMode.system,
    this.fontSize = 16,
    this.autoRefresh = true,
    this.showOutline = true,
  });

  /// 主题模式（dark/light/system）
  final ThemeMode themeMode;

  /// 字号大小（12-24，默认 16）
  final int fontSize;

  /// 自动刷新（默认 true）
  final bool autoRefresh;

  /// 显示大纲（默认 true）
  final bool showOutline;

  /// 最小字号
  static const int minFontSize = 12;

  /// 最大字号
  static const int maxFontSize = 24;

  /// 默认字号
  static const int defaultFontSize = 16;

  /// 是否可以增大字号。
  bool get canIncreaseFontSize => fontSize < maxFontSize;

  /// 是否可以减小字号。
  bool get canDecreaseFontSize => fontSize > minFontSize;

  /// 创建一个默认的设置状态。
  factory SettingsState.defaults() {
    return const SettingsState();
  }

  /// 创建一个新的 SettingsState 副本，可选择性地更新某些字段。
  SettingsState copyWith({
    ThemeMode? themeMode,
    int? fontSize,
    bool? autoRefresh,
    bool? showOutline,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      fontSize: fontSize ?? this.fontSize,
      autoRefresh: autoRefresh ?? this.autoRefresh,
      showOutline: showOutline ?? this.showOutline,
    );
  }

  /// 创建一个带有约束字号的副本。
  ///
  /// 确保字号在 [minFontSize] 和 [maxFontSize] 之间。
  SettingsState withClampedFontSize(int size) {
    final clampedSize = size.clamp(minFontSize, maxFontSize);
    return copyWith(fontSize: clampedSize);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsState &&
        other.themeMode == themeMode &&
        other.fontSize == fontSize &&
        other.autoRefresh == autoRefresh &&
        other.showOutline == showOutline;
  }

  @override
  int get hashCode {
    return Object.hash(themeMode, fontSize, autoRefresh, showOutline);
  }

  @override
  String toString() {
    return 'SettingsState(themeMode: $themeMode, fontSize: $fontSize, '
        'autoRefresh: $autoRefresh, showOutline: $showOutline)';
  }
}
