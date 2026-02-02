import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../shared/services/storage_service.dart';
import '../models/settings_state.dart';

/// SharedPreferences Provider。
///
/// 提供 SharedPreferences 的异步访问。
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// StorageService Provider。
///
/// 依赖 SharedPreferences 提供存储服务。
final storageServiceProvider = Provider<StorageService?>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.whenOrNull(
    data: (prefs) => StorageService(prefs),
  );
});

/// 设置状态 Provider。
///
/// 使用 AsyncNotifierProvider 管理设置功能的状态。
///
/// 使用示例：
/// ```dart
/// // 读取当前设置状态
/// final settingsAsync = ref.watch(settingsProvider);
/// settingsAsync.when(
///   data: (settings) => print(settings.themeMode),
///   loading: () => print('加载中'),
///   error: (e, s) => print('错误: $e'),
/// );
///
/// // 设置主题模式
/// ref.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);
/// ```
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, SettingsState>(
  SettingsNotifier.new,
);

/// 设置状态 Notifier。
///
/// 管理设置的加载、保存和更新。
class SettingsNotifier extends AsyncNotifier<SettingsState> {
  StorageService? _storageService;

  @override
  Future<SettingsState> build() async {
    // 获取 SharedPreferences
    final prefs = await ref.watch(sharedPreferencesProvider.future);
    _storageService = StorageService(prefs);

    // 从存储加载设置
    return _loadSettings();
  }

  /// 从存储加载设置。
  SettingsState _loadSettings() {
    final storage = _storageService;
    if (storage == null) {
      return SettingsState.defaults();
    }

    return SettingsState(
      themeMode: storage.getThemeMode(),
      fontSize: storage.getFontSize(),
      autoRefresh: storage.getAutoRefresh(),
      showOutline: storage.getShowOutline(),
    );
  }

  /// 设置主题模式。
  Future<void> setThemeMode(ThemeMode mode) async {
    final currentState = state.valueOrNull ?? SettingsState.defaults();
    state = AsyncData(currentState.copyWith(themeMode: mode));

    await _storageService?.setThemeMode(mode);
  }

  /// 设置字号。
  ///
  /// 字号会被限制在 12-24 之间。
  Future<void> setFontSize(int size) async {
    final clampedSize = size.clamp(
      SettingsState.minFontSize,
      SettingsState.maxFontSize,
    );
    final currentState = state.valueOrNull ?? SettingsState.defaults();
    state = AsyncData(currentState.copyWith(fontSize: clampedSize));

    await _storageService?.setFontSize(clampedSize);
  }

  /// 增大字号。
  Future<void> increaseFontSize() async {
    final currentState = state.valueOrNull ?? SettingsState.defaults();
    if (currentState.canIncreaseFontSize) {
      await setFontSize(currentState.fontSize + 1);
    }
  }

  /// 减小字号。
  Future<void> decreaseFontSize() async {
    final currentState = state.valueOrNull ?? SettingsState.defaults();
    if (currentState.canDecreaseFontSize) {
      await setFontSize(currentState.fontSize - 1);
    }
  }

  /// 切换自动刷新。
  Future<void> toggleAutoRefresh() async {
    final currentState = state.valueOrNull ?? SettingsState.defaults();
    final newValue = !currentState.autoRefresh;
    state = AsyncData(currentState.copyWith(autoRefresh: newValue));

    await _storageService?.setAutoRefresh(newValue);
  }

  /// 切换显示大纲。
  Future<void> toggleShowOutline() async {
    final currentState = state.valueOrNull ?? SettingsState.defaults();
    final newValue = !currentState.showOutline;
    state = AsyncData(currentState.copyWith(showOutline: newValue));

    await _storageService?.setShowOutline(newValue);
  }

  /// 重置所有设置为默认值。
  Future<void> resetToDefaults() async {
    state = AsyncData(SettingsState.defaults());

    final storage = _storageService;
    if (storage != null) {
      await storage.setThemeMode(ThemeMode.system);
      await storage.setFontSize(SettingsState.defaultFontSize);
      await storage.setAutoRefresh(true);
      await storage.setShowOutline(true);
    }
  }
}
