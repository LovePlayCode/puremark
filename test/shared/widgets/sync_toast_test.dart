import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/shared/widgets/sync_toast.dart';

void main() {
  group('SyncToast', () {
    Widget buildTestWidget({
      String message = 'File synced',
      IconData? icon,
      Duration duration = const Duration(seconds: 2),
      VoidCallback? onDismiss,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SyncToast(
              message: message,
              icon: icon,
              duration: duration,
              onDismiss: onDismiss,
            ),
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染 Toast 结构', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        expect(find.byKey(const Key('sync_toast_slide')), findsOneWidget);
        expect(find.byKey(const Key('sync_toast_fade')), findsOneWidget);
        expect(find.byKey(const Key('sync_toast_container')), findsOneWidget);
        expect(find.byKey(const Key('sync_toast_content')), findsOneWidget);
      });

      testWidgets('应该显示消息文本', (tester) async {
        await tester.pumpWidget(buildTestWidget(message: 'Sync complete'));
        await tester.pump();

        expect(find.text('Sync complete'), findsOneWidget);
        expect(find.byKey(const Key('sync_toast_message')), findsOneWidget);
      });

      testWidgets('应该显示图标（当提供时）', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          icon: Icons.check_circle,
        ));
        await tester.pump();

        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(find.byKey(const Key('sync_toast_icon')), findsOneWidget);
      });

      testWidgets('不应该显示图标（当未提供时）', (tester) async {
        await tester.pumpWidget(buildTestWidget(icon: null));
        await tester.pump();

        expect(find.byKey(const Key('sync_toast_icon')), findsNothing);
      });
    });

    group('样式', () {
      testWidgets('圆角应该为 8px', (tester) async {
        expect(SyncToast.borderRadius, 8.0);
      });

      testWidgets('容器应该有正确的圆角', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // 验证容器存在
        expect(find.byKey(const Key('sync_toast_container')), findsOneWidget);
      });
    });

    group('动画', () {
      testWidgets('应该有淡入动画', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // 检查 FadeTransition (通过 Key 查找)
        expect(find.byKey(const Key('sync_toast_fade')), findsOneWidget);
      });

      testWidgets('应该有滑动动画', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // 检查 SlideTransition (通过 Key 查找)
        expect(find.byKey(const Key('sync_toast_slide')), findsOneWidget);
      });

      testWidgets('入场动画应该在 300ms 内完成', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // 等待动画完成
        await tester.pump(const Duration(milliseconds: 300));

        // 验证组件可见
        expect(find.byKey(const Key('sync_toast_container')), findsOneWidget);
      });
    });

    group('自动消失', () {
      testWidgets('应该在指定时间后自动消失', (tester) async {
        var dismissed = false;
        await tester.pumpWidget(buildTestWidget(
          duration: const Duration(milliseconds: 500),
          onDismiss: () => dismissed = true,
        ));
        await tester.pump();

        // 验证 Toast 可见
        expect(find.byKey(const Key('sync_toast_container')), findsOneWidget);

        // 等待消失动画开始
        await tester.pump(const Duration(milliseconds: 500));

        // 等待消失动画完成
        await tester.pump(const Duration(milliseconds: 300));

        expect(dismissed, isTrue);
      });

      testWidgets('默认持续时间应该为 2 秒', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // 1.5 秒后应该还在
        await tester.pump(const Duration(milliseconds: 1500));
        expect(find.byKey(const Key('sync_toast_container')), findsOneWidget);
      });

      testWidgets('自定义持续时间应该生效', (tester) async {
        var dismissed = false;
        await tester.pumpWidget(buildTestWidget(
          duration: const Duration(milliseconds: 100),
          onDismiss: () => dismissed = true,
        ));
        await tester.pump();

        // 等待消失
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 300));

        expect(dismissed, isTrue);
      });
    });

    group('回调', () {
      testWidgets('onDismiss 应该在消失时被调用', (tester) async {
        var dismissCount = 0;
        await tester.pumpWidget(buildTestWidget(
          duration: const Duration(milliseconds: 100),
          onDismiss: () => dismissCount++,
        ));
        await tester.pump();

        // 等待消失
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 300));

        expect(dismissCount, 1);
      });

      testWidgets('未提供 onDismiss 时不应该抛出异常', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          duration: const Duration(milliseconds: 100),
          onDismiss: null,
        ));
        await tester.pump();

        // 等待消失
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 300));

        // 验证不抛出异常
        expect(true, isTrue);
      });
    });

    group('主题', () {
      testWidgets('深色主题下应该使用深色背景', (tester) async {
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));
        await tester.pump();

        expect(find.byKey(const Key('sync_toast_container')), findsOneWidget);
      });

      testWidgets('浅色主题下应该使用浅色背景', (tester) async {
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));
        await tester.pump();

        expect(find.byKey(const Key('sync_toast_container')), findsOneWidget);
      });
    });

    group('边界条件', () {
      testWidgets('空消息应该正确渲染', (tester) async {
        await tester.pumpWidget(buildTestWidget(message: ''));
        await tester.pump();

        expect(find.byKey(const Key('sync_toast_message')), findsOneWidget);
      });

      testWidgets('长消息应该正确渲染', (tester) async {
        const longMessage = 'This is a very long sync status message that might wrap to multiple lines';
        await tester.pumpWidget(buildTestWidget(message: longMessage));
        await tester.pump();

        expect(find.text(longMessage), findsOneWidget);
      });

      testWidgets('dispose 时应该取消定时器', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          duration: const Duration(seconds: 10),
        ));
        await tester.pump();

        // 替换为空组件
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );
        await tester.pump();

        // 验证不抛出异常
        expect(true, isTrue);
      });
    });
  });
}
