import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/viewer/widgets/loading_state.dart';
import 'package:puremark/shared/widgets/skeleton_loader.dart';

void main() {
  group('LoadingState', () {
    Widget buildTestWidget({
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: const Scaffold(
          body: LoadingState(),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染加载状态容器', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('loadingStateContainer')), findsOneWidget);
      });

      testWidgets('应该渲染 LoadingState Widget', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byType(LoadingState), findsOneWidget);
      });
    });

    group('骨架屏组件', () {
      testWidgets('应该包含标题骨架屏', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('loadingStateTitle')), findsOneWidget);
      });

      testWidgets('标题骨架屏应该是 title 类型', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final titleSkeleton = tester.widget<SkeletonLoader>(
          find.byKey(const Key('loadingStateTitle')),
        );
        expect(titleSkeleton.type, equals(SkeletonType.title));
      });

      testWidgets('应该包含多个段落骨架屏', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('loadingStateParagraph1')), findsOneWidget);
        expect(find.byKey(const Key('loadingStateParagraph2')), findsOneWidget);
        expect(find.byKey(const Key('loadingStateParagraph3')), findsOneWidget);
        expect(find.byKey(const Key('loadingStateParagraph4')), findsOneWidget);
        expect(find.byKey(const Key('loadingStateParagraph5')), findsOneWidget);
      });

      testWidgets('段落骨架屏应该是 paragraph 类型', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final paragraphSkeleton = tester.widget<SkeletonLoader>(
          find.byKey(const Key('loadingStateParagraph1')),
        );
        expect(paragraphSkeleton.type, equals(SkeletonType.paragraph));
      });

      testWidgets('应该包含代码块骨架屏', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('loadingStateCodeBlock')), findsOneWidget);
      });

      testWidgets('代码块骨架屏应该是 codeBlock 类型', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final codeBlockSkeleton = tester.widget<SkeletonLoader>(
          find.byKey(const Key('loadingStateCodeBlock')),
        );
        expect(codeBlockSkeleton.type, equals(SkeletonType.codeBlock));
      });
    });

    group('骨架屏尺寸', () {
      testWidgets('标题骨架屏应该有正确的尺寸', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final titleSkeleton = tester.widget<SkeletonLoader>(
          find.byKey(const Key('loadingStateTitle')),
        );
        expect(titleSkeleton.width, equals(250));
        expect(titleSkeleton.height, equals(32));
      });

      testWidgets('段落骨架屏应该有正确的高度', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final paragraphSkeleton = tester.widget<SkeletonLoader>(
          find.byKey(const Key('loadingStateParagraph1')),
        );
        expect(paragraphSkeleton.height, equals(16));
      });

      testWidgets('第三个段落应该有固定宽度', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final paragraph3 = tester.widget<SkeletonLoader>(
          find.byKey(const Key('loadingStateParagraph3')),
        );
        expect(paragraph3.width, equals(200));
      });

      testWidgets('代码块骨架屏应该有正确的高度', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final codeBlockSkeleton = tester.widget<SkeletonLoader>(
          find.byKey(const Key('loadingStateCodeBlock')),
        );
        expect(codeBlockSkeleton.height, equals(120));
      });
    });

    group('布局', () {
      testWidgets('应该有 24px 内边距', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final padding = tester.widget<Padding>(
          find.byKey(const Key('loadingStateContainer')),
        );
        expect(
          padding.padding,
          equals(const EdgeInsets.all(24)),
        );
      });

      testWidgets('内容应该左对齐', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final column = tester.widget<Column>(
          find.descendant(
            of: find.byKey(const Key('loadingStateContainer')),
            matching: find.byType(Column),
          ),
        );
        expect(
          column.crossAxisAlignment,
          equals(CrossAxisAlignment.start),
        );
      });
    });

    group('Shimmer 动画', () {
      testWidgets('骨架屏应该包含动画', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // Assert - 验证组件存在
        expect(find.byType(SkeletonLoader), findsWidgets);
      });

      testWidgets('动画应该在帧之间更新', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // Assert - 组件仍然存在且正常运行
        expect(find.byType(LoadingState), findsOneWidget);
      });
    });

    group('主题适配', () {
      testWidgets('深色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));

        // Assert
        expect(find.byType(LoadingState), findsOneWidget);
        expect(find.byKey(const Key('loadingStateTitle')), findsOneWidget);
      });

      testWidgets('浅色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        // Assert
        expect(find.byType(LoadingState), findsOneWidget);
        expect(find.byKey(const Key('loadingStateTitle')), findsOneWidget);
      });
    });

    group('骨架屏数量', () {
      testWidgets('应该有正确数量的 SkeletonLoader', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        // 1 title + 5 paragraphs + 1 codeBlock = 7
        expect(find.byType(SkeletonLoader), findsNWidgets(7));
      });
    });

    group('dispose', () {
      testWidgets('dispose 时不应该报错', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // 替换为空组件
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: SizedBox())),
        );
        await tester.pump();

        // Assert - 不应该抛出异常
        expect(true, isTrue);
      });
    });

    group('辅助功能', () {
      testWidgets('所有骨架屏应该有唯一的 Key', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert - 每个 Key 应该只找到一个 Widget
        expect(find.byKey(const Key('loadingStateTitle')), findsOneWidget);
        expect(find.byKey(const Key('loadingStateParagraph1')), findsOneWidget);
        expect(find.byKey(const Key('loadingStateParagraph2')), findsOneWidget);
        expect(find.byKey(const Key('loadingStateParagraph3')), findsOneWidget);
        expect(find.byKey(const Key('loadingStateParagraph4')), findsOneWidget);
        expect(find.byKey(const Key('loadingStateParagraph5')), findsOneWidget);
        expect(find.byKey(const Key('loadingStateCodeBlock')), findsOneWidget);
      });
    });
  });
}
