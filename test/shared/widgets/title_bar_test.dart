import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/core/theme/app_colors.dart';
import 'package:puremark/shared/widgets/title_bar.dart';

void main() {
  group('TitleBar', () {
    Widget buildTestWidget({
      String? fileName,
      VoidCallback? onClose,
      VoidCallback? onMinimize,
      VoidCallback? onFullscreen,
      GestureDragStartCallback? onDragStart,
      GestureDragUpdateCallback? onDragUpdate,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: TitleBar(
            fileName: fileName,
            onClose: onClose,
            onMinimize: onMinimize,
            onFullscreen: onFullscreen,
            onDragStart: onDragStart,
            onDragUpdate: onDragUpdate,
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染标题栏容器', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byKey(const Key('title_bar_container')), findsOneWidget);
        expect(find.byKey(const Key('title_bar_drag_area')), findsOneWidget);
      });

      testWidgets('应该正确渲染三个红绿灯按钮', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byKey(const Key('traffic_light_buttons')), findsOneWidget);
        expect(find.byKey(const Key('close_button')), findsOneWidget);
        expect(find.byKey(const Key('minimize_button')), findsOneWidget);
        expect(find.byKey(const Key('fullscreen_button')), findsOneWidget);
      });

      testWidgets('应该正确渲染文件名（当提供时）', (tester) async {
        await tester.pumpWidget(buildTestWidget(fileName: 'README.md'));

        expect(find.byKey(const Key('title_bar_file_name')), findsOneWidget);
        expect(find.text('README.md'), findsOneWidget);
      });

      testWidgets('不应该渲染文件名（当未提供时）', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byKey(const Key('title_bar_file_name')), findsNothing);
      });
    });

    group('尺寸和样式', () {
      testWidgets('标题栏高度应该为 40px', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final container = tester.widget<Container>(
          find.byKey(const Key('title_bar_container')),
        );

        expect(container.constraints?.maxHeight, 40.0);
      });

      testWidgets('红绿灯按钮大小应该为 12px', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // 验证常量值
        expect(TitleBar.buttonSize, 12.0);
      });

      testWidgets('按钮间距应该为 8px', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // 验证常量值
        expect(TitleBar.buttonSpacing, 8.0);
      });

      testWidgets('关闭按钮颜色应该为 trafficRed', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // 查找 close_button 下的 Container
        final closeButtonFinder = find.byKey(const Key('close_button'));
        final containerFinder = find.descendant(
          of: closeButtonFinder,
          matching: find.byType(Container),
        );
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.color, AppColors.trafficRed);
      });

      testWidgets('最小化按钮颜色应该为 trafficYellow', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final minimizeButtonFinder = find.byKey(const Key('minimize_button'));
        final containerFinder = find.descendant(
          of: minimizeButtonFinder,
          matching: find.byType(Container),
        );
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.color, AppColors.trafficYellow);
      });

      testWidgets('全屏按钮颜色应该为 trafficGreen', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final fullscreenButtonFinder = find.byKey(const Key('fullscreen_button'));
        final containerFinder = find.descendant(
          of: fullscreenButtonFinder,
          matching: find.byType(Container),
        );
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.color, AppColors.trafficGreen);
      });

      testWidgets('按钮应该是圆形', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final closeButtonFinder = find.byKey(const Key('close_button'));
        final containerFinder = find.descendant(
          of: closeButtonFinder,
          matching: find.byType(Container),
        );
        final container = tester.widget<Container>(containerFinder);
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.shape, BoxShape.circle);
      });
    });

    group('交互', () {
      testWidgets('点击关闭按钮应该触发 onClose 回调', (tester) async {
        var closeCalled = false;
        await tester.pumpWidget(buildTestWidget(
          onClose: () => closeCalled = true,
        ));

        await tester.tap(find.byKey(const Key('close_button')));
        await tester.pump();

        expect(closeCalled, isTrue);
      });

      testWidgets('点击最小化按钮应该触发 onMinimize 回调', (tester) async {
        var minimizeCalled = false;
        await tester.pumpWidget(buildTestWidget(
          onMinimize: () => minimizeCalled = true,
        ));

        await tester.tap(find.byKey(const Key('minimize_button')));
        await tester.pump();

        expect(minimizeCalled, isTrue);
      });

      testWidgets('点击全屏按钮应该触发 onFullscreen 回调', (tester) async {
        var fullscreenCalled = false;
        await tester.pumpWidget(buildTestWidget(
          onFullscreen: () => fullscreenCalled = true,
        ));

        await tester.tap(find.byKey(const Key('fullscreen_button')));
        await tester.pump();

        expect(fullscreenCalled, isTrue);
      });

      testWidgets('拖拽应该触发 onDragStart 和 onDragUpdate 回调', (tester) async {
        var dragStartCalled = false;
        var dragUpdateCalled = false;

        await tester.pumpWidget(buildTestWidget(
          onDragStart: (_) => dragStartCalled = true,
          onDragUpdate: (_) => dragUpdateCalled = true,
        ));

        final dragArea = find.byKey(const Key('title_bar_drag_area'));

        await tester.drag(dragArea, const Offset(100, 0));
        await tester.pump();

        expect(dragStartCalled, isTrue);
        expect(dragUpdateCalled, isTrue);
      });
    });

    group('主题', () {
      testWidgets('深色主题下背景色应该为 darkBgPrimary', (tester) async {
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));

        final container = tester.widget<Container>(
          find.byKey(const Key('title_bar_container')),
        );
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.color, AppColors.darkBgPrimary);
      });

      testWidgets('浅色主题下背景色应该为 lightBgPrimary', (tester) async {
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        final container = tester.widget<Container>(
          find.byKey(const Key('title_bar_container')),
        );
        final decoration = container.decoration as BoxDecoration;

        expect(decoration.color, AppColors.lightBgPrimary);
      });
    });
  });
}
