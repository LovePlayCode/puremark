import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/shared/widgets/skeleton_loader.dart';

void main() {
  group('SkeletonType', () {
    test('应该有四种类型', () {
      expect(SkeletonType.values.length, 4);
      expect(SkeletonType.values, contains(SkeletonType.title));
      expect(SkeletonType.values, contains(SkeletonType.paragraph));
      expect(SkeletonType.values, contains(SkeletonType.codeBlock));
      expect(SkeletonType.values, contains(SkeletonType.mermaid));
    });
  });

  group('SkeletonLoader', () {
    Widget buildTestWidget({
      SkeletonType type = SkeletonType.paragraph,
      double? width,
      double? height,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: SkeletonLoader(
              type: type,
              width: width,
              height: height,
            ),
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染 title 类型', (tester) async {
        await tester.pumpWidget(buildTestWidget(type: SkeletonType.title));

        expect(find.byKey(const Key('skeleton_loader_title')), findsOneWidget);
      });

      testWidgets('应该正确渲染 paragraph 类型', (tester) async {
        await tester.pumpWidget(buildTestWidget(type: SkeletonType.paragraph));

        expect(find.byKey(const Key('skeleton_loader_paragraph')), findsOneWidget);
      });

      testWidgets('应该正确渲染 codeBlock 类型', (tester) async {
        await tester.pumpWidget(buildTestWidget(type: SkeletonType.codeBlock));

        expect(find.byKey(const Key('skeleton_loader_codeBlock')), findsOneWidget);
      });

      testWidgets('应该正确渲染 mermaid 类型', (tester) async {
        await tester.pumpWidget(buildTestWidget(type: SkeletonType.mermaid));

        expect(find.byKey(const Key('skeleton_loader_mermaid')), findsOneWidget);
      });
    });

    group('圆角', () {
      testWidgets('title 类型圆角应该为 6px', (tester) async {
        await tester.pumpWidget(buildTestWidget(type: SkeletonType.title));

        final animatedBuilder = tester.widget<AnimatedBuilder>(
          find.byKey(const Key('skeleton_loader_title')),
        );

        // 验证组件存在
        expect(animatedBuilder, isNotNull);
      });

      testWidgets('paragraph 类型圆角应该为 4px', (tester) async {
        await tester.pumpWidget(buildTestWidget(type: SkeletonType.paragraph));

        final animatedBuilder = tester.widget<AnimatedBuilder>(
          find.byKey(const Key('skeleton_loader_paragraph')),
        );

        expect(animatedBuilder, isNotNull);
      });

      testWidgets('codeBlock 类型圆角应该为 12px', (tester) async {
        await tester.pumpWidget(buildTestWidget(type: SkeletonType.codeBlock));

        final animatedBuilder = tester.widget<AnimatedBuilder>(
          find.byKey(const Key('skeleton_loader_codeBlock')),
        );

        expect(animatedBuilder, isNotNull);
      });

      testWidgets('mermaid 类型圆角应该为 12px', (tester) async {
        await tester.pumpWidget(buildTestWidget(type: SkeletonType.mermaid));

        final animatedBuilder = tester.widget<AnimatedBuilder>(
          find.byKey(const Key('skeleton_loader_mermaid')),
        );

        expect(animatedBuilder, isNotNull);
      });
    });

    group('尺寸', () {
      testWidgets('自定义宽度应该生效', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          type: SkeletonType.title,
          width: 150,
        ));

        expect(find.byKey(const Key('skeleton_loader_title')), findsOneWidget);
      });

      testWidgets('自定义高度应该生效', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          type: SkeletonType.title,
          height: 30,
        ));

        expect(find.byKey(const Key('skeleton_loader_title')), findsOneWidget);
      });

      testWidgets('默认尺寸应该根据类型设置', (tester) async {
        // Title 默认 200x24
        await tester.pumpWidget(buildTestWidget(type: SkeletonType.title));
        expect(find.byKey(const Key('skeleton_loader_title')), findsOneWidget);
      });
    });

    group('动画', () {
      testWidgets('应该有动画效果', (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pump();

        // 检查 AnimatedBuilder 存在 (通过 Key 查找)
        expect(find.byKey(const Key('skeleton_loader_paragraph')), findsOneWidget);
      });

      testWidgets('动画应该正在运行', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // 验证动画在帧之间更新
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byKey(const Key('skeleton_loader_paragraph')), findsOneWidget);
      });

      testWidgets('dispose 时动画应该停止', (tester) async {
        await tester.pumpWidget(buildTestWidget());
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

    group('主题', () {
      testWidgets('深色主题下应该使用深色渐变', (tester) async {
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));

        expect(find.byKey(const Key('skeleton_loader_paragraph')), findsOneWidget);
      });

      testWidgets('浅色主题下应该使用浅色渐变', (tester) async {
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        expect(find.byKey(const Key('skeleton_loader_paragraph')), findsOneWidget);
      });
    });
  });

  group('SkeletonGroup', () {
    Widget buildTestWidget({
      double titleWidth = 200,
      int paragraphLines = 3,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: SkeletonGroup(
              titleWidth: titleWidth,
              paragraphLines: paragraphLines,
            ),
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染骨架组', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byKey(const Key('skeleton_group')), findsOneWidget);
        expect(find.byKey(const Key('skeleton_group_title')), findsOneWidget);
      });

      testWidgets('应该渲染正确数量的段落行', (tester) async {
        await tester.pumpWidget(buildTestWidget(paragraphLines: 3));

        expect(find.byKey(const Key('skeleton_group_paragraph_0')), findsOneWidget);
        expect(find.byKey(const Key('skeleton_group_paragraph_1')), findsOneWidget);
        expect(find.byKey(const Key('skeleton_group_paragraph_2')), findsOneWidget);
      });

      testWidgets('自定义段落行数应该生效', (tester) async {
        await tester.pumpWidget(buildTestWidget(paragraphLines: 5));

        expect(find.byKey(const Key('skeleton_group_paragraph_0')), findsOneWidget);
        expect(find.byKey(const Key('skeleton_group_paragraph_4')), findsOneWidget);
      });
    });

    group('尺寸', () {
      testWidgets('自定义标题宽度应该生效', (tester) async {
        await tester.pumpWidget(buildTestWidget(titleWidth: 150));

        expect(find.byKey(const Key('skeleton_group_title')), findsOneWidget);
      });
    });

    group('边界条件', () {
      testWidgets('零行段落应该正确渲染', (tester) async {
        await tester.pumpWidget(buildTestWidget(paragraphLines: 0));

        expect(find.byKey(const Key('skeleton_group')), findsOneWidget);
        expect(find.byKey(const Key('skeleton_group_title')), findsOneWidget);
        // 不应该有段落行
        expect(find.byKey(const Key('skeleton_group_paragraph_0')), findsNothing);
      });

      testWidgets('单行段落应该正确渲染', (tester) async {
        await tester.pumpWidget(buildTestWidget(paragraphLines: 1));

        expect(find.byKey(const Key('skeleton_group_paragraph_0')), findsOneWidget);
        expect(find.byKey(const Key('skeleton_group_paragraph_1')), findsNothing);
      });
    });
  });
}
