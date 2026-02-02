import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/viewer/widgets/empty_state.dart';

void main() {
  group('EmptyState', () {
    Widget buildTestWidget({
      void Function(String path)? onFileDropped,
      VoidCallback? onOpenFile,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: EmptyState(
            onFileDropped: onFileDropped,
            onOpenFile: onOpenFile,
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染 Logo 容器', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('logoContainer')), findsOneWidget);
      });

      testWidgets('应该显示标题 "PureMark"', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('PureMark'), findsOneWidget);
        expect(find.byKey(const Key('title')), findsOneWidget);
      });

      testWidgets('应该显示提示文字 "拖拽 Markdown 文件至此"', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('拖拽 Markdown 文件至此'), findsOneWidget);
        expect(find.byKey(const Key('hint')), findsOneWidget);
      });

      testWidgets('应该显示拖放区域', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('dragArea')), findsOneWidget);
      });

      testWidgets('应该显示打开文件按钮', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('openFileButton')), findsOneWidget);
        expect(find.text('或点击选择文件'), findsOneWidget);
      });

      testWidgets('应该显示拖放提示图标', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byIcon(Icons.upload_file), findsOneWidget);
      });

      testWidgets('应该显示拖放提示文字', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('拖放文件到这里'), findsOneWidget);
      });
    });

    group('Logo 容器', () {
      testWidgets('Logo 容器应该包含图标', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byIcon(Icons.description_outlined), findsOneWidget);
      });

      testWidgets('Logo 容器应该有正确的尺寸 (80x80)', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('logoContainer')),
        );
        expect(container.constraints?.maxWidth, equals(80));
        expect(container.constraints?.maxHeight, equals(80));
      });
    });

    group('拖放区域', () {
      testWidgets('拖放区域应该有正确的尺寸 (300x150)', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final dragArea = tester.widget<Container>(
          find.byKey(const Key('dragArea')),
        );
        expect(dragArea.constraints?.maxWidth, equals(300));
        expect(dragArea.constraints?.maxHeight, equals(150));
      });

      testWidgets('拖放区域应该有 12px 圆角', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('dragArea')),
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration, isNotNull);
        expect(
          decoration!.borderRadius,
          equals(BorderRadius.circular(12)),
        );
      });
    });

    group('回调', () {
      testWidgets('点击打开文件按钮应该触发 onOpenFile 回调', (tester) async {
        // Arrange
        var callbackInvoked = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onOpenFile: () => callbackInvoked = true,
        ));
        await tester.tap(find.byKey(const Key('openFileButton')));
        await tester.pump();

        // Assert
        expect(callbackInvoked, isTrue);
      });

      testWidgets('没有传 onOpenFile 时点击按钮不应该报错', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.tap(find.byKey(const Key('openFileButton')));
        await tester.pump();

        // Assert - 不应该抛出异常
        expect(true, isTrue);
      });
    });

    group('主题适配', () {
      testWidgets('深色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));

        // Assert
        expect(find.byKey(const Key('logoContainer')), findsOneWidget);
        expect(find.text('PureMark'), findsOneWidget);
      });

      testWidgets('浅色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        // Assert
        expect(find.byKey(const Key('logoContainer')), findsOneWidget);
        expect(find.text('PureMark'), findsOneWidget);
      });
    });

    group('布局', () {
      testWidgets('内容应该垂直居中', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert - EmptyState 的根部使用 Center Widget
        expect(find.byType(Center), findsWidgets);
        // 验证 EmptyState 中的内容被 Center 包裹
        expect(
          find.ancestor(
            of: find.byKey(const Key('logoContainer')),
            matching: find.byType(Center),
          ),
          findsWidgets,
        );
      });

      testWidgets('内容应该在 Column 中', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(Column), findsWidgets);
      });
    });

    group('边界条件', () {
      testWidgets('所有回调都为 null 时应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(
          onFileDropped: null,
          onOpenFile: null,
        ));

        // Assert
        expect(find.byKey(const Key('dragArea')), findsOneWidget);
        expect(find.byKey(const Key('openFileButton')), findsOneWidget);
      });
    });
  });

  group('DashedBorderPainter', () {
    test('应该正确创建实例', () {
      // Act
      final painter = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        dashWidth: 8,
        dashSpace: 4,
        radius: 12,
      );

      // Assert
      expect(painter.color, equals(Colors.grey));
      expect(painter.strokeWidth, equals(2));
      expect(painter.dashWidth, equals(8));
      expect(painter.dashSpace, equals(4));
      expect(painter.radius, equals(12));
    });

    test('shouldRepaint 颜色变化时应该返回 true', () {
      // Arrange
      final painter1 = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        dashWidth: 8,
        dashSpace: 4,
        radius: 12,
      );
      final painter2 = DashedBorderPainter(
        color: Colors.red,
        strokeWidth: 2,
        dashWidth: 8,
        dashSpace: 4,
        radius: 12,
      );

      // Assert
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint 属性相同时应该返回 false', () {
      // Arrange
      final painter1 = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        dashWidth: 8,
        dashSpace: 4,
        radius: 12,
      );
      final painter2 = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        dashWidth: 8,
        dashSpace: 4,
        radius: 12,
      );

      // Assert
      expect(painter1.shouldRepaint(painter2), isFalse);
    });

    test('shouldRepaint strokeWidth 变化时应该返回 true', () {
      // Arrange
      final painter1 = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        dashWidth: 8,
        dashSpace: 4,
        radius: 12,
      );
      final painter2 = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 3,
        dashWidth: 8,
        dashSpace: 4,
        radius: 12,
      );

      // Assert
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint dashWidth 变化时应该返回 true', () {
      // Arrange
      final painter1 = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        dashWidth: 8,
        dashSpace: 4,
        radius: 12,
      );
      final painter2 = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        dashWidth: 10,
        dashSpace: 4,
        radius: 12,
      );

      // Assert
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint dashSpace 变化时应该返回 true', () {
      // Arrange
      final painter1 = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        dashWidth: 8,
        dashSpace: 4,
        radius: 12,
      );
      final painter2 = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        dashWidth: 8,
        dashSpace: 6,
        radius: 12,
      );

      // Assert
      expect(painter1.shouldRepaint(painter2), isTrue);
    });

    test('shouldRepaint radius 变化时应该返回 true', () {
      // Arrange
      final painter1 = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        dashWidth: 8,
        dashSpace: 4,
        radius: 12,
      );
      final painter2 = DashedBorderPainter(
        color: Colors.grey,
        strokeWidth: 2,
        dashWidth: 8,
        dashSpace: 4,
        radius: 16,
      );

      // Assert
      expect(painter1.shouldRepaint(painter2), isTrue);
    });
  });
}
