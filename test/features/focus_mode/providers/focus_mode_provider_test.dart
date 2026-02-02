import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/focus_mode/providers/focus_mode_provider.dart';

void main() {
  group('FocusModeState', () {
    group('构造函数', () {
      test('默认构造函数应该创建禁用状态', () {
        // Act
        const state = FocusModeState();

        // Assert
        expect(state.isEnabled, isFalse);
        expect(state.readingProgress, equals(0.0));
      });

      test('应该正确创建带数据的状态', () {
        // Act
        const state = FocusModeState(
          isEnabled: true,
          readingProgress: 0.5,
        );

        // Assert
        expect(state.isEnabled, isTrue);
        expect(state.readingProgress, equals(0.5));
      });
    });

    group('readingProgressPercent', () {
      test('应该正确计算百分比', () {
        // Assert
        expect(
          const FocusModeState(readingProgress: 0.0).readingProgressPercent,
          equals(0),
        );
        expect(
          const FocusModeState(readingProgress: 0.5).readingProgressPercent,
          equals(50),
        );
        expect(
          const FocusModeState(readingProgress: 1.0).readingProgressPercent,
          equals(100),
        );
        expect(
          const FocusModeState(readingProgress: 0.333).readingProgressPercent,
          equals(33),
        );
      });
    });

    group('copyWith', () {
      test('copyWith 应该正确复制并更新字段', () {
        // Arrange
        const original = FocusModeState(
          isEnabled: false,
          readingProgress: 0.3,
        );

        // Act
        final updated = original.copyWith(isEnabled: true);

        // Assert
        expect(updated.isEnabled, isTrue);
        expect(updated.readingProgress, equals(0.3));
      });

      test('copyWith 不传参数应该返回相同值', () {
        // Arrange
        const original = FocusModeState(
          isEnabled: true,
          readingProgress: 0.7,
        );

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied, equals(original));
      });

      test('copyWith 可以更新所有字段', () {
        // Arrange
        const original = FocusModeState();

        // Act
        final updated = original.copyWith(
          isEnabled: true,
          readingProgress: 0.9,
        );

        // Assert
        expect(updated.isEnabled, isTrue);
        expect(updated.readingProgress, equals(0.9));
      });
    });

    group('相等性', () {
      test('相同值的 FocusModeState 应该相等', () {
        // Arrange
        const state1 = FocusModeState(
          isEnabled: true,
          readingProgress: 0.5,
        );
        const state2 = FocusModeState(
          isEnabled: true,
          readingProgress: 0.5,
        );

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('不同 isEnabled 的 FocusModeState 应该不相等', () {
        // Arrange
        const state1 = FocusModeState(isEnabled: true);
        const state2 = FocusModeState(isEnabled: false);

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('不同 readingProgress 的 FocusModeState 应该不相等', () {
        // Arrange
        const state1 = FocusModeState(readingProgress: 0.3);
        const state2 = FocusModeState(readingProgress: 0.7);

        // Assert
        expect(state1, isNot(equals(state2)));
      });
    });

    group('toString', () {
      test('toString 应该包含所有信息', () {
        // Arrange
        const state = FocusModeState(
          isEnabled: true,
          readingProgress: 0.5,
        );

        // Act
        final str = state.toString();

        // Assert
        expect(str, contains('FocusModeState'));
        expect(str, contains('true'));
        expect(str, contains('0.5'));
      });
    });
  });

  group('FocusModeProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('初始状态', () {
      test('初始状态应该是禁用的', () {
        // Act
        final state = container.read(focusModeProvider);

        // Assert
        expect(state.isEnabled, isFalse);
        expect(state.readingProgress, equals(0.0));
      });
    });

    group('enterFocusMode', () {
      test('应该启用专注模式', () {
        // Act
        container.read(focusModeProvider.notifier).enterFocusMode();

        // Assert
        final state = container.read(focusModeProvider);
        expect(state.isEnabled, isTrue);
      });

      test('应该重置阅读进度', () {
        // Arrange
        container.read(focusModeProvider.notifier).updateProgress(0.5);

        // Act
        container.read(focusModeProvider.notifier).enterFocusMode();

        // Assert
        final state = container.read(focusModeProvider);
        expect(state.readingProgress, equals(0.0));
      });
    });

    group('exitFocusMode', () {
      test('应该禁用专注模式', () {
        // Arrange
        container.read(focusModeProvider.notifier).enterFocusMode();

        // Act
        container.read(focusModeProvider.notifier).exitFocusMode();

        // Assert
        final state = container.read(focusModeProvider);
        expect(state.isEnabled, isFalse);
      });

      test('应该重置阅读进度', () {
        // Arrange
        container.read(focusModeProvider.notifier).enterFocusMode();
        container.read(focusModeProvider.notifier).updateProgress(0.7);

        // Act
        container.read(focusModeProvider.notifier).exitFocusMode();

        // Assert
        final state = container.read(focusModeProvider);
        expect(state.readingProgress, equals(0.0));
      });
    });

    group('updateProgress', () {
      test('应该正确更新阅读进度', () {
        // Act
        container.read(focusModeProvider.notifier).updateProgress(0.5);

        // Assert
        final state = container.read(focusModeProvider);
        expect(state.readingProgress, equals(0.5));
      });

      test('应该限制进度在 0.0-1.0 之间', () {
        // Act - 小于 0
        container.read(focusModeProvider.notifier).updateProgress(-0.5);

        // Assert
        var state = container.read(focusModeProvider);
        expect(state.readingProgress, equals(0.0));

        // Act - 大于 1
        container.read(focusModeProvider.notifier).updateProgress(1.5);

        // Assert
        state = container.read(focusModeProvider);
        expect(state.readingProgress, equals(1.0));
      });

      test('边界值应该正确处理', () {
        // Act & Assert - 0.0
        container.read(focusModeProvider.notifier).updateProgress(0.0);
        expect(container.read(focusModeProvider).readingProgress, equals(0.0));

        // Act & Assert - 1.0
        container.read(focusModeProvider.notifier).updateProgress(1.0);
        expect(container.read(focusModeProvider).readingProgress, equals(1.0));
      });
    });

    group('resetProgress', () {
      test('应该重置阅读进度为 0', () {
        // Arrange
        container.read(focusModeProvider.notifier).updateProgress(0.8);

        // Act
        container.read(focusModeProvider.notifier).resetProgress();

        // Assert
        final state = container.read(focusModeProvider);
        expect(state.readingProgress, equals(0.0));
      });
    });

    group('toggleFocusMode', () {
      test('禁用时应该切换为启用', () {
        // Act
        container.read(focusModeProvider.notifier).toggleFocusMode();

        // Assert
        expect(container.read(focusModeProvider).isEnabled, isTrue);
      });

      test('启用时应该切换为禁用', () {
        // Arrange
        container.read(focusModeProvider.notifier).enterFocusMode();

        // Act
        container.read(focusModeProvider.notifier).toggleFocusMode();

        // Assert
        expect(container.read(focusModeProvider).isEnabled, isFalse);
      });
    });

    group('Provider 类型验证', () {
      test('focusModeProvider 应该是 StateNotifierProvider', () {
        expect(
          focusModeProvider,
          isA<StateNotifierProvider<FocusModeNotifier, FocusModeState>>(),
        );
      });
    });

    group('状态变化监听', () {
      test('应该能正确监听状态变化', () {
        // Arrange
        var changeCount = 0;
        container.listen<FocusModeState>(
          focusModeProvider,
          (previous, next) {
            changeCount++;
          },
        );

        // Act
        container.read(focusModeProvider.notifier).enterFocusMode();
        container.read(focusModeProvider.notifier).updateProgress(0.5);
        container.read(focusModeProvider.notifier).exitFocusMode();

        // Assert
        expect(changeCount, equals(3));
      });
    });
  });
}
