import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/search/models/search_state.dart';
import 'package:puremark/features/search/providers/search_provider.dart';

void main() {
  group('SearchState', () {
    group('构造函数', () {
      test('默认构造函数应该创建空状态', () {
        // Act
        const state = SearchState();

        // Assert
        expect(state.query, equals(''));
        expect(state.totalMatches, equals(0));
        expect(state.currentMatch, equals(0));
        expect(state.isVisible, isFalse);
      });

      test('factory empty 应该创建空状态', () {
        // Act
        final state = SearchState.empty();

        // Assert
        expect(state.query, equals(''));
        expect(state.totalMatches, equals(0));
        expect(state.currentMatch, equals(0));
        expect(state.isVisible, isFalse);
      });

      test('应该正确创建带数据的状态', () {
        // Act
        const state = SearchState(
          query: 'flutter',
          totalMatches: 12,
          currentMatch: 3,
          isVisible: true,
        );

        // Assert
        expect(state.query, equals('flutter'));
        expect(state.totalMatches, equals(12));
        expect(state.currentMatch, equals(3));
        expect(state.isVisible, isTrue);
      });
    });

    group('hasMatches', () {
      test('有匹配时应该返回 true', () {
        // Arrange
        const state = SearchState(totalMatches: 5, currentMatch: 1);

        // Assert
        expect(state.hasMatches, isTrue);
      });

      test('无匹配时应该返回 false', () {
        // Arrange
        const state = SearchState(totalMatches: 0);

        // Assert
        expect(state.hasMatches, isFalse);
      });
    });

    group('matchCountText', () {
      test('有匹配时应该返回 "X of Y" 格式', () {
        // Arrange
        const state = SearchState(totalMatches: 12, currentMatch: 3);

        // Assert
        expect(state.matchCountText, equals('3 of 12'));
      });

      test('无匹配时应该返回 "无匹配"', () {
        // Arrange
        const state = SearchState(totalMatches: 0);

        // Assert
        expect(state.matchCountText, equals('无匹配'));
      });

      test('单个匹配应该显示 "1 of 1"', () {
        // Arrange
        const state = SearchState(totalMatches: 1, currentMatch: 1);

        // Assert
        expect(state.matchCountText, equals('1 of 1'));
      });
    });

    group('copyWith', () {
      test('copyWith 应该正确复制并更新字段', () {
        // Arrange
        const original = SearchState(
          query: 'test',
          totalMatches: 10,
          currentMatch: 1,
          isVisible: true,
        );

        // Act
        final updated = original.copyWith(currentMatch: 5);

        // Assert
        expect(updated.query, equals('test'));
        expect(updated.totalMatches, equals(10));
        expect(updated.currentMatch, equals(5));
        expect(updated.isVisible, isTrue);
      });

      test('copyWith 不传参数应该返回相同值', () {
        // Arrange
        const original = SearchState(
          query: 'test',
          totalMatches: 5,
          currentMatch: 2,
          isVisible: true,
        );

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied, equals(original));
      });

      test('copyWith 可以更新所有字段', () {
        // Arrange
        const original = SearchState();

        // Act
        final updated = original.copyWith(
          query: 'new query',
          totalMatches: 20,
          currentMatch: 10,
          isVisible: true,
        );

        // Assert
        expect(updated.query, equals('new query'));
        expect(updated.totalMatches, equals(20));
        expect(updated.currentMatch, equals(10));
        expect(updated.isVisible, isTrue);
      });
    });

    group('相等性', () {
      test('相同值的 SearchState 应该相等', () {
        // Arrange
        const state1 = SearchState(
          query: 'test',
          totalMatches: 5,
          currentMatch: 2,
          isVisible: true,
        );
        const state2 = SearchState(
          query: 'test',
          totalMatches: 5,
          currentMatch: 2,
          isVisible: true,
        );

        // Assert
        expect(state1, equals(state2));
        expect(state1.hashCode, equals(state2.hashCode));
      });

      test('不同 query 的 SearchState 应该不相等', () {
        // Arrange
        const state1 = SearchState(query: 'test1');
        const state2 = SearchState(query: 'test2');

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('不同 totalMatches 的 SearchState 应该不相等', () {
        // Arrange
        const state1 = SearchState(totalMatches: 5);
        const state2 = SearchState(totalMatches: 10);

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('不同 currentMatch 的 SearchState 应该不相等', () {
        // Arrange
        const state1 = SearchState(currentMatch: 1);
        const state2 = SearchState(currentMatch: 2);

        // Assert
        expect(state1, isNot(equals(state2)));
      });

      test('不同 isVisible 的 SearchState 应该不相等', () {
        // Arrange
        const state1 = SearchState(isVisible: true);
        const state2 = SearchState(isVisible: false);

        // Assert
        expect(state1, isNot(equals(state2)));
      });
    });

    group('toString', () {
      test('toString 应该包含所有信息', () {
        // Arrange
        const state = SearchState(
          query: 'flutter',
          totalMatches: 10,
          currentMatch: 5,
          isVisible: true,
        );

        // Act
        final str = state.toString();

        // Assert
        expect(str, contains('SearchState'));
        expect(str, contains('flutter'));
        expect(str, contains('10'));
        expect(str, contains('5'));
        expect(str, contains('true'));
      });
    });
  });

  group('SearchProvider', () {
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
        final state = container.read(searchProvider);

        // Assert
        expect(state.query, equals(''));
        expect(state.totalMatches, equals(0));
        expect(state.currentMatch, equals(0));
        expect(state.isVisible, isFalse);
      });
    });

    group('setQuery', () {
      test('setQuery 应该正确设置查询词', () {
        // Act
        container.read(searchProvider.notifier).setQuery('flutter');

        // Assert
        final state = container.read(searchProvider);
        expect(state.query, equals('flutter'));
      });

      test('setQuery 应该清除匹配状态', () {
        // Arrange
        container.read(searchProvider.notifier).setMatches(10);

        // Act
        container.read(searchProvider.notifier).setQuery('new query');

        // Assert
        final state = container.read(searchProvider);
        expect(state.totalMatches, equals(0));
        expect(state.currentMatch, equals(0));
      });

      test('setQuery 可以设置空字符串', () {
        // Arrange
        container.read(searchProvider.notifier).setQuery('test');

        // Act
        container.read(searchProvider.notifier).setQuery('');

        // Assert
        final state = container.read(searchProvider);
        expect(state.query, equals(''));
      });
    });

    group('setMatches', () {
      test('setMatches 应该正确设置匹配数', () {
        // Act
        container.read(searchProvider.notifier).setMatches(15);

        // Assert
        final state = container.read(searchProvider);
        expect(state.totalMatches, equals(15));
        expect(state.currentMatch, equals(1)); // 默认第一个
      });

      test('setMatches 可以指定当前匹配位置', () {
        // Act
        container.read(searchProvider.notifier).setMatches(15, currentMatch: 5);

        // Assert
        final state = container.read(searchProvider);
        expect(state.totalMatches, equals(15));
        expect(state.currentMatch, equals(5));
      });

      test('setMatches 0 时 currentMatch 应该是 0', () {
        // Act
        container.read(searchProvider.notifier).setMatches(0);

        // Assert
        final state = container.read(searchProvider);
        expect(state.totalMatches, equals(0));
        expect(state.currentMatch, equals(0));
      });
    });

    group('nextMatch', () {
      test('nextMatch 应该前进到下一个匹配', () {
        // Arrange
        container.read(searchProvider.notifier).setMatches(10);
        expect(container.read(searchProvider).currentMatch, equals(1));

        // Act
        container.read(searchProvider.notifier).nextMatch();

        // Assert
        expect(container.read(searchProvider).currentMatch, equals(2));
      });

      test('nextMatch 在最后一个时应该循环到第一个', () {
        // Arrange
        container.read(searchProvider.notifier).setMatches(5, currentMatch: 5);

        // Act
        container.read(searchProvider.notifier).nextMatch();

        // Assert
        expect(container.read(searchProvider).currentMatch, equals(1));
      });

      test('nextMatch 在无匹配时应该无操作', () {
        // Arrange
        container.read(searchProvider.notifier).setMatches(0);

        // Act
        container.read(searchProvider.notifier).nextMatch();

        // Assert
        expect(container.read(searchProvider).currentMatch, equals(0));
      });

      test('nextMatch 连续调用应该正确递增', () {
        // Arrange
        container.read(searchProvider.notifier).setMatches(3);

        // Act & Assert
        container.read(searchProvider.notifier).nextMatch();
        expect(container.read(searchProvider).currentMatch, equals(2));

        container.read(searchProvider.notifier).nextMatch();
        expect(container.read(searchProvider).currentMatch, equals(3));

        container.read(searchProvider.notifier).nextMatch();
        expect(container.read(searchProvider).currentMatch, equals(1)); // 循环
      });
    });

    group('previousMatch', () {
      test('previousMatch 应该后退到上一个匹配', () {
        // Arrange
        container.read(searchProvider.notifier).setMatches(10, currentMatch: 5);

        // Act
        container.read(searchProvider.notifier).previousMatch();

        // Assert
        expect(container.read(searchProvider).currentMatch, equals(4));
      });

      test('previousMatch 在第一个时应该循环到最后一个', () {
        // Arrange
        container.read(searchProvider.notifier).setMatches(5, currentMatch: 1);

        // Act
        container.read(searchProvider.notifier).previousMatch();

        // Assert
        expect(container.read(searchProvider).currentMatch, equals(5));
      });

      test('previousMatch 在无匹配时应该无操作', () {
        // Arrange
        container.read(searchProvider.notifier).setMatches(0);

        // Act
        container.read(searchProvider.notifier).previousMatch();

        // Assert
        expect(container.read(searchProvider).currentMatch, equals(0));
      });

      test('previousMatch 连续调用应该正确递减', () {
        // Arrange
        container.read(searchProvider.notifier).setMatches(3, currentMatch: 3);

        // Act & Assert
        container.read(searchProvider.notifier).previousMatch();
        expect(container.read(searchProvider).currentMatch, equals(2));

        container.read(searchProvider.notifier).previousMatch();
        expect(container.read(searchProvider).currentMatch, equals(1));

        container.read(searchProvider.notifier).previousMatch();
        expect(container.read(searchProvider).currentMatch, equals(3)); // 循环
      });
    });

    group('clearSearch', () {
      test('clearSearch 应该重置所有状态', () {
        // Arrange
        container.read(searchProvider.notifier).setQuery('test');
        container.read(searchProvider.notifier).setMatches(10, currentMatch: 5);
        container.read(searchProvider.notifier).show();

        // Act
        container.read(searchProvider.notifier).clearSearch();

        // Assert
        final state = container.read(searchProvider);
        expect(state.query, equals(''));
        expect(state.totalMatches, equals(0));
        expect(state.currentMatch, equals(0));
        expect(state.isVisible, isFalse);
      });
    });

    group('toggleVisibility', () {
      test('toggleVisibility 应该切换可见性', () {
        // Arrange
        expect(container.read(searchProvider).isVisible, isFalse);

        // Act
        container.read(searchProvider.notifier).toggleVisibility();

        // Assert
        expect(container.read(searchProvider).isVisible, isTrue);

        // Act again
        container.read(searchProvider.notifier).toggleVisibility();

        // Assert
        expect(container.read(searchProvider).isVisible, isFalse);
      });
    });

    group('show', () {
      test('show 应该设置 isVisible 为 true', () {
        // Act
        container.read(searchProvider.notifier).show();

        // Assert
        expect(container.read(searchProvider).isVisible, isTrue);
      });

      test('show 多次调用应该保持 true', () {
        // Act
        container.read(searchProvider.notifier).show();
        container.read(searchProvider.notifier).show();

        // Assert
        expect(container.read(searchProvider).isVisible, isTrue);
      });
    });

    group('hide', () {
      test('hide 应该设置 isVisible 为 false', () {
        // Arrange
        container.read(searchProvider.notifier).show();

        // Act
        container.read(searchProvider.notifier).hide();

        // Assert
        expect(container.read(searchProvider).isVisible, isFalse);
      });

      test('hide 多次调用应该保持 false', () {
        // Act
        container.read(searchProvider.notifier).hide();
        container.read(searchProvider.notifier).hide();

        // Assert
        expect(container.read(searchProvider).isVisible, isFalse);
      });
    });

    group('Provider 类型验证', () {
      test('searchProvider 应该是 StateNotifierProvider', () {
        expect(
          searchProvider,
          isA<StateNotifierProvider<SearchNotifier, SearchState>>(),
        );
      });
    });

    group('状态变化监听', () {
      test('应该能正确监听状态变化', () {
        // Arrange
        var changeCount = 0;
        container.listen<SearchState>(
          searchProvider,
          (previous, next) {
            changeCount++;
          },
        );

        // Act
        container.read(searchProvider.notifier).setQuery('test');
        container.read(searchProvider.notifier).setMatches(5);
        container.read(searchProvider.notifier).nextMatch();
        container.read(searchProvider.notifier).toggleVisibility();
        container.read(searchProvider.notifier).clearSearch();

        // Assert
        expect(changeCount, equals(5));
      });
    });

    group('边界条件', () {
      test('单个匹配时 nextMatch 应该保持在 1', () {
        // Arrange
        container.read(searchProvider.notifier).setMatches(1);

        // Act
        container.read(searchProvider.notifier).nextMatch();

        // Assert
        expect(container.read(searchProvider).currentMatch, equals(1));
      });

      test('单个匹配时 previousMatch 应该保持在 1', () {
        // Arrange
        container.read(searchProvider.notifier).setMatches(1);

        // Act
        container.read(searchProvider.notifier).previousMatch();

        // Assert
        expect(container.read(searchProvider).currentMatch, equals(1));
      });
    });
  });
}
