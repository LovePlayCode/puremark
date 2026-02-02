import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/search/models/search_state.dart';
import 'package:puremark/features/search/widgets/search_bar.dart';

void main() {
  group('SearchBarWidget', () {
    Widget buildTestWidget({
      SearchState searchState = const SearchState(),
      void Function(String)? onQueryChanged,
      VoidCallback? onNextMatch,
      VoidCallback? onPreviousMatch,
      VoidCallback? onClose,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SearchBarWidget(
              searchState: searchState,
              onQueryChanged: onQueryChanged,
              onNextMatch: onNextMatch,
              onPreviousMatch: onPreviousMatch,
              onClose: onClose,
            ),
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染搜索栏', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('searchBar')), findsOneWidget);
      });

      testWidgets('应该显示搜索图标', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byIcon(Icons.search), findsOneWidget);
      });

      testWidgets('应该显示搜索输入框', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('searchInput')), findsOneWidget);
      });

      testWidgets('应该显示关闭按钮', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('closeButton')), findsOneWidget);
      });

      testWidgets('输入框应该显示提示文字', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('搜索...'), findsOneWidget);
      });
    });

    group('圆角', () {
      testWidgets('搜索栏应该有 8px 圆角', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('searchBar')),
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.borderRadius, equals(BorderRadius.circular(8)));
      });
    });

    group('匹配计数', () {
      testWidgets('有查询词时应该显示匹配计数', (tester) async {
        // Arrange
        const state = SearchState(
          query: 'test',
          totalMatches: 12,
          currentMatch: 3,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(searchState: state));

        // Assert
        expect(find.text('3 of 12'), findsOneWidget);
        expect(find.byKey(const Key('matchCount')), findsOneWidget);
      });

      testWidgets('无匹配时应该显示 "无匹配"', (tester) async {
        // Arrange
        const state = SearchState(
          query: 'test',
          totalMatches: 0,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(searchState: state));

        // Assert
        expect(find.text('无匹配'), findsOneWidget);
      });

      testWidgets('无查询词时不应该显示匹配计数', (tester) async {
        // Arrange
        const state = SearchState(query: '');

        // Act
        await tester.pumpWidget(buildTestWidget(searchState: state));

        // Assert
        expect(find.byKey(const Key('matchCount')), findsNothing);
      });
    });

    group('导航按钮', () {
      testWidgets('有匹配时应该显示导航按钮', (tester) async {
        // Arrange
        const state = SearchState(
          query: 'test',
          totalMatches: 5,
          currentMatch: 2,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(searchState: state));

        // Assert
        expect(find.byKey(const Key('previousButton')), findsOneWidget);
        expect(find.byKey(const Key('nextButton')), findsOneWidget);
      });

      testWidgets('无匹配时不应该显示导航按钮', (tester) async {
        // Arrange
        const state = SearchState(
          query: 'test',
          totalMatches: 0,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(searchState: state));

        // Assert
        expect(find.byKey(const Key('previousButton')), findsNothing);
        expect(find.byKey(const Key('nextButton')), findsNothing);
      });

      testWidgets('点击下一个按钮应该触发 onNextMatch', (tester) async {
        // Arrange
        var nextCalled = false;
        const state = SearchState(
          query: 'test',
          totalMatches: 5,
          currentMatch: 2,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          searchState: state,
          onNextMatch: () => nextCalled = true,
        ));
        await tester.tap(find.byKey(const Key('nextButton')));
        await tester.pump();

        // Assert
        expect(nextCalled, isTrue);
      });

      testWidgets('点击上一个按钮应该触发 onPreviousMatch', (tester) async {
        // Arrange
        var previousCalled = false;
        const state = SearchState(
          query: 'test',
          totalMatches: 5,
          currentMatch: 2,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          searchState: state,
          onPreviousMatch: () => previousCalled = true,
        ));
        await tester.tap(find.byKey(const Key('previousButton')));
        await tester.pump();

        // Assert
        expect(previousCalled, isTrue);
      });
    });

    group('关闭按钮', () {
      testWidgets('点击关闭按钮应该触发 onClose', (tester) async {
        // Arrange
        var closeCalled = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onClose: () => closeCalled = true,
        ));
        await tester.tap(find.byKey(const Key('closeButton')));
        await tester.pump();

        // Assert
        expect(closeCalled, isTrue);
      });
    });

    group('输入', () {
      testWidgets('输入应该触发 onQueryChanged', (tester) async {
        // Arrange
        String? changedQuery;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onQueryChanged: (q) => changedQuery = q,
        ));
        await tester.enterText(find.byKey(const Key('searchInput')), 'flutter');
        await tester.pump();

        // Assert
        expect(changedQuery, equals('flutter'));
      });

      testWidgets('初始状态应该显示 searchState 的 query', (tester) async {
        // Arrange
        const state = SearchState(query: 'initial query');

        // Act
        await tester.pumpWidget(buildTestWidget(searchState: state));

        // Assert
        final textField = tester.widget<TextField>(
          find.byKey(const Key('searchInput')),
        );
        expect(textField.controller?.text, equals('initial query'));
      });

      testWidgets('searchState 更新时应该更新输入框', (tester) async {
        // Arrange
        const state1 = SearchState(query: 'first');
        const state2 = SearchState(query: 'second');

        // Act
        await tester.pumpWidget(buildTestWidget(searchState: state1));
        await tester.pumpWidget(buildTestWidget(searchState: state2));

        // Assert
        final textField = tester.widget<TextField>(
          find.byKey(const Key('searchInput')),
        );
        expect(textField.controller?.text, equals('second'));
      });
    });

    group('快捷键', () {
      testWidgets('Enter 应该触发 onNextMatch', (tester) async {
        // Arrange
        var nextCalled = false;
        const state = SearchState(
          query: 'test',
          totalMatches: 5,
          currentMatch: 2,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(
          searchState: state,
          onNextMatch: () => nextCalled = true,
        ));

        // 聚焦输入框并按 Enter
        await tester.tap(find.byKey(const Key('searchInput')));
        await tester.pump();
        await tester.testTextInput.receiveAction(TextInputAction.done);
        await tester.pump();

        // Assert
        expect(nextCalled, isTrue);
      });

      // 注意：Shift+Enter 和 Escape 快捷键测试较复杂，
      // 因为需要模拟硬件键盘事件，这里简化处理
    });

    group('主题适配', () {
      testWidgets('深色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));

        // Assert
        expect(find.byKey(const Key('searchBar')), findsOneWidget);
      });

      testWidgets('浅色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        // Assert
        expect(find.byKey(const Key('searchBar')), findsOneWidget);
      });
    });

    group('边界条件', () {
      testWidgets('所有回调都为 null 时应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(
          onQueryChanged: null,
          onNextMatch: null,
          onPreviousMatch: null,
          onClose: null,
        ));

        // Assert
        expect(find.byKey(const Key('searchBar')), findsOneWidget);
      });

      testWidgets('空查询词应该正确渲染', (tester) async {
        // Arrange
        const state = SearchState(query: '');

        // Act
        await tester.pumpWidget(buildTestWidget(searchState: state));

        // Assert
        expect(find.byKey(const Key('searchBar')), findsOneWidget);
        expect(find.byKey(const Key('matchCount')), findsNothing);
      });

      testWidgets('长查询词应该正确渲染', (tester) async {
        // Arrange
        const longQuery = 'this is a very long search query that might overflow';
        const state = SearchState(query: longQuery, totalMatches: 1, currentMatch: 1);

        // Act
        await tester.pumpWidget(buildTestWidget(searchState: state));

        // Assert
        expect(find.byKey(const Key('searchBar')), findsOneWidget);
      });

      testWidgets('大量匹配应该正确显示', (tester) async {
        // Arrange
        const state = SearchState(
          query: 'test',
          totalMatches: 99999,
          currentMatch: 12345,
        );

        // Act
        await tester.pumpWidget(buildTestWidget(searchState: state));

        // Assert
        expect(find.text('12345 of 99999'), findsOneWidget);
      });
    });

    group('自动聚焦', () {
      testWidgets('创建时应该自动聚焦输入框', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(); // 等待 postFrameCallback

        // Assert
        final textField = tester.widget<TextField>(
          find.byKey(const Key('searchInput')),
        );
        expect(textField.focusNode?.hasFocus, isTrue);
      });
    });
  });
}
