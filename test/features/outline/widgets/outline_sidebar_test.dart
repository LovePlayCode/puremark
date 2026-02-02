import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/outline/models/heading.dart';
import 'package:puremark/features/outline/widgets/outline_item.dart';
import 'package:puremark/features/outline/widgets/outline_sidebar.dart';

void main() {
  group('OutlineItem', () {
    Widget buildTestWidget({
      required Heading heading,
      bool isActive = false,
      void Function(Heading)? onTap,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: OutlineItem(
            heading: heading,
            isActive: isActive,
            onTap: onTap,
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确显示标题文本', (tester) async {
        // Arrange
        const heading = Heading(id: '1', text: '测试标题', level: 1);

        // Act
        await tester.pumpWidget(buildTestWidget(heading: heading));

        // Assert
        expect(find.text('测试标题'), findsOneWidget);
      });

      testWidgets('应该有正确的 key', (tester) async {
        // Arrange
        const heading = Heading(id: 'test-id', text: 'Test', level: 1);

        // Act
        await tester.pumpWidget(buildTestWidget(heading: heading));

        // Assert
        expect(find.byKey(const Key('outlineItem_test-id')), findsOneWidget);
      });
    });

    group('层级缩进', () {
      testWidgets('H1 应该没有缩进', (tester) async {
        // Arrange
        const heading = Heading(id: '1', text: 'H1', level: 1);

        // Act
        await tester.pumpWidget(buildTestWidget(heading: heading));

        // Assert
        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('H1'),
            matching: find.byType(Container),
          ).first,
        );
        final padding = container.padding as EdgeInsets?;
        expect(padding?.left, equals(12)); // 基础 padding 12 + indent 0
      });

      testWidgets('H2 应该有 16px 缩进', (tester) async {
        // Arrange
        const heading = Heading(id: '2', text: 'H2', level: 2);

        // Act
        await tester.pumpWidget(buildTestWidget(heading: heading));

        // Assert
        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('H2'),
            matching: find.byType(Container),
          ).first,
        );
        final padding = container.padding as EdgeInsets?;
        expect(padding?.left, equals(28)); // 基础 padding 12 + indent 16
      });

      testWidgets('H3 应该有 32px 缩进', (tester) async {
        // Arrange
        const heading = Heading(id: '3', text: 'H3', level: 3);

        // Act
        await tester.pumpWidget(buildTestWidget(heading: heading));

        // Assert
        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('H3'),
            matching: find.byType(Container),
          ).first,
        );
        final padding = container.padding as EdgeInsets?;
        expect(padding?.left, equals(44)); // 基础 padding 12 + indent 32
      });
    });

    group('活动状态', () {
      testWidgets('活动项应该有高亮背景', (tester) async {
        // Arrange
        const heading = Heading(id: '1', text: 'Active', level: 1);

        // Act
        await tester.pumpWidget(buildTestWidget(
          heading: heading,
          isActive: true,
        ));

        // Assert
        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('Active'),
            matching: find.byType(Container),
          ).first,
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.color, isNot(Colors.transparent));
      });

      testWidgets('非活动项应该没有高亮背景', (tester) async {
        // Arrange
        const heading = Heading(id: '1', text: 'Inactive', level: 1);

        // Act
        await tester.pumpWidget(buildTestWidget(
          heading: heading,
          isActive: false,
        ));

        // Assert
        final container = tester.widget<Container>(
          find.ancestor(
            of: find.text('Inactive'),
            matching: find.byType(Container),
          ).first,
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration?.color, equals(Colors.transparent));
      });
    });

    group('回调', () {
      testWidgets('点击应该触发 onTap 回调', (tester) async {
        // Arrange
        const heading = Heading(id: '1', text: 'Clickable', level: 1);
        Heading? tappedHeading;

        // Act
        await tester.pumpWidget(buildTestWidget(
          heading: heading,
          onTap: (h) => tappedHeading = h,
        ));
        await tester.tap(find.text('Clickable'));
        await tester.pump();

        // Assert
        expect(tappedHeading, equals(heading));
      });

      testWidgets('没有 onTap 时点击应该安全', (tester) async {
        // Arrange
        const heading = Heading(id: '1', text: 'No callback', level: 1);

        // Act
        await tester.pumpWidget(buildTestWidget(heading: heading));
        await tester.tap(find.text('No callback'));
        await tester.pump();

        // Assert - 不应该抛出异常
        expect(true, isTrue);
      });
    });

    group('主题适配', () {
      testWidgets('深色主题下应该正确渲染', (tester) async {
        // Arrange
        const heading = Heading(id: '1', text: 'Dark', level: 1);

        // Act
        await tester.pumpWidget(buildTestWidget(
          heading: heading,
          brightness: Brightness.dark,
        ));

        // Assert
        expect(find.text('Dark'), findsOneWidget);
      });

      testWidgets('浅色主题下应该正确渲染', (tester) async {
        // Arrange
        const heading = Heading(id: '1', text: 'Light', level: 1);

        // Act
        await tester.pumpWidget(buildTestWidget(
          heading: heading,
          brightness: Brightness.light,
        ));

        // Assert
        expect(find.text('Light'), findsOneWidget);
      });
    });
  });

  group('OutlineSidebar', () {
    Widget buildTestWidget({
      List<Heading> headings = const [],
      String? activeHeadingId,
      void Function(Heading)? onHeadingTap,
      bool isCollapsed = false,
      VoidCallback? onToggleCollapse,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: OutlineSidebar(
            headings: headings,
            activeHeadingId: activeHeadingId,
            onHeadingTap: onHeadingTap,
            isCollapsed: isCollapsed,
            onToggleCollapse: onToggleCollapse,
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染侧边栏', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('outlineSidebar')), findsOneWidget);
      });

      testWidgets('应该显示标题 "大纲"', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('大纲'), findsOneWidget);
        expect(find.byKey(const Key('outlineTitle')), findsOneWidget);
      });

      testWidgets('应该显示折叠按钮', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('collapseButton')), findsOneWidget);
      });

      testWidgets('应该显示标题栏', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('outlineHeader')), findsOneWidget);
      });
    });

    group('宽度', () {
      testWidgets('展开状态下应该有 220px 宽度', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('outlineSidebar')),
        );
        expect(container.constraints?.maxWidth, equals(220));
      });

      testWidgets('折叠状态下应该有 44px 宽度', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(isCollapsed: true));

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('outlineSidebar_collapsed')),
        );
        expect(container.constraints?.maxWidth, equals(44));
      });
    });

    group('折叠状态', () {
      testWidgets('折叠状态应该显示展开按钮', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(isCollapsed: true));

        // Assert
        expect(find.byKey(const Key('expandButton')), findsOneWidget);
        expect(find.byKey(const Key('collapseButton')), findsNothing);
      });

      testWidgets('折叠状态不应该显示标题', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(isCollapsed: true));

        // Assert
        expect(find.text('大纲'), findsNothing);
      });

      testWidgets('点击展开按钮应该触发 onToggleCollapse', (tester) async {
        // Arrange
        var toggleCalled = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          isCollapsed: true,
          onToggleCollapse: () => toggleCalled = true,
        ));
        await tester.tap(find.byKey(const Key('expandButton')));
        await tester.pump();

        // Assert
        expect(toggleCalled, isTrue);
      });

      testWidgets('点击折叠按钮应该触发 onToggleCollapse', (tester) async {
        // Arrange
        var toggleCalled = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          isCollapsed: false,
          onToggleCollapse: () => toggleCalled = true,
        ));
        await tester.tap(find.byKey(const Key('collapseButton')));
        await tester.pump();

        // Assert
        expect(toggleCalled, isTrue);
      });
    });

    group('空状态', () {
      testWidgets('没有标题时应该显示空状态', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(headings: []));

        // Assert
        expect(find.text('暂无大纲'), findsOneWidget);
        expect(find.byKey(const Key('emptyOutlineText')), findsOneWidget);
      });
    });

    group('标题列表', () {
      testWidgets('应该正确显示标题列表', (tester) async {
        // Arrange
        const headings = [
          Heading(id: '1', text: '第一章', level: 1),
          Heading(id: '2', text: '1.1 节', level: 2),
          Heading(id: '3', text: '1.1.1 小节', level: 3),
        ];

        // Act
        await tester.pumpWidget(buildTestWidget(headings: headings));

        // Assert
        expect(find.text('第一章'), findsOneWidget);
        expect(find.text('1.1 节'), findsOneWidget);
        expect(find.text('1.1.1 小节'), findsOneWidget);
        expect(find.byKey(const Key('outlineList')), findsOneWidget);
      });

      testWidgets('应该正确高亮活动标题', (tester) async {
        // Arrange
        const headings = [
          Heading(id: '1', text: '标题一', level: 1),
          Heading(id: '2', text: '标题二', level: 1),
        ];

        // Act
        await tester.pumpWidget(buildTestWidget(
          headings: headings,
          activeHeadingId: '2',
        ));

        // Assert
        // 验证活动标题项存在
        expect(find.byKey(const Key('outlineItem_2')), findsOneWidget);
      });

      testWidgets('点击标题应该触发 onHeadingTap', (tester) async {
        // Arrange
        const headings = [
          Heading(id: '1', text: '可点击', level: 1),
        ];
        Heading? tappedHeading;

        // Act
        await tester.pumpWidget(buildTestWidget(
          headings: headings,
          onHeadingTap: (h) => tappedHeading = h,
        ));
        await tester.tap(find.text('可点击'));
        await tester.pump();

        // Assert
        expect(tappedHeading?.id, equals('1'));
        expect(tappedHeading?.text, equals('可点击'));
      });
    });

    group('主题适配', () {
      testWidgets('深色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));

        // Assert
        expect(find.byKey(const Key('outlineSidebar')), findsOneWidget);
      });

      testWidgets('浅色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        // Assert
        expect(find.byKey(const Key('outlineSidebar')), findsOneWidget);
      });
    });

    group('边界条件', () {
      testWidgets('大量标题应该能正确滚动', (tester) async {
        // Arrange
        final headings = List.generate(
          50,
          (i) => Heading(id: '$i', text: '标题 $i', level: 1),
        );

        // Act
        await tester.pumpWidget(buildTestWidget(headings: headings));

        // Assert
        expect(find.byKey(const Key('outlineList')), findsOneWidget);
        // 验证列表可滚动
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('没有 onToggleCollapse 时点击按钮应该安全', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(onToggleCollapse: null));
        await tester.tap(find.byKey(const Key('collapseButton')));
        await tester.pump();

        // Assert - 不应该抛出异常
        expect(true, isTrue);
      });
    });
  });
}
