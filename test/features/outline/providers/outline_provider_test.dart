import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/outline/models/heading.dart';
import 'package:puremark/features/outline/providers/outline_provider.dart';

void main() {
  group('Heading', () {
    group('构造函数', () {
      test('应该正确创建 Heading 实例', () {
        // Arrange & Act
        const heading = Heading(
          id: 'heading-1',
          text: '简介',
          level: 1,
        );

        // Assert
        expect(heading.id, equals('heading-1'));
        expect(heading.text, equals('简介'));
        expect(heading.level, equals(1));
      });
    });

    group('indent', () {
      test('H1 级别应该返回 0 缩进', () {
        // Arrange
        const heading = Heading(id: '1', text: 'H1', level: 1);

        // Assert
        expect(heading.indent, equals(0));
      });

      test('H2 级别应该返回 16px 缩进', () {
        // Arrange
        const heading = Heading(id: '2', text: 'H2', level: 2);

        // Assert
        expect(heading.indent, equals(16));
      });

      test('H3 级别应该返回 32px 缩进', () {
        // Arrange
        const heading = Heading(id: '3', text: 'H3', level: 3);

        // Assert
        expect(heading.indent, equals(32));
      });

      test('未知级别应该返回 0 缩进', () {
        // Arrange
        const heading = Heading(id: '4', text: 'H4', level: 4);

        // Assert
        expect(heading.indent, equals(0));
      });
    });

    group('copyWith', () {
      test('copyWith 应该正确复制并更新字段', () {
        // Arrange
        const original = Heading(id: '1', text: 'Original', level: 1);

        // Act
        final updated = original.copyWith(text: 'Updated');

        // Assert
        expect(updated.id, equals('1'));
        expect(updated.text, equals('Updated'));
        expect(updated.level, equals(1));
      });

      test('copyWith 不传参数应该返回相同值', () {
        // Arrange
        const original = Heading(id: '1', text: 'Test', level: 2);

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied, equals(original));
      });

      test('copyWith 可以更新所有字段', () {
        // Arrange
        const original = Heading(id: '1', text: 'Old', level: 1);

        // Act
        final updated = original.copyWith(
          id: '2',
          text: 'New',
          level: 3,
        );

        // Assert
        expect(updated.id, equals('2'));
        expect(updated.text, equals('New'));
        expect(updated.level, equals(3));
      });
    });

    group('相等性', () {
      test('相同值的 Heading 应该相等', () {
        // Arrange
        const heading1 = Heading(id: '1', text: 'Test', level: 1);
        const heading2 = Heading(id: '1', text: 'Test', level: 1);

        // Assert
        expect(heading1, equals(heading2));
        expect(heading1.hashCode, equals(heading2.hashCode));
      });

      test('不同值的 Heading 应该不相等', () {
        // Arrange
        const heading1 = Heading(id: '1', text: 'Test', level: 1);
        const heading2 = Heading(id: '2', text: 'Test', level: 1);

        // Assert
        expect(heading1, isNot(equals(heading2)));
      });

      test('不同文本的 Heading 应该不相等', () {
        // Arrange
        const heading1 = Heading(id: '1', text: 'Test1', level: 1);
        const heading2 = Heading(id: '1', text: 'Test2', level: 1);

        // Assert
        expect(heading1, isNot(equals(heading2)));
      });

      test('不同级别的 Heading 应该不相等', () {
        // Arrange
        const heading1 = Heading(id: '1', text: 'Test', level: 1);
        const heading2 = Heading(id: '1', text: 'Test', level: 2);

        // Assert
        expect(heading1, isNot(equals(heading2)));
      });
    });

    group('toString', () {
      test('toString 应该包含所有信息', () {
        // Arrange
        const heading = Heading(id: '1', text: '简介', level: 1);

        // Act
        final str = heading.toString();

        // Assert
        expect(str, contains('Heading'));
        expect(str, contains('1'));
        expect(str, contains('简介'));
      });
    });
  });

  group('OutlineState', () {
    group('构造函数', () {
      test('默认构造函数应该创建空状态', () {
        // Act
        const state = OutlineState();

        // Assert
        expect(state.headings, isEmpty);
        expect(state.activeHeadingId, isNull);
      });

      test('factory empty 应该创建空状态', () {
        // Act
        final state = OutlineState.empty();

        // Assert
        expect(state.headings, isEmpty);
        expect(state.activeHeadingId, isNull);
      });

      test('应该正确创建带数据的状态', () {
        // Arrange
        const headings = [
          Heading(id: '1', text: 'H1', level: 1),
          Heading(id: '2', text: 'H2', level: 2),
        ];

        // Act
        const state = OutlineState(
          headings: headings,
          activeHeadingId: '1',
        );

        // Assert
        expect(state.headings.length, equals(2));
        expect(state.activeHeadingId, equals('1'));
      });
    });

    group('copyWith', () {
      test('copyWith 应该正确更新 headings', () {
        // Arrange
        final original = OutlineState.empty();
        const newHeadings = [Heading(id: '1', text: 'New', level: 1)];

        // Act
        final updated = original.copyWith(headings: newHeadings);

        // Assert
        expect(updated.headings.length, equals(1));
        expect(updated.headings[0].text, equals('New'));
      });

      test('copyWith 应该正确更新 activeHeadingId', () {
        // Arrange
        final original = OutlineState.empty();

        // Act
        final updated = original.copyWith(activeHeadingId: 'active-1');

        // Assert
        expect(updated.activeHeadingId, equals('active-1'));
      });

      test('copyWith clearActiveHeading 应该清除活动状态', () {
        // Arrange
        const original = OutlineState(activeHeadingId: 'active-1');

        // Act
        final updated = original.copyWith(clearActiveHeading: true);

        // Assert
        expect(updated.activeHeadingId, isNull);
      });
    });

    group('相等性', () {
      test('相同值的 OutlineState 应该相等', () {
        // Arrange
        const headings = [Heading(id: '1', text: 'Test', level: 1)];
        const state1 = OutlineState(headings: headings, activeHeadingId: '1');
        const state2 = OutlineState(headings: headings, activeHeadingId: '1');

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('不同 headings 长度的 OutlineState 应该不相等', () {
        // Arrange
        const state1 = OutlineState(
          headings: [Heading(id: '1', text: 'Test', level: 1)],
        );
        const state2 = OutlineState(headings: []);

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('不同 activeHeadingId 的 OutlineState 应该不相等', () {
        // Arrange
        const state1 = OutlineState(activeHeadingId: '1');
        const state2 = OutlineState(activeHeadingId: '2');

        // Assert
        expect(state1, isNot(equals(state2)));
      });
    });

    group('toString', () {
      test('toString 应该包含状态信息', () {
        // Arrange
        const headings = [Heading(id: '1', text: 'Test', level: 1)];
        const state = OutlineState(headings: headings, activeHeadingId: '1');

        // Act
        final str = state.toString();

        // Assert
        expect(str, contains('OutlineState'));
        expect(str, contains('1 items'));
        expect(str, contains('1'));
      });
    });
  });

  group('OutlineProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('初始状态', () {
      test('初始状态应该是空的', () {
        // Act
        final state = container.read(outlineProvider);

        // Assert
        expect(state.headings, isEmpty);
        expect(state.activeHeadingId, isNull);
      });
    });

    group('setHeadings', () {
      test('setHeadings 应该正确设置标题列表', () {
        // Arrange
        const headings = [
          Heading(id: '1', text: '第一章', level: 1),
          Heading(id: '2', text: '1.1 节', level: 2),
          Heading(id: '3', text: '1.1.1 小节', level: 3),
        ];

        // Act
        container.read(outlineProvider.notifier).setHeadings(headings);

        // Assert
        final state = container.read(outlineProvider);
        expect(state.headings.length, equals(3));
        expect(state.headings[0].text, equals('第一章'));
        expect(state.headings[1].text, equals('1.1 节'));
        expect(state.headings[2].text, equals('1.1.1 小节'));
      });

      test('setHeadings 应该保留 activeHeadingId', () {
        // Arrange
        const headings = [Heading(id: '1', text: 'Test', level: 1)];
        container.read(outlineProvider.notifier).setHeadings(headings);
        container.read(outlineProvider.notifier).setActiveHeading('1');

        // Act
        const newHeadings = [
          Heading(id: '1', text: 'Test', level: 1),
          Heading(id: '2', text: 'New', level: 2),
        ];
        container.read(outlineProvider.notifier).setHeadings(newHeadings);

        // Assert
        final state = container.read(outlineProvider);
        expect(state.activeHeadingId, equals('1'));
      });

      test('setHeadings 可以设置空列表', () {
        // Arrange
        const headings = [Heading(id: '1', text: 'Test', level: 1)];
        container.read(outlineProvider.notifier).setHeadings(headings);

        // Act
        container.read(outlineProvider.notifier).setHeadings([]);

        // Assert
        final state = container.read(outlineProvider);
        expect(state.headings, isEmpty);
      });
    });

    group('setActiveHeading', () {
      test('setActiveHeading 应该正确设置活动标题', () {
        // Arrange
        const headings = [
          Heading(id: '1', text: 'H1', level: 1),
          Heading(id: '2', text: 'H2', level: 2),
        ];
        container.read(outlineProvider.notifier).setHeadings(headings);

        // Act
        container.read(outlineProvider.notifier).setActiveHeading('2');

        // Assert
        final state = container.read(outlineProvider);
        expect(state.activeHeadingId, equals('2'));
      });

      test('setActiveHeading null 应该清除活动状态', () {
        // Arrange
        container.read(outlineProvider.notifier).setActiveHeading('1');

        // Act
        container.read(outlineProvider.notifier).setActiveHeading(null);

        // Assert
        final state = container.read(outlineProvider);
        expect(state.activeHeadingId, isNull);
      });

      test('setActiveHeading 可以切换活动标题', () {
        // Arrange
        const headings = [
          Heading(id: '1', text: 'H1', level: 1),
          Heading(id: '2', text: 'H2', level: 2),
        ];
        container.read(outlineProvider.notifier).setHeadings(headings);
        container.read(outlineProvider.notifier).setActiveHeading('1');

        // Act
        container.read(outlineProvider.notifier).setActiveHeading('2');

        // Assert
        final state = container.read(outlineProvider);
        expect(state.activeHeadingId, equals('2'));
      });
    });

    group('clearHeadings', () {
      test('clearHeadings 应该清除所有状态', () {
        // Arrange
        const headings = [
          Heading(id: '1', text: 'H1', level: 1),
          Heading(id: '2', text: 'H2', level: 2),
        ];
        container.read(outlineProvider.notifier).setHeadings(headings);
        container.read(outlineProvider.notifier).setActiveHeading('1');

        // Act
        container.read(outlineProvider.notifier).clearHeadings();

        // Assert
        final state = container.read(outlineProvider);
        expect(state.headings, isEmpty);
        expect(state.activeHeadingId, isNull);
      });

      test('clearHeadings 在空状态下调用应该安全', () {
        // Act
        container.read(outlineProvider.notifier).clearHeadings();

        // Assert
        final state = container.read(outlineProvider);
        expect(state.headings, isEmpty);
        expect(state.activeHeadingId, isNull);
      });
    });

    group('Provider 类型验证', () {
      test('outlineProvider 应该是 StateNotifierProvider', () {
        expect(
          outlineProvider,
          isA<StateNotifierProvider<OutlineNotifier, OutlineState>>(),
        );
      });
    });

    group('状态变化监听', () {
      test('应该能正确监听状态变化', () {
        // Arrange
        var changeCount = 0;
        container.listen<OutlineState>(
          outlineProvider,
          (previous, next) {
            changeCount++;
          },
        );

        // Act
        container.read(outlineProvider.notifier).setHeadings([
          const Heading(id: '1', text: 'Test', level: 1),
        ]);
        container.read(outlineProvider.notifier).setActiveHeading('1');
        container.read(outlineProvider.notifier).clearHeadings();

        // Assert
        expect(changeCount, equals(3));
      });
    });
  });
}
