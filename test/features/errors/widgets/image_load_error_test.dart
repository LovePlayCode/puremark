import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/errors/widgets/image_load_error.dart';

void main() {
  group('ImageLoadError', () {
    Widget buildTestWidget({
      String imageUrl = 'https://example.com/image.png',
      VoidCallback? onRetry,
      double width = 200,
      double height = 150,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: ImageLoadError(
              imageUrl: imageUrl,
              onRetry: onRetry,
              width: width,
              height: height,
            ),
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染错误容器', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('imageLoadErrorContainer')), findsOneWidget);
      });

      testWidgets('应该显示损坏图片图标', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('brokenImageIcon')), findsOneWidget);
        expect(find.byIcon(Icons.broken_image_outlined), findsOneWidget);
      });

      testWidgets('应该显示错误消息 "图片加载失败"', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('图片加载失败'), findsOneWidget);
        expect(find.byKey(const Key('errorMessage')), findsOneWidget);
      });

      testWidgets('应该显示图片 URL', (tester) async {
        // Arrange
        const testUrl = 'https://test.com/test-image.png';

        // Act
        await tester.pumpWidget(buildTestWidget(imageUrl: testUrl));

        // Assert
        expect(find.text(testUrl), findsOneWidget);
        expect(find.byKey(const Key('imageUrl')), findsOneWidget);
      });

      testWidgets('应该显示重试按钮', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('retryButton')), findsOneWidget);
        expect(find.text('重试'), findsOneWidget);
      });

      testWidgets('重试按钮应该有刷新图标', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byIcon(Icons.refresh), findsOneWidget);
      });
    });

    group('尺寸', () {
      testWidgets('应该使用默认尺寸 (200x150)', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('imageLoadErrorContainer')),
        );
        expect(container.constraints?.maxWidth, equals(200));
        expect(container.constraints?.maxHeight, equals(150));
      });

      testWidgets('应该支持自定义宽度', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(width: 300));

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('imageLoadErrorContainer')),
        );
        expect(container.constraints?.maxWidth, equals(300));
      });

      testWidgets('应该支持自定义高度', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(height: 200));

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('imageLoadErrorContainer')),
        );
        expect(container.constraints?.maxHeight, equals(200));
      });

      testWidgets('应该支持自定义宽度和高度', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(width: 400, height: 300));

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('imageLoadErrorContainer')),
        );
        expect(container.constraints?.maxWidth, equals(400));
        expect(container.constraints?.maxHeight, equals(300));
      });
    });

    group('容器样式', () {
      testWidgets('容器应该有圆角边框', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('imageLoadErrorContainer')),
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration, isNotNull);
        expect(decoration!.borderRadius, isNotNull);
      });

      testWidgets('容器应该有边框', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('imageLoadErrorContainer')),
        );
        final decoration = container.decoration as BoxDecoration?;
        expect(decoration, isNotNull);
        expect(decoration!.border, isNotNull);
      });
    });

    group('回调', () {
      testWidgets('点击重试按钮应该触发 onRetry 回调', (tester) async {
        // Arrange
        var callbackInvoked = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onRetry: () => callbackInvoked = true,
        ));
        await tester.tap(find.byKey(const Key('retryButton')));
        await tester.pump();

        // Assert
        expect(callbackInvoked, isTrue);
      });

      testWidgets('没有传 onRetry 时点击按钮不应该报错', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(onRetry: null));
        await tester.tap(find.byKey(const Key('retryButton')));
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
        expect(find.byKey(const Key('imageLoadErrorContainer')), findsOneWidget);
        expect(find.text('图片加载失败'), findsOneWidget);
      });

      testWidgets('浅色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        // Assert
        expect(find.byKey(const Key('imageLoadErrorContainer')), findsOneWidget);
        expect(find.text('图片加载失败'), findsOneWidget);
      });
    });

    group('布局', () {
      testWidgets('内容应该垂直居中', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final column = tester.widget<Column>(
          find.descendant(
            of: find.byKey(const Key('imageLoadErrorContainer')),
            matching: find.byType(Column),
          ),
        );
        expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
      });
    });

    group('边界条件', () {
      testWidgets('长 URL 应该被截断', (tester) async {
        // Arrange
        const longUrl =
            'https://example.com/very/long/path/to/some/image/file/with/many/directories/image.png';

        // Act
        await tester.pumpWidget(buildTestWidget(imageUrl: longUrl));

        // Assert
        final text = tester.widget<Text>(find.byKey(const Key('imageUrl')));
        expect(text.overflow, equals(TextOverflow.ellipsis));
        expect(text.maxLines, equals(1));
      });

      testWidgets('空 URL 应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(imageUrl: ''));

        // Assert
        expect(find.byKey(const Key('imageUrl')), findsOneWidget);
      });

      testWidgets('URL 应该有 Tooltip 显示完整内容', (tester) async {
        // Arrange
        const testUrl = 'https://example.com/image.png';

        // Act
        await tester.pumpWidget(buildTestWidget(imageUrl: testUrl));

        // Assert
        expect(
          find.ancestor(
            of: find.byKey(const Key('imageUrl')),
            matching: find.byType(Tooltip),
          ),
          findsOneWidget,
        );
      });
    });
  });
}
