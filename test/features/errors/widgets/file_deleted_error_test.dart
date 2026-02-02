import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/errors/widgets/file_deleted_error.dart';

void main() {
  group('FileDeletedError', () {
    Widget buildTestWidget({
      String filePath = '/path/to/deleted/file.md',
      VoidCallback? onCloseTab,
      VoidCallback? onOpenFile,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: FileDeletedError(
            filePath: filePath,
            onCloseTab: onCloseTab,
            onOpenFile: onOpenFile,
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染错误容器', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('fileDeletedErrorContainer')), findsOneWidget);
      });

      testWidgets('应该显示错误图标', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('errorIcon')), findsOneWidget);
        expect(find.byIcon(Icons.error_outline), findsOneWidget);
      });

      testWidgets('应该显示错误消息 "文件已被删除或移动"', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('文件已被删除或移动'), findsOneWidget);
        expect(find.byKey(const Key('errorMessage')), findsOneWidget);
      });

      testWidgets('应该显示文件路径', (tester) async {
        // Arrange
        const testPath = '/test/path/to/file.md';

        // Act
        await tester.pumpWidget(buildTestWidget(filePath: testPath));

        // Assert
        expect(find.text(testPath), findsOneWidget);
        expect(find.byKey(const Key('filePath')), findsOneWidget);
      });

      testWidgets('应该显示关闭标签按钮', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('closeTabButton')), findsOneWidget);
        expect(find.text('关闭标签'), findsOneWidget);
      });

      testWidgets('应该显示打开其他文件按钮', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('openFileButton')), findsOneWidget);
        expect(find.text('打开其他文件'), findsOneWidget);
      });

      testWidgets('应该显示错误图标容器', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('errorIconContainer')), findsOneWidget);
      });

      testWidgets('应该显示文件路径容器', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('filePathContainer')), findsOneWidget);
      });
    });

    group('错误图标容器', () {
      testWidgets('错误图标容器应该有正确的尺寸 (80x80)', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('errorIconContainer')),
        );
        expect(container.constraints?.maxWidth, equals(80));
        expect(container.constraints?.maxHeight, equals(80));
      });

      testWidgets('错误图标容器应该是圆形', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('errorIconContainer')),
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration, isNotNull);
        expect(decoration!.shape, equals(BoxShape.circle));
      });
    });

    group('回调', () {
      testWidgets('点击关闭标签按钮应该触发 onCloseTab 回调', (tester) async {
        // Arrange
        var callbackInvoked = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onCloseTab: () => callbackInvoked = true,
        ));
        await tester.tap(find.byKey(const Key('closeTabButton')));
        await tester.pump();

        // Assert
        expect(callbackInvoked, isTrue);
      });

      testWidgets('点击打开其他文件按钮应该触发 onOpenFile 回调', (tester) async {
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

      testWidgets('没有传 onCloseTab 时点击按钮不应该报错', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(onCloseTab: null));
        await tester.tap(find.byKey(const Key('closeTabButton')));
        await tester.pump();

        // Assert - 不应该抛出异常
        expect(true, isTrue);
      });

      testWidgets('没有传 onOpenFile 时点击按钮不应该报错', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(onOpenFile: null));
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
        expect(find.byKey(const Key('fileDeletedErrorContainer')), findsOneWidget);
        expect(find.text('文件已被删除或移动'), findsOneWidget);
      });

      testWidgets('浅色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        // Assert
        expect(find.byKey(const Key('fileDeletedErrorContainer')), findsOneWidget);
        expect(find.text('文件已被删除或移动'), findsOneWidget);
      });
    });

    group('布局', () {
      testWidgets('内容应该居中显示', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(Center), findsWidgets);
        expect(
          find.ancestor(
            of: find.byKey(const Key('fileDeletedErrorContainer')),
            matching: find.byType(Center),
          ),
          findsWidgets,
        );
      });

      testWidgets('按钮应该在 Row 中水平排列', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(
          find.ancestor(
            of: find.byKey(const Key('closeTabButton')),
            matching: find.byType(Row),
          ),
          findsOneWidget,
        );
        expect(
          find.ancestor(
            of: find.byKey(const Key('openFileButton')),
            matching: find.byType(Row),
          ),
          findsOneWidget,
        );
      });
    });

    group('边界条件', () {
      testWidgets('所有回调都为 null 时应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(
          onCloseTab: null,
          onOpenFile: null,
        ));

        // Assert
        expect(find.byKey(const Key('closeTabButton')), findsOneWidget);
        expect(find.byKey(const Key('openFileButton')), findsOneWidget);
      });

      testWidgets('长文件路径应该被截断', (tester) async {
        // Arrange
        const longPath =
            '/very/long/path/to/some/deeply/nested/directory/structure/file.md';

        // Act
        await tester.pumpWidget(buildTestWidget(filePath: longPath));

        // Assert
        final text = tester.widget<Text>(find.byKey(const Key('filePath')));
        expect(text.overflow, equals(TextOverflow.ellipsis));
        expect(text.maxLines, equals(2));
      });

      testWidgets('空文件路径应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(filePath: ''));

        // Assert
        expect(find.byKey(const Key('filePath')), findsOneWidget);
      });
    });
  });
}
