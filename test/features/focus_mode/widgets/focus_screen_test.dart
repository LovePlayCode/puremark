import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/focus_mode/widgets/focus_screen.dart';

void main() {
  group('FocusScreen', () {
    Widget buildTestWidget({
      double readingProgress = 0.0,
      VoidCallback? onExit,
      void Function(double)? onProgressChanged,
      Widget? child,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: FocusScreen(
          readingProgress: readingProgress,
          onExit: onExit,
          onProgressChanged: onProgressChanged,
          child: child ?? const Text('Test Content'),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染专注模式屏幕', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('focusScreen')), findsOneWidget);
      });

      testWidgets('应该显示进度条', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('progressBar')), findsOneWidget);
      });

      testWidgets('应该显示内容区域', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(
          child: const Text('Custom Content'),
        ));

        // Assert
        expect(find.byKey(const Key('focusContent')), findsOneWidget);
        expect(find.text('Custom Content'), findsOneWidget);
      });

      testWidgets('应该显示退出提示', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('exitHint')), findsOneWidget);
        expect(find.text('ESC to exit'), findsOneWidget);
      });
    });

    group('进度条', () {
      testWidgets('进度为 0 时进度条应该为空', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(readingProgress: 0.0));

        // Assert
        expect(find.byKey(const Key('progressIndicator')), findsOneWidget);
      });

      testWidgets('进度为 0.5 时进度条应该显示一半', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(readingProgress: 0.5));

        // Assert
        final progressIndicator = tester.widget<FractionallySizedBox>(
          find.ancestor(
            of: find.byKey(const Key('progressIndicator')),
            matching: find.byType(FractionallySizedBox),
          ),
        );
        expect(progressIndicator.widthFactor, equals(0.5));
      });

      testWidgets('进度为 1.0 时进度条应该完全填满', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(readingProgress: 1.0));

        // Assert
        final progressIndicator = tester.widget<FractionallySizedBox>(
          find.ancestor(
            of: find.byKey(const Key('progressIndicator')),
            matching: find.byType(FractionallySizedBox),
          ),
        );
        expect(progressIndicator.widthFactor, equals(1.0));
      });

      testWidgets('进度大于 1.0 应该被限制为 1.0', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(readingProgress: 1.5));

        // Assert
        final progressIndicator = tester.widget<FractionallySizedBox>(
          find.ancestor(
            of: find.byKey(const Key('progressIndicator')),
            matching: find.byType(FractionallySizedBox),
          ),
        );
        expect(progressIndicator.widthFactor, equals(1.0));
      });

      testWidgets('进度小于 0.0 应该被限制为 0.0', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(readingProgress: -0.5));

        // Assert
        final progressIndicator = tester.widget<FractionallySizedBox>(
          find.ancestor(
            of: find.byKey(const Key('progressIndicator')),
            matching: find.byType(FractionallySizedBox),
          ),
        );
        expect(progressIndicator.widthFactor, equals(0.0));
      });
    });

    group('ESC 退出', () {
      testWidgets('按 ESC 应该触发 onExit', (tester) async {
        // Arrange
        var exitCalled = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onExit: () => exitCalled = true,
        ));

        // 模拟按下 ESC 键
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        // Assert
        expect(exitCalled, isTrue);
      });

      testWidgets('onExit 为 null 时按 ESC 不应该报错', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(onExit: null));

        // 模拟按下 ESC 键
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        // Assert - 不报错即可
        expect(find.byKey(const Key('focusScreen')), findsOneWidget);
      });
    });

    group('内容最大宽度', () {
      testWidgets('内容最大宽度应该是 800px', (tester) async {
        // Assert
        expect(FocusScreen.maxContentWidth, equals(800));
      });
    });

    group('主题适配', () {
      testWidgets('深色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));

        // Assert
        expect(find.byKey(const Key('focusScreen')), findsOneWidget);
      });

      testWidgets('浅色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        // Assert
        expect(find.byKey(const Key('focusScreen')), findsOneWidget);
      });
    });

    group('边界条件', () {
      testWidgets('所有回调都为 null 时应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(
          onExit: null,
          onProgressChanged: null,
        ));

        // Assert
        expect(find.byKey(const Key('focusScreen')), findsOneWidget);
      });
    });
  });

  group('FocusModeWrapper', () {
    Widget buildTestWidget({
      bool isEnabled = false,
      double readingProgress = 0.0,
      VoidCallback? onExit,
      void Function(double)? onProgressChanged,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: FocusModeWrapper(
          isEnabled: isEnabled,
          readingProgress: readingProgress,
          onExit: onExit,
          onProgressChanged: onProgressChanged,
          normalChild: const Scaffold(
            key: Key('normalView'),
            body: Text('Normal View'),
          ),
          focusChild: const Text('Focus Content'),
        ),
      );
    }

    group('渲染', () {
      testWidgets('禁用时应该显示 normalChild', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(isEnabled: false));

        // Assert
        expect(find.byKey(const Key('normalView')), findsOneWidget);
        expect(find.byKey(const Key('focusScreen')), findsNothing);
      });

      testWidgets('启用时应该显示 FocusScreen', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(isEnabled: true));

        // Assert
        expect(find.byKey(const Key('focusScreen')), findsOneWidget);
        expect(find.byKey(const Key('normalView')), findsNothing);
      });

      testWidgets('启用时应该显示 focusChild', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(isEnabled: true));

        // Assert
        expect(find.text('Focus Content'), findsOneWidget);
      });
    });

    group('切换', () {
      testWidgets('从禁用切换到启用应该显示 FocusScreen', (tester) async {
        // Act - 初始禁用
        await tester.pumpWidget(buildTestWidget(isEnabled: false));
        expect(find.byKey(const Key('normalView')), findsOneWidget);

        // Act - 启用
        await tester.pumpWidget(buildTestWidget(isEnabled: true));

        // Assert
        expect(find.byKey(const Key('focusScreen')), findsOneWidget);
      });

      testWidgets('从启用切换到禁用应该显示 normalChild', (tester) async {
        // Act - 初始启用
        await tester.pumpWidget(buildTestWidget(isEnabled: true));
        expect(find.byKey(const Key('focusScreen')), findsOneWidget);

        // Act - 禁用
        await tester.pumpWidget(buildTestWidget(isEnabled: false));

        // Assert
        expect(find.byKey(const Key('normalView')), findsOneWidget);
      });
    });

    group('回调传递', () {
      testWidgets('启用时按 ESC 应该触发 onExit', (tester) async {
        // Arrange
        var exitCalled = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          isEnabled: true,
          onExit: () => exitCalled = true,
        ));

        // 模拟按下 ESC 键
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pump();

        // Assert
        expect(exitCalled, isTrue);
      });
    });
  });
}
