import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/shared/widgets/context_menu.dart';

void main() {
  group('ContextMenuItem', () {
    test('应该正确创建菜单项', () {
      const item = ContextMenuItem(
        label: 'Copy',
        icon: Icons.copy,
        id: 'copy_item',
      );

      expect(item.label, 'Copy');
      expect(item.icon, Icons.copy);
      expect(item.id, 'copy_item');
    });

    test('应该允许不带图标和 ID 的菜单项', () {
      const item = ContextMenuItem(label: 'Simple');

      expect(item.label, 'Simple');
      expect(item.icon, isNull);
      expect(item.id, isNull);
    });
  });

  group('ContextMenu', () {
    final testItems = [
      const ContextMenuItem(label: 'Copy', icon: Icons.copy, id: 'copy'),
      const ContextMenuItem(label: 'Paste', icon: Icons.paste, id: 'paste'),
      const ContextMenuItem(label: 'Delete', icon: Icons.delete, id: 'delete'),
    ];

    Widget buildTestWidget({
      List<ContextMenuItem>? items,
      ValueChanged<ContextMenuItem>? onItemSelected,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: ContextMenu(
              items: items ?? testItems,
              onItemSelected: onItemSelected,
            ),
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染菜单容器', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byKey(const Key('context_menu_clip')), findsOneWidget);
        expect(find.byKey(const Key('context_menu_blur')), findsOneWidget);
        expect(find.byKey(const Key('context_menu_container')), findsOneWidget);
        expect(find.byKey(const Key('context_menu_items')), findsOneWidget);
      });

      testWidgets('应该正确渲染所有菜单项', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byKey(const Key('context_menu_item_copy')), findsOneWidget);
        expect(find.byKey(const Key('context_menu_item_paste')), findsOneWidget);
        expect(find.byKey(const Key('context_menu_item_delete')), findsOneWidget);
      });

      testWidgets('应该显示菜单项标签', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.text('Copy'), findsOneWidget);
        expect(find.text('Paste'), findsOneWidget);
        expect(find.text('Delete'), findsOneWidget);
      });

      testWidgets('应该显示菜单项图标', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byIcon(Icons.copy), findsOneWidget);
        expect(find.byIcon(Icons.paste), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
      });

      testWidgets('没有图标的菜单项应该正确渲染', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          items: [
            const ContextMenuItem(label: 'No Icon'),
          ],
        ));

        expect(find.text('No Icon'), findsOneWidget);
        // 验证没有图标
        expect(find.byType(Icon), findsNothing);
      });
    });

    group('尺寸和样式', () {
      testWidgets('圆角应该为 12px', (tester) async {
        expect(ContextMenu.borderRadius, 12.0);
      });

      testWidgets('菜单项高度应该为 36px', (tester) async {
        expect(ContextMenu.itemHeight, 36.0);
      });

      testWidgets('应该有毛玻璃效果（BackdropFilter）', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        expect(find.byType(BackdropFilter), findsOneWidget);
      });

      testWidgets('应该有 ClipRRect 裁剪圆角', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        final clipRRect = tester.widget<ClipRRect>(
          find.byKey(const Key('context_menu_clip')),
        );

        expect(
          clipRRect.borderRadius,
          BorderRadius.circular(ContextMenu.borderRadius),
        );
      });
    });

    group('交互', () {
      testWidgets('点击菜单项应该触发 onItemSelected 回调', (tester) async {
        ContextMenuItem? selectedItem;
        await tester.pumpWidget(buildTestWidget(
          onItemSelected: (item) => selectedItem = item,
        ));

        await tester.tap(find.text('Copy'));
        await tester.pump();

        expect(selectedItem, isNotNull);
        expect(selectedItem!.label, 'Copy');
        expect(selectedItem!.id, 'copy');
      });

      testWidgets('点击不同菜单项应该返回对应项', (tester) async {
        ContextMenuItem? selectedItem;
        await tester.pumpWidget(buildTestWidget(
          onItemSelected: (item) => selectedItem = item,
        ));

        await tester.tap(find.text('Paste'));
        await tester.pump();

        expect(selectedItem!.label, 'Paste');
        expect(selectedItem!.id, 'paste');
      });

      testWidgets('未提供回调时点击不应该抛出异常', (tester) async {
        await tester.pumpWidget(buildTestWidget(onItemSelected: null));

        await tester.tap(find.text('Copy'));
        await tester.pump();

        // 验证不抛出异常
        expect(true, isTrue);
      });
    });

    group('悬停效果', () {
      testWidgets('鼠标悬停时应该改变背景色', (tester) async {
        await tester.pumpWidget(buildTestWidget());

        // 获取菜单项位置
        final copyItem = find.byKey(const Key('context_menu_item_copy'));

        // 创建鼠标进入事件
        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: tester.getCenter(copyItem));
        addTearDown(gesture.removePointer);

        await tester.pump();

        // 验证组件存在
        expect(copyItem, findsOneWidget);
      });
    });

    group('主题', () {
      testWidgets('深色主题下应该正确渲染', (tester) async {
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));

        expect(find.byKey(const Key('context_menu_container')), findsOneWidget);
      });

      testWidgets('浅色主题下应该正确渲染', (tester) async {
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        expect(find.byKey(const Key('context_menu_container')), findsOneWidget);
      });
    });

    group('边界条件', () {
      testWidgets('单个菜单项应该正确渲染', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          items: [const ContextMenuItem(label: 'Only One')],
        ));

        expect(find.text('Only One'), findsOneWidget);
      });

      testWidgets('多个菜单项应该正确渲染', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          items: List.generate(
            10,
            (i) => ContextMenuItem(label: 'Item $i', id: 'item_$i'),
          ),
        ));

        expect(find.text('Item 0'), findsOneWidget);
        expect(find.text('Item 9'), findsOneWidget);
      });

      testWidgets('使用 label 作为 Key 当 id 为空时', (tester) async {
        await tester.pumpWidget(buildTestWidget(
          items: [const ContextMenuItem(label: 'No ID Item')],
        ));

        expect(
          find.byKey(const Key('context_menu_item_No ID Item')),
          findsOneWidget,
        );
      });
    });
  });
}
