import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 主题模式 Provider。
///
/// 使用 StateProvider 管理应用的主题模式。
/// 初始值为 ThemeMode.dark。
///
/// 使用示例：
/// ```dart
/// // 读取当前主题模式
/// final themeMode = ref.watch(themeModeProvider);
///
/// // 更新主题模式
/// ref.read(themeModeProvider.notifier).state = ThemeMode.light;
/// ```
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.dark;
});
