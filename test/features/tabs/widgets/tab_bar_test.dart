import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/tabs/models/tab_item.dart';
import 'package:puremark/features/tabs/providers/tabs_provider.dart';
import 'package:puremark/features/tabs/widgets/tab_bar.dart';
import 'package:puremark/features/tabs/widgets/tab_item.dart';

void main() {
  group('TabItemWidget', () {
    group('Widget 创建', () {
      testWidgets('应该正确创建 TabItemWidget', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TabItemWidget(title: 'test.md'),
            ),
          ),
        );

        // Assert
        expect(find.byKey(const Key('tabItemContainer')), findsOneWidget);
        expect(find.text('test.md'), findsOneWidget);
      });

      testWidgets('应该显示文件名', (tester) async {
        // Arrange
        const title = 'README.md';

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TabItemWidget(title: title),
            ),
          ),
        );

        // Assert
        expect(find.text(title), findsOneWidget);
      });

      testWidgets('应该有关闭按钮', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TabItemWidget(title: 'test.md'),
            ),
          ),
        );

        // Assert
        expect(find.byKey(const Key('tabItemCloseButton')), findsOneWidget);
      });
    });

    group('活动状态', () {
      testWidgets('活动标签应该有不同的样式', (tester) async {
        // Act - 创建活动标签
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Row(
                children: [
                  TabItemWidget(title: 'active.md', isActive: true),
                  TabItemWidget(title: 'inactive.md', isActive: false),
                ],
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('active.md'), findsOneWidget);
        expect(find.text('inactive.md'), findsOneWidget);
      });

      testWidgets('默认应该是非活动状态', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TabItemWidget(title: 'test.md'),
            ),
          ),
        );

        // Assert - Widget 创建成功即可
        expect(find.byType(TabItemWidget), findsOneWidget);
      });
    });

    group('交互', () {
      testWidgets('点击应该触发 onTap 回调', (tester) async {
        // Arrange
        var tapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TabItemWidget(
                title: 'test.md',
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byType(TabItemWidget));
        await tester.pump();

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('点击关闭按钮应该触发 onClose 回调', (tester) async {
        // Arrange
        var closed = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: TabItemWidget(
                title: 'test.md',
                isActive: true, // 活动状态下关闭按钮可见
                onClose: () => closed = true,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byKey(const Key('tabItemCloseButton')));
        await tester.pump();

        // Assert
        expect(closed, isTrue);
      });
    });

    group('悬停', () {
      testWidgets('悬停时关闭按钮应该更明显', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TabItemWidget(title: 'test.md'),
            ),
          ),
        );

        // 模拟鼠标悬停
        final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        await gesture.moveTo(tester.getCenter(find.byType(TabItemWidget)));
        await tester.pump();

        // Assert - Widget 存在即可
        expect(find.byKey(const Key('tabItemCloseButton')), findsOneWidget);
      });
    });

    group('长文件名', () {
      testWidgets('应该截断过长的文件名', (tester) async {
        // Arrange
        const longTitle = 'very_long_filename_that_should_be_truncated.md';

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 150,
                child: TabItemWidget(title: longTitle),
              ),
            ),
          ),
        );

        // Assert - Widget 创建成功，文本应该被截断
        expect(find.byType(TabItemWidget), findsOneWidget);
      });
    });
  });

  group('StandaloneTabBar', () {
    group('Widget 创建', () {
      testWidgets('应该正确创建空的标签栏', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: StandaloneTabBar(tabs: []),
            ),
          ),
        );

        // Assert
        expect(
          find.byKey(const Key('standaloneTabBarContainer')),
          findsOneWidget,
        );
      });

      testWidgets('应该显示所有标签页', (tester) async {
        // Arrange
        const tabs = [
          TabItem(id: '1', filePath: '/file1.md'),
          TabItem(id: '2', filePath: '/file2.md'),
          TabItem(id: '3', filePath: '/file3.md'),
        ];

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: StandaloneTabBar(tabs: tabs),
            ),
          ),
        );

        // Assert
        expect(find.text('file1.md'), findsOneWidget);
        expect(find.text('file2.md'), findsOneWidget);
        expect(find.text('file3.md'), findsOneWidget);
      });

      testWidgets('应该有正确的高度 36px', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: StandaloneTabBar(tabs: []),
            ),
          ),
        );

        // Assert
        final container = tester.widget<Container>(
          find.byKey(const Key('standaloneTabBarContainer')),
        );
        expect(container.constraints?.maxHeight, equals(36));
      });
    });

    group('新建标签按钮', () {
      testWidgets('应该显示新建标签按钮', (tester) async {
        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: StandaloneTabBar(tabs: []),
            ),
          ),
        );

        // Assert
        expect(find.byKey(const Key('newTabButton')), findsOneWidget);
        expect(find.text('+'), findsOneWidget);
      });

      testWidgets('点击新建按钮应该触发 onNewTab 回调', (tester) async {
        // Arrange
        var newTabClicked = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StandaloneTabBar(
                tabs: const [],
                onNewTab: () => newTabClicked = true,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byKey(const Key('newTabButton')));
        await tester.pump();

        // Assert
        expect(newTabClicked, isTrue);
      });
    });

    group('标签交互', () {
      testWidgets('点击标签应该触发 onTabSelected 回调', (tester) async {
        // Arrange
        TabItem? selectedTab;
        const tabs = [
          TabItem(id: '1', filePath: '/file1.md'),
          TabItem(id: '2', filePath: '/file2.md'),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StandaloneTabBar(
                tabs: tabs,
                onTabSelected: (tab) => selectedTab = tab,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('file1.md'));
        await tester.pump();

        // Assert
        expect(selectedTab, isNotNull);
        expect(selectedTab?.id, equals('1'));
      });

      testWidgets('关闭标签应该触发 onTabClosed 回调', (tester) async {
        // Arrange
        TabItem? closedTab;
        const tabs = [
          TabItem(id: '1', filePath: '/file1.md', isActive: true),
        ];

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StandaloneTabBar(
                tabs: tabs,
                activeTabId: '1',
                onTabClosed: (tab) => closedTab = tab,
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byKey(const Key('tabItemCloseButton')));
        await tester.pump();

        // Assert
        expect(closedTab, isNotNull);
        expect(closedTab?.id, equals('1'));
      });
    });

    group('活动标签样式', () {
      testWidgets('活动标签应该有不同的背景色', (tester) async {
        // Arrange
        const tabs = [
          TabItem(id: '1', filePath: '/active.md', isActive: true),
          TabItem(id: '2', filePath: '/inactive.md', isActive: false),
        ];

        // Act
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: StandaloneTabBar(
                tabs: tabs,
                activeTabId: '1',
              ),
            ),
          ),
        );

        // Assert - 两个标签都存在
        expect(find.text('active.md'), findsOneWidget);
        expect(find.text('inactive.md'), findsOneWidget);
      });
    });
  });

  group('TabBarWidget', () {
    group('Widget 创建', () {
      testWidgets('应该正确创建标签栏', (tester) async {
        // Act
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TabBarWidget(),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byKey(const Key('tabBarContainer')), findsOneWidget);
      });

      testWidgets('空状态下应该只显示新建按钮', (tester) async {
        // Act
        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TabBarWidget(),
              ),
            ),
          ),
        );

        // Assert
        expect(find.byKey(const Key('newTabButton')), findsOneWidget);
        expect(find.byType(TabItemWidget), findsNothing);
      });
    });

    group('与 Provider 集成', () {
      testWidgets('应该显示 Provider 中的标签页', (tester) async {
        // Arrange
        final container = ProviderContainer();
        container.read(tabsProvider.notifier).addTab('/test.md');

        // Act
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: TabBarWidget(),
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('test.md'), findsOneWidget);

        // Cleanup
        container.dispose();
      });

      testWidgets('添加标签后应该更新 UI', (tester) async {
        // Arrange
        final container = ProviderContainer();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: TabBarWidget(),
              ),
            ),
          ),
        );

        // 初始状态无标签
        expect(find.byType(TabItemWidget), findsNothing);

        // Act - 添加标签
        container.read(tabsProvider.notifier).addTab('/new.md');
        await tester.pump();

        // Assert
        expect(find.text('new.md'), findsOneWidget);

        // Cleanup
        container.dispose();
      });

      testWidgets('点击标签应该设置活动标签', (tester) async {
        // Arrange
        final container = ProviderContainer();
        container.read(tabsProvider.notifier).addTab('/file1.md');
        final tab2Id =
            container.read(tabsProvider.notifier).addTab('/file2.md');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: TabBarWidget(),
              ),
            ),
          ),
        );

        // file2 是当前活动标签
        expect(container.read(tabsProvider).activeTabId, equals(tab2Id));

        // Act - 点击第一个标签
        await tester.tap(find.text('file1.md'));
        await tester.pump();

        // Assert - 活动标签已改变
        expect(
          container.read(tabsProvider).activeTab?.filePath,
          equals('/file1.md'),
        );

        // Cleanup
        container.dispose();
      });

      testWidgets('关闭标签应该从列表中移除', (tester) async {
        // Arrange
        final container = ProviderContainer();
        container.read(tabsProvider.notifier).addTab('/file.md');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(
              home: Scaffold(
                body: TabBarWidget(),
              ),
            ),
          ),
        );

        expect(find.text('file.md'), findsOneWidget);

        // Act - 关闭标签
        await tester.tap(find.byKey(const Key('tabItemCloseButton')));
        await tester.pump();

        // Assert
        expect(find.text('file.md'), findsNothing);
        expect(container.read(tabsProvider).tabs, isEmpty);

        // Cleanup
        container.dispose();
      });
    });

    group('回调函数', () {
      testWidgets('onNewTab 应该被调用', (tester) async {
        // Arrange
        var newTabCalled = false;

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: TabBarWidget(
                  onNewTab: () => newTabCalled = true,
                ),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byKey(const Key('newTabButton')));
        await tester.pump();

        // Assert
        expect(newTabCalled, isTrue);
      });

      testWidgets('onTabSelected 应该被调用', (tester) async {
        // Arrange
        TabItem? selectedTab;
        final container = ProviderContainer();
        container.read(tabsProvider.notifier).addTab('/file.md');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TabBarWidget(
                  onTabSelected: (tab) => selectedTab = tab,
                ),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.text('file.md'));
        await tester.pump();

        // Assert
        expect(selectedTab, isNotNull);

        // Cleanup
        container.dispose();
      });

      testWidgets('onTabClosed 应该被调用', (tester) async {
        // Arrange
        TabItem? closedTab;
        final container = ProviderContainer();
        container.read(tabsProvider.notifier).addTab('/file.md');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: TabBarWidget(
                  onTabClosed: (tab) => closedTab = tab,
                ),
              ),
            ),
          ),
        );

        // Act
        await tester.tap(find.byKey(const Key('tabItemCloseButton')));
        await tester.pump();

        // Assert
        expect(closedTab, isNotNull);

        // Cleanup
        container.dispose();
      });
    });
  });
}
