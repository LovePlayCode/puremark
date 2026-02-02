import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/shortcuts/widgets/shortcuts_panel.dart';

void main() {
  group('ShortcutItem', () {
    test('应该正确创建快捷键项', () {
      // Act
      const item = ShortcutItem(label: '打开文件', keys: ['⌘', 'O']);

      // Assert
      expect(item.label, equals('打开文件'));
      expect(item.keys, equals(['⌘', 'O']));
    });
  });

  group('ShortcutGroup', () {
    test('应该正确创建快捷键分组', () {
      // Act
      const group = ShortcutGroup(
        title: '文件',
        shortcuts: [
          ShortcutItem(label: '打开文件', keys: ['⌘', 'O']),
          ShortcutItem(label: '关闭标签页', keys: ['⌘', 'W']),
        ],
      );

      // Assert
      expect(group.title, equals('文件'));
      expect(group.shortcuts.length, equals(2));
    });
  });

  group('ShortcutsPanel', () {
    Widget buildTestWidget({
      VoidCallback? onClose,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: ShortcutsPanel(
              onClose: onClose,
            ),
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染快捷键面板', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('shortcutsPanel')), findsOneWidget);
      });

      testWidgets('应该显示标题 "快捷键"', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('快捷键'), findsOneWidget);
      });

      testWidgets('应该显示关闭按钮', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('closeButton')), findsOneWidget);
      });
    });

    group('圆角', () {
      testWidgets('快捷键面板应该有 16px 圆角', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final dialog = tester.widget<Dialog>(
          find.byKey(const Key('shortcutsPanel')),
        );
        final shape = dialog.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, equals(BorderRadius.circular(16)));
      });
    });

    group('默认快捷键分组', () {
      test('应该有 5 个默认分组', () {
        // Assert
        expect(ShortcutsPanel.defaultGroups.length, equals(5));
      });

      test('应该包含文件分组', () {
        // Assert
        final group = ShortcutsPanel.defaultGroups.firstWhere(
          (g) => g.title == '文件',
        );
        expect(group.shortcuts.isNotEmpty, isTrue);
      });

      test('应该包含视图分组', () {
        // Assert
        final group = ShortcutsPanel.defaultGroups.firstWhere(
          (g) => g.title == '视图',
        );
        expect(group.shortcuts.isNotEmpty, isTrue);
      });

      test('应该包含搜索分组', () {
        // Assert
        final group = ShortcutsPanel.defaultGroups.firstWhere(
          (g) => g.title == '搜索',
        );
        expect(group.shortcuts.isNotEmpty, isTrue);
      });

      test('应该包含导航分组', () {
        // Assert
        final group = ShortcutsPanel.defaultGroups.firstWhere(
          (g) => g.title == '导航',
        );
        expect(group.shortcuts.isNotEmpty, isTrue);
      });

      test('应该包含其他分组', () {
        // Assert
        final group = ShortcutsPanel.defaultGroups.firstWhere(
          (g) => g.title == '其他',
        );
        expect(group.shortcuts.isNotEmpty, isTrue);
      });
    });

    group('分组标题显示', () {
      testWidgets('应该显示所有分组标题', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('groupTitle_文件')), findsOneWidget);
        expect(find.byKey(const Key('groupTitle_视图')), findsOneWidget);
        expect(find.byKey(const Key('groupTitle_搜索')), findsOneWidget);
        expect(find.byKey(const Key('groupTitle_导航')), findsOneWidget);
        expect(find.byKey(const Key('groupTitle_其他')), findsOneWidget);
      });
    });

    group('快捷键显示', () {
      testWidgets('应该显示打开文件快捷键', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('打开文件'), findsOneWidget);
      });

      testWidgets('应该显示专注模式快捷键', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('专注模式'), findsOneWidget);
      });

      testWidgets('应该显示搜索快捷键', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('搜索'), findsAtLeast(2)); // 分组标题 + 快捷键项
      });
    });

    group('键位徽章', () {
      testWidgets('应该显示键位徽章', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('keyBadge_⌘')), findsWidgets);
      });

      testWidgets('键位徽章应该有 4px 圆角', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('keyBadge_⌘')).first,
        );
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.borderRadius, equals(BorderRadius.circular(4)));
      });
    });

    group('关闭按钮', () {
      testWidgets('点击关闭按钮应该触发 onClose', (tester) async {
        // Arrange
        var closeCalled = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onClose: () => closeCalled = true,
        ));
        await tester.tap(find.byKey(const Key('closeButton')));
        await tester.pump();

        // Assert
        expect(closeCalled, isTrue);
      });
    });

    group('主题适配', () {
      testWidgets('深色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));

        // Assert
        expect(find.byKey(const Key('shortcutsPanel')), findsOneWidget);
      });

      testWidgets('浅色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        // Assert
        expect(find.byKey(const Key('shortcutsPanel')), findsOneWidget);
      });
    });

    group('边界条件', () {
      testWidgets('onClose 为 null 时应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(onClose: null));

        // Assert
        expect(find.byKey(const Key('shortcutsPanel')), findsOneWidget);
      });
    });
  });
}
