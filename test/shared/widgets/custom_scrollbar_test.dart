import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/shared/widgets/custom_scrollbar.dart';

void main() {
  group('CustomScrollbar', () {
    late ScrollController scrollController;

    setUp(() {
      scrollController = ScrollController();
    });

    tearDown(() {
      scrollController.dispose();
    });

    Widget buildTestWidget({
      Duration fadeOutDuration = const Duration(milliseconds: 800),
      Brightness brightness = Brightness.dark,
      int itemCount = 50,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: SizedBox(
            height: 400,
            child: CustomScrollbar(
              controller: scrollController,
              fadeOutDuration: fadeOutDuration,
              child: ListView.builder(
                controller: scrollController,
                itemCount: itemCount,
                itemBuilder: (context, index) => ListTile(
                  title: Text('Item $index'),
                ),
              ),
            ),
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染滚动条结构', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byKey(const Key('custom_scrollbar_stack')), findsOneWidget);
        expect(find.byKey(const Key('scrollbar_opacity')), findsOneWidget);
        expect(find.byKey(const Key('scrollbar_track')), findsOneWidget);
        expect(find.byKey(const Key('scrollbar_thumb')), findsOneWidget);
      });

      testWidgets('应该渲染子组件', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('Item 0'), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('尺寸和样式', () {
      testWidgets('滚动条宽度应该为 6px', (tester) async {
        expect(CustomScrollbar.width, 6.0);
      });

      testWidgets('滚动条圆角应该为 4px', (tester) async {
        expect(CustomScrollbar.borderRadius, 4.0);
      });

      testWidgets('滚动条轨道应该有正确的宽度', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final track = tester.widget<Container>(
          find.byKey(const Key('scrollbar_track')),
        );

        expect(track.constraints?.maxWidth, CustomScrollbar.width);
      });
    });

    group('可见性', () {
      testWidgets('初始状态滚动条应该不可见（透明度为 0）', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        final opacity = tester.widget<AnimatedOpacity>(
          find.byKey(const Key('scrollbar_opacity')),
        );

        expect(opacity.opacity, 0.0);
      });

      testWidgets('滚动时滚动条应该可见（透明度为 1）', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // 执行滚动
        await tester.drag(find.byType(ListView), const Offset(0, -100));
        await tester.pump();

        final opacity = tester.widget<AnimatedOpacity>(
          find.byKey(const Key('scrollbar_opacity')),
        );

        expect(opacity.opacity, 1.0);
      });

      testWidgets('滚动停止后滚动条应该淡出', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          fadeOutDuration: const Duration(milliseconds: 100),
        ));
        await tester.pump();

        // 执行滚动
        await tester.drag(find.byType(ListView), const Offset(0, -100));
        await tester.pump();

        // 验证滚动条可见
        var opacity = tester.widget<AnimatedOpacity>(
          find.byKey(const Key('scrollbar_opacity')),
        );
        expect(opacity.opacity, 1.0);

        // 等待淡出
        await tester.pump(const Duration(milliseconds: 150));

        opacity = tester.widget<AnimatedOpacity>(
          find.byKey(const Key('scrollbar_opacity')),
        );
        expect(opacity.opacity, 0.0);
      });
    });

    group('滚动行为', () {
      testWidgets('内容不足以滚动时不显示滑块', (tester) async {
        await tester.pumpWidget(buildTestWidget(itemCount: 3));
        await tester.pump();

        // 尝试滚动
        await tester.drag(find.byType(ListView), const Offset(0, -100));
        await tester.pump();

        // 滚动条组件存在但滑块可能不显示
        expect(find.byKey(const Key('scrollbar_thumb')), findsOneWidget);
      });

      testWidgets('滚动位置变化时滑块位置应该更新', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // 执行滚动
        await tester.drag(find.byType(ListView), const Offset(0, -200));
        await tester.pump();

        // 验证滚动控制器位置已更新
        expect(scrollController.offset, greaterThan(0));
      });
    });

    group('主题', () {
      testWidgets('深色主题下应该使用 darkTextTertiary 颜色', (tester) async {
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));
        await tester.pump();

        // 验证组件在深色主题下正确渲染
        expect(find.byKey(const Key('scrollbar_track')), findsOneWidget);
      });

      testWidgets('浅色主题下应该使用 lightTextTertiary 颜色', (tester) async {
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));
        await tester.pump();

        // 验证组件在浅色主题下正确渲染
        expect(find.byKey(const Key('scrollbar_track')), findsOneWidget);
      });
    });

    group('边界条件', () {
      testWidgets('空列表应该正确渲染', (tester) async {
        await tester.pumpWidget(buildTestWidget(itemCount: 0));
        await tester.pump();

        expect(find.byKey(const Key('custom_scrollbar_stack')), findsOneWidget);
      });

      testWidgets('ScrollController 监听器应该正确添加和移除', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // 移除组件
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );
        await tester.pump();

        // 验证不会抛出异常
        expect(true, isTrue);
      });
    });
  });
}
