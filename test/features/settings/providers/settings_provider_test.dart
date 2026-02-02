import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:puremark/features/settings/models/settings_state.dart';
import 'package:puremark/features/settings/providers/settings_provider.dart';
import 'package:puremark/shared/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SettingsState', () {
    group('构造函数', () {
      test('默认构造函数应该创建默认状态', () {
        // Act
        const state = SettingsState();

        // Assert
        expect(state.themeMode, equals(ThemeMode.system));
        expect(state.fontSize, equals(16));
        expect(state.autoRefresh, isTrue);
        expect(state.showOutline, isTrue);
      });

      test('factory defaults 应该创建默认状态', () {
        // Act
        final state = SettingsState.defaults();

        // Assert
        expect(state.themeMode, equals(ThemeMode.system));
        expect(state.fontSize, equals(16));
        expect(state.autoRefresh, isTrue);
        expect(state.showOutline, isTrue);
      });

      test('应该正确创建带数据的状态', () {
        // Act
        const state = SettingsState(
          themeMode: ThemeMode.dark,
          fontSize: 20,
          autoRefresh: false,
          showOutline: false,
        );

        // Assert
        expect(state.themeMode, equals(ThemeMode.dark));
        expect(state.fontSize, equals(20));
        expect(state.autoRefresh, isFalse);
        expect(state.showOutline, isFalse);
      });
    });

    group('常量', () {
      test('minFontSize 应该是 12', () {
        expect(SettingsState.minFontSize, equals(12));
      });

      test('maxFontSize 应该是 24', () {
        expect(SettingsState.maxFontSize, equals(24));
      });

      test('defaultFontSize 应该是 16', () {
        expect(SettingsState.defaultFontSize, equals(16));
      });
    });

    group('canIncreaseFontSize', () {
      test('字号小于最大值时应该返回 true', () {
        // Arrange
        const state = SettingsState(fontSize: 20);

        // Assert
        expect(state.canIncreaseFontSize, isTrue);
      });

      test('字号等于最大值时应该返回 false', () {
        // Arrange
        const state = SettingsState(fontSize: 24);

        // Assert
        expect(state.canIncreaseFontSize, isFalse);
      });
    });

    group('canDecreaseFontSize', () {
      test('字号大于最小值时应该返回 true', () {
        // Arrange
        const state = SettingsState(fontSize: 16);

        // Assert
        expect(state.canDecreaseFontSize, isTrue);
      });

      test('字号等于最小值时应该返回 false', () {
        // Arrange
        const state = SettingsState(fontSize: 12);

        // Assert
        expect(state.canDecreaseFontSize, isFalse);
      });
    });

    group('copyWith', () {
      test('copyWith 应该正确复制并更新字段', () {
        // Arrange
        const original = SettingsState(
          themeMode: ThemeMode.dark,
          fontSize: 16,
          autoRefresh: true,
          showOutline: true,
        );

        // Act
        final updated = original.copyWith(themeMode: ThemeMode.light);

        // Assert
        expect(updated.themeMode, equals(ThemeMode.light));
        expect(updated.fontSize, equals(16));
        expect(updated.autoRefresh, isTrue);
        expect(updated.showOutline, isTrue);
      });

      test('copyWith 不传参数应该返回相同值', () {
        // Arrange
        const original = SettingsState(
          themeMode: ThemeMode.dark,
          fontSize: 20,
          autoRefresh: false,
          showOutline: false,
        );

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied, equals(original));
      });

      test('copyWith 可以更新所有字段', () {
        // Arrange
        const original = SettingsState();

        // Act
        final updated = original.copyWith(
          themeMode: ThemeMode.light,
          fontSize: 20,
          autoRefresh: false,
          showOutline: false,
        );

        // Assert
        expect(updated.themeMode, equals(ThemeMode.light));
        expect(updated.fontSize, equals(20));
        expect(updated.autoRefresh, isFalse);
        expect(updated.showOutline, isFalse);
      });
    });

    group('withClampedFontSize', () {
      test('应该限制字号在最小值和最大值之间', () {
        // Arrange
        const state = SettingsState();

        // Act & Assert - 小于最小值
        final tooSmall = state.withClampedFontSize(8);
        expect(tooSmall.fontSize, equals(12));

        // Act & Assert - 大于最大值
        final tooLarge = state.withClampedFontSize(30);
        expect(tooLarge.fontSize, equals(24));

        // Act & Assert - 在范围内
        final normal = state.withClampedFontSize(18);
        expect(normal.fontSize, equals(18));
      });
    });

    group('相等性', () {
      test('相同值的 SettingsState 应该相等', () {
        // Arrange
        const state1 = SettingsState(
          themeMode: ThemeMode.dark,
          fontSize: 16,
          autoRefresh: true,
          showOutline: true,
        );
        const state2 = SettingsState(
          themeMode: ThemeMode.dark,
          fontSize: 16,
          autoRefresh: true,
          showOutline: true,
        );

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('不同 themeMode 的 SettingsState 应该不相等', () {
        // Arrange
        const state1 = SettingsState(themeMode: ThemeMode.dark);
        const state2 = SettingsState(themeMode: ThemeMode.light);

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('不同 fontSize 的 SettingsState 应该不相等', () {
        // Arrange
        const state1 = SettingsState(fontSize: 14);
        const state2 = SettingsState(fontSize: 18);

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('不同 autoRefresh 的 SettingsState 应该不相等', () {
        // Arrange
        const state1 = SettingsState(autoRefresh: true);
        const state2 = SettingsState(autoRefresh: false);

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('不同 showOutline 的 SettingsState 应该不相等', () {
        // Arrange
        const state1 = SettingsState(showOutline: true);
        const state2 = SettingsState(showOutline: false);

        // Assert
        expect(state1, isNot(equals(state2)));
      });
    });

    group('toString', () {
      test('toString 应该包含所有信息', () {
        // Arrange
        const state = SettingsState(
          themeMode: ThemeMode.dark,
          fontSize: 18,
          autoRefresh: true,
          showOutline: false,
        );

        // Act
        final str = state.toString();

        // Assert
        expect(str, contains('SettingsState'));
        expect(str, contains('dark'));
        expect(str, contains('18'));
        expect(str, contains('true'));
        expect(str, contains('false'));
      });
    });
  });

  group('StorageService', () {
    late SharedPreferences prefs;
    late StorageService storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = StorageService(prefs);
    });

    group('themeMode', () {
      test('默认应该返回 system', () {
        // Assert
        expect(storage.getThemeMode(), equals(ThemeMode.system));
      });

      test('应该正确保存和读取 dark', () async {
        // Act
        await storage.setThemeMode(ThemeMode.dark);

        // Assert
        expect(storage.getThemeMode(), equals(ThemeMode.dark));
      });

      test('应该正确保存和读取 light', () async {
        // Act
        await storage.setThemeMode(ThemeMode.light);

        // Assert
        expect(storage.getThemeMode(), equals(ThemeMode.light));
      });

      test('应该正确保存和读取 system', () async {
        // Act
        await storage.setThemeMode(ThemeMode.system);

        // Assert
        expect(storage.getThemeMode(), equals(ThemeMode.system));
      });
    });

    group('fontSize', () {
      test('默认应该返回 16', () {
        // Assert
        expect(storage.getFontSize(), equals(16));
      });

      test('应该正确保存和读取字号', () async {
        // Act
        await storage.setFontSize(20);

        // Assert
        expect(storage.getFontSize(), equals(20));
      });
    });

    group('autoRefresh', () {
      test('默认应该返回 true', () {
        // Assert
        expect(storage.getAutoRefresh(), isTrue);
      });

      test('应该正确保存和读取 autoRefresh', () async {
        // Act
        await storage.setAutoRefresh(false);

        // Assert
        expect(storage.getAutoRefresh(), isFalse);
      });
    });

    group('showOutline', () {
      test('默认应该返回 true', () {
        // Assert
        expect(storage.getShowOutline(), isTrue);
      });

      test('应该正确保存和读取 showOutline', () async {
        // Act
        await storage.setShowOutline(false);

        // Assert
        expect(storage.getShowOutline(), isFalse);
      });
    });

    group('clearAll', () {
      test('应该清除所有设置', () async {
        // Arrange
        await storage.setThemeMode(ThemeMode.dark);
        await storage.setFontSize(20);
        await storage.setAutoRefresh(false);
        await storage.setShowOutline(false);

        // Act
        await storage.clearAll();

        // Assert - 应该恢复默认值
        expect(storage.getThemeMode(), equals(ThemeMode.system));
        expect(storage.getFontSize(), equals(16));
        expect(storage.getAutoRefresh(), isTrue);
        expect(storage.getShowOutline(), isTrue);
      });
    });
  });

  group('SettingsProvider', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() {
      container.dispose();
    });

    group('初始状态', () {
      test('初始状态应该是默认设置', () async {
        // Arrange
        container = ProviderContainer();

        // Act
        final state = await container.read(settingsProvider.future);

        // Assert
        expect(state.themeMode, equals(ThemeMode.system));
        expect(state.fontSize, equals(16));
        expect(state.autoRefresh, isTrue);
        expect(state.showOutline, isTrue);
      });

      test('应该从存储加载设置', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'themeMode': 'dark',
          'fontSize': 20,
          'autoRefresh': false,
          'showOutline': false,
        });
        container = ProviderContainer();

        // Act
        final state = await container.read(settingsProvider.future);

        // Assert
        expect(state.themeMode, equals(ThemeMode.dark));
        expect(state.fontSize, equals(20));
        expect(state.autoRefresh, isFalse);
        expect(state.showOutline, isFalse);
      });
    });

    group('setThemeMode', () {
      test('应该正确设置主题模式', () async {
        // Arrange
        container = ProviderContainer();
        await container.read(settingsProvider.future);

        // Act
        await container.read(settingsProvider.notifier).setThemeMode(ThemeMode.dark);

        // Assert
        final state = await container.read(settingsProvider.future);
        expect(state.themeMode, equals(ThemeMode.dark));
      });
    });

    group('setFontSize', () {
      test('应该正确设置字号', () async {
        // Arrange
        container = ProviderContainer();
        await container.read(settingsProvider.future);

        // Act
        await container.read(settingsProvider.notifier).setFontSize(20);

        // Assert
        final state = await container.read(settingsProvider.future);
        expect(state.fontSize, equals(20));
      });

      test('应该限制字号在有效范围内', () async {
        // Arrange
        container = ProviderContainer();
        await container.read(settingsProvider.future);

        // Act - 设置过小的字号
        await container.read(settingsProvider.notifier).setFontSize(8);

        // Assert
        var state = await container.read(settingsProvider.future);
        expect(state.fontSize, equals(12));

        // Act - 设置过大的字号
        await container.read(settingsProvider.notifier).setFontSize(30);

        // Assert
        state = await container.read(settingsProvider.future);
        expect(state.fontSize, equals(24));
      });
    });

    group('increaseFontSize', () {
      test('应该增大字号', () async {
        // Arrange
        container = ProviderContainer();
        await container.read(settingsProvider.future);

        // Act
        await container.read(settingsProvider.notifier).increaseFontSize();

        // Assert
        final state = await container.read(settingsProvider.future);
        expect(state.fontSize, equals(17));
      });

      test('字号已是最大值时不应该增大', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'fontSize': 24});
        container = ProviderContainer();
        await container.read(settingsProvider.future);

        // Act
        await container.read(settingsProvider.notifier).increaseFontSize();

        // Assert
        final state = await container.read(settingsProvider.future);
        expect(state.fontSize, equals(24));
      });
    });

    group('decreaseFontSize', () {
      test('应该减小字号', () async {
        // Arrange
        container = ProviderContainer();
        await container.read(settingsProvider.future);

        // Act
        await container.read(settingsProvider.notifier).decreaseFontSize();

        // Assert
        final state = await container.read(settingsProvider.future);
        expect(state.fontSize, equals(15));
      });

      test('字号已是最小值时不应该减小', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({'fontSize': 12});
        container = ProviderContainer();
        await container.read(settingsProvider.future);

        // Act
        await container.read(settingsProvider.notifier).decreaseFontSize();

        // Assert
        final state = await container.read(settingsProvider.future);
        expect(state.fontSize, equals(12));
      });
    });

    group('toggleAutoRefresh', () {
      test('应该切换自动刷新', () async {
        // Arrange
        container = ProviderContainer();
        await container.read(settingsProvider.future);

        // Act
        await container.read(settingsProvider.notifier).toggleAutoRefresh();

        // Assert
        var state = await container.read(settingsProvider.future);
        expect(state.autoRefresh, isFalse);

        // Act again
        await container.read(settingsProvider.notifier).toggleAutoRefresh();

        // Assert
        state = await container.read(settingsProvider.future);
        expect(state.autoRefresh, isTrue);
      });
    });

    group('toggleShowOutline', () {
      test('应该切换显示大纲', () async {
        // Arrange
        container = ProviderContainer();
        await container.read(settingsProvider.future);

        // Act
        await container.read(settingsProvider.notifier).toggleShowOutline();

        // Assert
        var state = await container.read(settingsProvider.future);
        expect(state.showOutline, isFalse);

        // Act again
        await container.read(settingsProvider.notifier).toggleShowOutline();

        // Assert
        state = await container.read(settingsProvider.future);
        expect(state.showOutline, isTrue);
      });
    });

    group('resetToDefaults', () {
      test('应该重置所有设置为默认值', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'themeMode': 'dark',
          'fontSize': 20,
          'autoRefresh': false,
          'showOutline': false,
        });
        container = ProviderContainer();
        await container.read(settingsProvider.future);

        // Act
        await container.read(settingsProvider.notifier).resetToDefaults();

        // Assert
        final state = await container.read(settingsProvider.future);
        expect(state.themeMode, equals(ThemeMode.system));
        expect(state.fontSize, equals(16));
        expect(state.autoRefresh, isTrue);
        expect(state.showOutline, isTrue);
      });
    });
  });
}
