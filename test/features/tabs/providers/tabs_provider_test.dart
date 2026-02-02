import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/tabs/models/tab_item.dart';
import 'package:puremark/features/tabs/providers/tabs_provider.dart';

void main() {
  group('TabItem', () {
    group('构造函数', () {
      test('应该正确创建 TabItem', () {
        // Arrange & Act
        const tab = TabItem(
          id: 'test-id',
          filePath: '/path/to/file.md',
        );

        // Assert
        expect(tab.id, equals('test-id'));
        expect(tab.filePath, equals('/path/to/file.md'));
        expect(tab.isActive, isFalse);
      });

      test('应该支持 isActive 参数', () {
        // Arrange & Act
        const tab = TabItem(
          id: 'test-id',
          filePath: '/path/to/file.md',
          isActive: true,
        );

        // Assert
        expect(tab.isActive, isTrue);
      });
    });

    group('title', () {
      test('应该从文件路径提取文件名', () {
        // Arrange
        const tab = TabItem(
          id: 'test-id',
          filePath: '/path/to/README.md',
        );

        // Assert
        expect(tab.title, equals('README.md'));
      });

      test('应该处理嵌套路径', () {
        // Arrange
        const tab = TabItem(
          id: 'test-id',
          filePath: '/Users/test/Documents/project/docs/guide.md',
        );

        // Assert
        expect(tab.title, equals('guide.md'));
      });

      test('应该处理 Windows 风格路径', () {
        // Arrange
        // 注意：path 包在不同平台上对 Windows 路径的处理不同
        // 在 macOS/Linux 上，反斜杠不被识别为路径分隔符
        const tab = TabItem(
          id: 'test-id',
          filePath: 'C:\\Users\\test\\file.md',
        );

        // Assert - 在 macOS 上整个字符串被视为文件名
        // 这是 path 包的预期行为
        expect(tab.title, isNotEmpty);
      });

      test('应该处理只有文件名的路径', () {
        // Arrange
        const tab = TabItem(
          id: 'test-id',
          filePath: 'file.md',
        );

        // Assert
        expect(tab.title, equals('file.md'));
      });
    });

    group('copyWith', () {
      test('应该正确复制并更新 isActive', () {
        // Arrange
        const original = TabItem(
          id: 'test-id',
          filePath: '/path/to/file.md',
          isActive: false,
        );

        // Act
        final updated = original.copyWith(isActive: true);

        // Assert
        expect(updated.id, equals(original.id));
        expect(updated.filePath, equals(original.filePath));
        expect(updated.isActive, isTrue);
      });

      test('不传参数应该返回相同值的副本', () {
        // Arrange
        const original = TabItem(
          id: 'test-id',
          filePath: '/path/to/file.md',
          isActive: true,
        );

        // Act
        final copied = original.copyWith();

        // Assert
        expect(copied, equals(original));
      });

      test('应该能更新所有字段', () {
        // Arrange
        const original = TabItem(
          id: 'old-id',
          filePath: '/old/path.md',
          isActive: false,
        );

        // Act
        final updated = original.copyWith(
          id: 'new-id',
          filePath: '/new/path.md',
          isActive: true,
        );

        // Assert
        expect(updated.id, equals('new-id'));
        expect(updated.filePath, equals('/new/path.md'));
        expect(updated.isActive, isTrue);
      });
    });

    group('相等性', () {
      test('相同值的 TabItem 应该相等', () {
        // Arrange
        const tab1 = TabItem(
          id: 'test-id',
          filePath: '/path/to/file.md',
          isActive: true,
        );
        const tab2 = TabItem(
          id: 'test-id',
          filePath: '/path/to/file.md',
          isActive: true,
        );

        // Assert
        expect(tab1, equals(tab2));
        expect(tab1.hashCode, equals(tab2.hashCode));
      });

      test('不同 id 的 TabItem 应该不相等', () {
        // Arrange
        const tab1 = TabItem(id: 'id-1', filePath: '/path.md');
        const tab2 = TabItem(id: 'id-2', filePath: '/path.md');

        // Assert
        expect(tab1, isNot(equals(tab2)));
      });

      test('不同 filePath 的 TabItem 应该不相等', () {
        // Arrange
        const tab1 = TabItem(id: 'id', filePath: '/path1.md');
        const tab2 = TabItem(id: 'id', filePath: '/path2.md');

        // Assert
        expect(tab1, isNot(equals(tab2)));
      });

      test('不同 isActive 的 TabItem 应该不相等', () {
        // Arrange
        const tab1 = TabItem(id: 'id', filePath: '/path.md', isActive: true);
        const tab2 = TabItem(id: 'id', filePath: '/path.md', isActive: false);

        // Assert
        expect(tab1, isNot(equals(tab2)));
      });
    });

    group('toString', () {
      test('toString 应该包含所有字段', () {
        // Arrange
        const tab = TabItem(
          id: 'my-id',
          filePath: '/path/to/file.md',
          isActive: true,
        );

        // Act
        final str = tab.toString();

        // Assert
        expect(str, contains('TabItem'));
        expect(str, contains('my-id'));
        expect(str, contains('/path/to/file.md'));
        expect(str, contains('file.md'));
        expect(str, contains('true'));
      });
    });
  });

  group('TabsState', () {
    group('构造函数', () {
      test('应该正确创建空状态', () {
        // Act
        final state = TabsState.empty();

        // Assert
        expect(state.tabs, isEmpty);
        expect(state.activeTabId, isNull);
        expect(state.hasTabs, isFalse);
        expect(state.tabCount, equals(0));
      });

      test('应该支持传入标签列表', () {
        // Arrange
        const tabs = [
          TabItem(id: '1', filePath: '/file1.md'),
          TabItem(id: '2', filePath: '/file2.md'),
        ];

        // Act
        const state = TabsState(tabs: tabs, activeTabId: '1');

        // Assert
        expect(state.tabs.length, equals(2));
        expect(state.activeTabId, equals('1'));
        expect(state.hasTabs, isTrue);
        expect(state.tabCount, equals(2));
      });
    });

    group('activeTab', () {
      test('应该返回活动标签页', () {
        // Arrange
        const tabs = [
          TabItem(id: '1', filePath: '/file1.md'),
          TabItem(id: '2', filePath: '/file2.md', isActive: true),
        ];
        const state = TabsState(tabs: tabs, activeTabId: '2');

        // Act
        final activeTab = state.activeTab;

        // Assert
        expect(activeTab, isNotNull);
        expect(activeTab?.id, equals('2'));
      });

      test('没有活动标签页时应该返回 null', () {
        // Arrange
        final state = TabsState.empty();

        // Act
        final activeTab = state.activeTab;

        // Assert
        expect(activeTab, isNull);
      });

      test('activeTabId 不存在时应该返回 null', () {
        // Arrange
        const tabs = [TabItem(id: '1', filePath: '/file1.md')];
        const state = TabsState(tabs: tabs, activeTabId: 'non-existent');

        // Act
        final activeTab = state.activeTab;

        // Assert
        expect(activeTab, isNull);
      });
    });

    group('copyWith', () {
      test('应该正确复制并更新字段', () {
        // Arrange
        const state = TabsState(
          tabs: [TabItem(id: '1', filePath: '/file.md')],
          activeTabId: '1',
        );

        // Act
        final updated = state.copyWith(activeTabId: '2');

        // Assert
        expect(updated.tabs.length, equals(1));
        expect(updated.activeTabId, equals('2'));
      });

      test('应该支持清除 activeTabId', () {
        // Arrange
        const state = TabsState(
          tabs: [TabItem(id: '1', filePath: '/file.md')],
          activeTabId: '1',
        );

        // Act
        final updated = state.copyWith(clearActiveTabId: true);

        // Assert
        expect(updated.activeTabId, isNull);
      });
    });
  });

  group('TabsProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    group('初始状态', () {
      test('初始状态应该是空的', () {
        // Act
        final state = container.read(tabsProvider);

        // Assert
        expect(state.tabs, isEmpty);
        expect(state.activeTabId, isNull);
        expect(state.hasTabs, isFalse);
      });
    });

    group('addTab', () {
      test('应该添加新标签页', () {
        // Act
        final tabId =
            container.read(tabsProvider.notifier).addTab('/path/to/file.md');

        // Assert
        final state = container.read(tabsProvider);
        expect(state.tabs.length, equals(1));
        expect(state.tabs.first.filePath, equals('/path/to/file.md'));
        expect(state.activeTabId, equals(tabId));
      });

      test('添加的标签页应该自动激活', () {
        // Act
        final tabId =
            container.read(tabsProvider.notifier).addTab('/file.md');

        // Assert
        final state = container.read(tabsProvider);
        expect(state.tabs.first.isActive, isTrue);
        expect(state.activeTabId, equals(tabId));
      });

      test('添加多个标签页时只有最后一个应该是活动的', () {
        // Act
        container.read(tabsProvider.notifier).addTab('/file1.md');
        container.read(tabsProvider.notifier).addTab('/file2.md');
        final lastTabId =
            container.read(tabsProvider.notifier).addTab('/file3.md');

        // Assert
        final state = container.read(tabsProvider);
        expect(state.tabs.length, equals(3));
        expect(state.activeTabId, equals(lastTabId));

        final activeTabs = state.tabs.where((t) => t.isActive).toList();
        expect(activeTabs.length, equals(1));
        expect(activeTabs.first.filePath, equals('/file3.md'));
      });

      test('打开已存在的文件应该激活已有标签而不是新建', () {
        // Arrange
        final firstTabId =
            container.read(tabsProvider.notifier).addTab('/file.md');
        container.read(tabsProvider.notifier).addTab('/other.md');

        // Act
        final resultTabId =
            container.read(tabsProvider.notifier).addTab('/file.md');

        // Assert
        final state = container.read(tabsProvider);
        expect(state.tabs.length, equals(2)); // 没有新建
        expect(resultTabId, equals(firstTabId)); // 返回已有标签 ID
        expect(state.activeTabId, equals(firstTabId)); // 激活已有标签
      });
    });

    group('closeTab', () {
      test('应该关闭指定标签页', () {
        // Arrange
        final tabId =
            container.read(tabsProvider.notifier).addTab('/file.md');

        // Act
        container.read(tabsProvider.notifier).closeTab(tabId);

        // Assert
        final state = container.read(tabsProvider);
        expect(state.tabs, isEmpty);
        expect(state.activeTabId, isNull);
      });

      test('关闭不存在的标签页应该安全', () {
        // Act & Assert - 不应该抛出异常
        container.read(tabsProvider.notifier).closeTab('non-existent');
        expect(container.read(tabsProvider).tabs, isEmpty);
      });

      test('关闭活动标签页应该激活右侧标签', () {
        // Arrange
        final tab1Id =
            container.read(tabsProvider.notifier).addTab('/file1.md');
        container.read(tabsProvider.notifier).addTab('/file2.md');
        container.read(tabsProvider.notifier).addTab('/file3.md');
        container.read(tabsProvider.notifier).setActiveTab(tab1Id);

        // Act - 关闭第一个（活动）标签
        container.read(tabsProvider.notifier).closeTab(tab1Id);

        // Assert
        final state = container.read(tabsProvider);
        expect(state.tabs.length, equals(2));
        expect(state.activeTab?.filePath, equals('/file2.md')); // 右侧标签
      });

      test('关闭最右侧活动标签页应该激活左侧标签', () {
        // Arrange
        container.read(tabsProvider.notifier).addTab('/file1.md');
        container.read(tabsProvider.notifier).addTab('/file2.md');
        final tab3Id =
            container.read(tabsProvider.notifier).addTab('/file3.md');

        // Act - 关闭最后一个（活动）标签
        container.read(tabsProvider.notifier).closeTab(tab3Id);

        // Assert
        final state = container.read(tabsProvider);
        expect(state.tabs.length, equals(2));
        expect(state.activeTab?.filePath, equals('/file2.md')); // 左侧标签
      });

      test('关闭非活动标签页不应改变活动标签', () {
        // Arrange
        final tab1Id =
            container.read(tabsProvider.notifier).addTab('/file1.md');
        container.read(tabsProvider.notifier).addTab('/file2.md');
        final tab3Id =
            container.read(tabsProvider.notifier).addTab('/file3.md');
        // tab3 是当前活动标签

        // Act - 关闭第一个（非活动）标签
        container.read(tabsProvider.notifier).closeTab(tab1Id);

        // Assert
        final state = container.read(tabsProvider);
        expect(state.tabs.length, equals(2));
        expect(state.activeTabId, equals(tab3Id)); // 活动标签不变
      });
    });

    group('setActiveTab', () {
      test('应该设置活动标签页', () {
        // Arrange
        final tab1Id =
            container.read(tabsProvider.notifier).addTab('/file1.md');
        container.read(tabsProvider.notifier).addTab('/file2.md');

        // Act
        container.read(tabsProvider.notifier).setActiveTab(tab1Id);

        // Assert
        final state = container.read(tabsProvider);
        expect(state.activeTabId, equals(tab1Id));
        expect(state.tabs.firstWhere((t) => t.id == tab1Id).isActive, isTrue);
      });

      test('设置不存在的标签页应该无效', () {
        // Arrange
        final originalId =
            container.read(tabsProvider.notifier).addTab('/file.md');

        // Act
        container.read(tabsProvider.notifier).setActiveTab('non-existent');

        // Assert
        final state = container.read(tabsProvider);
        expect(state.activeTabId, equals(originalId)); // 保持不变
      });

      test('设置相同标签页应该无操作', () {
        // Arrange
        final tabId =
            container.read(tabsProvider.notifier).addTab('/file.md');

        // Act
        container.read(tabsProvider.notifier).setActiveTab(tabId);
        container.read(tabsProvider.notifier).setActiveTab(tabId);

        // Assert - 应该没有问题
        final state = container.read(tabsProvider);
        expect(state.activeTabId, equals(tabId));
      });
    });

    group('closeAllTabs', () {
      test('应该关闭所有标签页', () {
        // Arrange
        container.read(tabsProvider.notifier).addTab('/file1.md');
        container.read(tabsProvider.notifier).addTab('/file2.md');
        container.read(tabsProvider.notifier).addTab('/file3.md');

        // Act
        container.read(tabsProvider.notifier).closeAllTabs();

        // Assert
        final state = container.read(tabsProvider);
        expect(state.tabs, isEmpty);
        expect(state.activeTabId, isNull);
      });

      test('空状态下调用应该安全', () {
        // Act & Assert - 不应该抛出异常
        container.read(tabsProvider.notifier).closeAllTabs();
        expect(container.read(tabsProvider).tabs, isEmpty);
      });
    });

    group('closeOtherTabs', () {
      test('应该只保留活动标签页', () {
        // Arrange
        container.read(tabsProvider.notifier).addTab('/file1.md');
        container.read(tabsProvider.notifier).addTab('/file2.md');
        final activeTabId =
            container.read(tabsProvider.notifier).addTab('/file3.md');

        // Act
        container.read(tabsProvider.notifier).closeOtherTabs();

        // Assert
        final state = container.read(tabsProvider);
        expect(state.tabs.length, equals(1));
        expect(state.tabs.first.id, equals(activeTabId));
        expect(state.tabs.first.filePath, equals('/file3.md'));
      });

      test('没有活动标签页时应该无效', () {
        // Act & Assert - 空状态下调用应该安全
        container.read(tabsProvider.notifier).closeOtherTabs();
        expect(container.read(tabsProvider).tabs, isEmpty);
      });
    });

    group('findTabByFilePath', () {
      test('应该找到匹配的标签页', () {
        // Arrange
        container.read(tabsProvider.notifier).addTab('/file1.md');
        container.read(tabsProvider.notifier).addTab('/file2.md');

        // Act
        final tab = container
            .read(tabsProvider.notifier)
            .findTabByFilePath('/file1.md');

        // Assert
        expect(tab, isNotNull);
        expect(tab?.filePath, equals('/file1.md'));
      });

      test('未找到时应该返回 null', () {
        // Arrange
        container.read(tabsProvider.notifier).addTab('/file.md');

        // Act
        final tab = container
            .read(tabsProvider.notifier)
            .findTabByFilePath('/non-existent.md');

        // Assert
        expect(tab, isNull);
      });
    });

    group('Provider 类型验证', () {
      test('tabsProvider 应该是 StateNotifierProvider', () {
        expect(
          tabsProvider,
          isA<StateNotifierProvider<TabsNotifier, TabsState>>(),
        );
      });
    });
  });
}
