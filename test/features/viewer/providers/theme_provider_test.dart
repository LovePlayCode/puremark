import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/viewer/providers/theme_provider.dart';

void main() {
  group('ThemeModeProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('初始状态', () {
      test('初始主题模式应该是 dark', () {
        // Act
        final themeMode = container.read(themeModeProvider);

        // Assert
        expect(themeMode, equals(ThemeMode.dark));
      });
    });

    group('读取主题模式', () {
      test('应该能正确读取当前主题模式', () {
        // Act
        final themeMode = container.read(themeModeProvider);

        // Assert
        expect(themeMode, isA<ThemeMode>());
      });

      test('使用 notifier 读取状态应该与直接读取一致', () {
        // Act
        final themeMode = container.read(themeModeProvider);
        final themeModeFromNotifier =
            container.read(themeModeProvider.notifier).state;

        // Assert
        expect(themeMode, equals(themeModeFromNotifier));
      });
    });

    group('切换到 light 模式', () {
      test('应该能成功切换到 light 模式', () {
        // Act
        container.read(themeModeProvider.notifier).state = ThemeMode.light;

        // Assert
        expect(
          container.read(themeModeProvider),
          equals(ThemeMode.light),
        );
      });

      test('切换到 light 后状态应该保持', () {
        // Arrange
        container.read(themeModeProvider.notifier).state = ThemeMode.light;

        // Act - 多次读取
        final firstRead = container.read(themeModeProvider);
        final secondRead = container.read(themeModeProvider);

        // Assert
        expect(firstRead, equals(ThemeMode.light));
        expect(secondRead, equals(ThemeMode.light));
      });
    });

    group('切换到 dark 模式', () {
      test('从 light 切换回 dark 应该成功', () {
        // Arrange
        container.read(themeModeProvider.notifier).state = ThemeMode.light;

        // Act
        container.read(themeModeProvider.notifier).state = ThemeMode.dark;

        // Assert
        expect(
          container.read(themeModeProvider),
          equals(ThemeMode.dark),
        );
      });

      test('默认就是 dark，再次设置应该保持', () {
        // Act
        container.read(themeModeProvider.notifier).state = ThemeMode.dark;

        // Assert
        expect(
          container.read(themeModeProvider),
          equals(ThemeMode.dark),
        );
      });
    });

    group('切换到 system 模式', () {
      test('应该能成功切换到 system 模式', () {
        // Act
        container.read(themeModeProvider.notifier).state = ThemeMode.system;

        // Assert
        expect(
          container.read(themeModeProvider),
          equals(ThemeMode.system),
        );
      });

      test('从 system 切换到其他模式应该成功', () {
        // Arrange
        container.read(themeModeProvider.notifier).state = ThemeMode.system;

        // Act
        container.read(themeModeProvider.notifier).state = ThemeMode.light;

        // Assert
        expect(
          container.read(themeModeProvider),
          equals(ThemeMode.light),
        );
      });
    });

    group('连续切换', () {
      test('应该支持多次连续切换', () {
        // Act & Assert
        container.read(themeModeProvider.notifier).state = ThemeMode.light;
        expect(container.read(themeModeProvider), equals(ThemeMode.light));

        container.read(themeModeProvider.notifier).state = ThemeMode.dark;
        expect(container.read(themeModeProvider), equals(ThemeMode.dark));

        container.read(themeModeProvider.notifier).state = ThemeMode.system;
        expect(container.read(themeModeProvider), equals(ThemeMode.system));

        container.read(themeModeProvider.notifier).state = ThemeMode.light;
        expect(container.read(themeModeProvider), equals(ThemeMode.light));
      });

      test('快速切换不应该丢失状态', () {
        // Act
        for (var i = 0; i < 10; i++) {
          container.read(themeModeProvider.notifier).state = ThemeMode.light;
          container.read(themeModeProvider.notifier).state = ThemeMode.dark;
        }
        container.read(themeModeProvider.notifier).state = ThemeMode.system;

        // Assert
        expect(
          container.read(themeModeProvider),
          equals(ThemeMode.system),
        );
      });
    });

    group('独立容器', () {
      test('不同容器应该有独立的状态', () {
        // Arrange
        final container1 = ProviderContainer();
        final container2 = ProviderContainer();
        addTearDown(container1.dispose);
        addTearDown(container2.dispose);

        // Act
        container1.read(themeModeProvider.notifier).state = ThemeMode.light;
        container2.read(themeModeProvider.notifier).state = ThemeMode.system;

        // Assert
        expect(container1.read(themeModeProvider), equals(ThemeMode.light));
        expect(container2.read(themeModeProvider), equals(ThemeMode.system));
      });
    });

    group('Provider 类型验证', () {
      test('themeModeProvider 应该是 StateProvider<ThemeMode>', () {
        // Assert
        expect(themeModeProvider, isA<StateProvider<ThemeMode>>());
      });

      test('notifier 应该是 StateController<ThemeMode>', () {
        // Act
        final notifier = container.read(themeModeProvider.notifier);

        // Assert
        expect(notifier, isA<StateController<ThemeMode>>());
      });
    });

    group('边界条件', () {
      test('设置相同的值应该不报错', () {
        // Arrange
        final initialValue = container.read(themeModeProvider);

        // Act
        container.read(themeModeProvider.notifier).state = initialValue;

        // Assert
        expect(
          container.read(themeModeProvider),
          equals(initialValue),
        );
      });

      test('dispose 后不应该访问 provider', () {
        // Arrange
        final localContainer = ProviderContainer();

        // Act
        localContainer.dispose();

        // Assert - 访问已 dispose 的容器应该抛出异常
        expect(
          () => localContainer.read(themeModeProvider),
          throwsStateError,
        );
      });
    });
  });
}
