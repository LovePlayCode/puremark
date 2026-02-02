import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/tab_item.dart';

/// 标签页状态。
///
/// 包含所有打开的标签页和当前活动标签页的 ID。
class TabsState {
  /// 创建一个标签页状态。
  const TabsState({
    this.tabs = const [],
    this.activeTabId,
  });

  /// 空状态。
  factory TabsState.empty() => const TabsState();

  /// 所有打开的标签页
  final List<TabItem> tabs;

  /// 当前活动标签页的 ID
  final String? activeTabId;

  /// 获取当前活动的标签页。
  TabItem? get activeTab {
    if (activeTabId == null) return null;
    try {
      return tabs.firstWhere((tab) => tab.id == activeTabId);
    } catch (_) {
      return null;
    }
  }

  /// 检查是否有打开的标签页。
  bool get hasTabs => tabs.isNotEmpty;

  /// 获取标签页数量。
  int get tabCount => tabs.length;

  /// 创建此状态的副本，可选择性地更新某些字段。
  TabsState copyWith({
    List<TabItem>? tabs,
    String? activeTabId,
    bool clearActiveTabId = false,
  }) {
    return TabsState(
      tabs: tabs ?? this.tabs,
      activeTabId: clearActiveTabId ? null : (activeTabId ?? this.activeTabId),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TabsState &&
          runtimeType == other.runtimeType &&
          _listEquals(tabs, other.tabs) &&
          activeTabId == other.activeTabId;

  @override
  int get hashCode => tabs.hashCode ^ activeTabId.hashCode;

  bool _listEquals(List<TabItem> a, List<TabItem> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  String toString() =>
      'TabsState(tabs: ${tabs.length}, activeTabId: $activeTabId)';
}

/// 标签页 Provider。
///
/// 使用 StateNotifierProvider 管理标签页状态。
///
/// 使用示例：
/// ```dart
/// // 读取状态
/// final tabsState = ref.watch(tabsProvider);
///
/// // 添加标签
/// ref.read(tabsProvider.notifier).addTab('/path/to/file.md');
///
/// // 关闭标签
/// ref.read(tabsProvider.notifier).closeTab('tab-id');
///
/// // 设置活动标签
/// ref.read(tabsProvider.notifier).setActiveTab('tab-id');
/// ```
final tabsProvider = StateNotifierProvider<TabsNotifier, TabsState>((ref) {
  return TabsNotifier();
});

/// 标签页 Notifier。
///
/// 管理标签页的添加、关闭和活动状态切换。
class TabsNotifier extends StateNotifier<TabsState> {
  /// 创建一个标签页 Notifier。
  TabsNotifier() : super(TabsState.empty());

  final _uuid = const Uuid();

  /// 添加一个新标签页。
  ///
  /// [filePath] 要打开的文件路径
  ///
  /// 如果文件已经在某个标签页中打开，则激活该标签页而不是创建新的。
  /// 返回新创建或激活的标签页的 ID。
  String addTab(String filePath) {
    // 检查是否已经打开了相同文件的标签页
    final existingTab = state.tabs.cast<TabItem?>().firstWhere(
          (tab) => tab?.filePath == filePath,
          orElse: () => null,
        );

    if (existingTab != null) {
      // 激活已存在的标签页
      setActiveTab(existingTab.id);
      return existingTab.id;
    }

    // 创建新标签页
    final newId = _uuid.v4();
    final newTab = TabItem(
      id: newId,
      filePath: filePath,
      isActive: true,
    );

    // 将其他标签页设为非活动
    final updatedTabs = state.tabs.map((tab) {
      return tab.copyWith(isActive: false);
    }).toList();

    // 添加新标签页
    updatedTabs.add(newTab);

    state = state.copyWith(
      tabs: updatedTabs,
      activeTabId: newId,
    );

    return newId;
  }

  /// 关闭指定的标签页。
  ///
  /// [tabId] 要关闭的标签页 ID
  ///
  /// 如果关闭的是活动标签页，会自动激活相邻的标签页：
  /// - 优先激活右侧标签页
  /// - 如果没有右侧标签页，则激活左侧标签页
  /// - 如果是最后一个标签页，则清空活动标签页
  void closeTab(String tabId) {
    final tabIndex = state.tabs.indexWhere((tab) => tab.id == tabId);
    if (tabIndex == -1) return;

    final closingTab = state.tabs[tabIndex];
    final wasActive = closingTab.isActive || state.activeTabId == tabId;

    // 移除标签页
    final updatedTabs = List<TabItem>.from(state.tabs)..removeAt(tabIndex);

    String? newActiveTabId = state.activeTabId;

    if (wasActive && updatedTabs.isNotEmpty) {
      // 确定新的活动标签页
      final newActiveIndex =
          tabIndex < updatedTabs.length ? tabIndex : updatedTabs.length - 1;
      newActiveTabId = updatedTabs[newActiveIndex].id;

      // 更新活动状态
      for (var i = 0; i < updatedTabs.length; i++) {
        updatedTabs[i] = updatedTabs[i].copyWith(
          isActive: i == newActiveIndex,
        );
      }
    } else if (updatedTabs.isEmpty) {
      newActiveTabId = null;
    }

    state = TabsState(
      tabs: updatedTabs,
      activeTabId: newActiveTabId,
    );
  }

  /// 设置活动标签页。
  ///
  /// [tabId] 要激活的标签页 ID
  void setActiveTab(String tabId) {
    if (state.activeTabId == tabId) return;

    final tabIndex = state.tabs.indexWhere((tab) => tab.id == tabId);
    if (tabIndex == -1) return;

    final updatedTabs = state.tabs.map((tab) {
      return tab.copyWith(isActive: tab.id == tabId);
    }).toList();

    state = state.copyWith(
      tabs: updatedTabs,
      activeTabId: tabId,
    );
  }

  /// 关闭所有标签页。
  void closeAllTabs() {
    state = TabsState.empty();
  }

  /// 关闭其他标签页（保留当前活动标签页）。
  void closeOtherTabs() {
    if (state.activeTabId == null) return;

    final activeTab = state.activeTab;
    if (activeTab == null) return;

    state = TabsState(
      tabs: [activeTab.copyWith(isActive: true)],
      activeTabId: activeTab.id,
    );
  }

  /// 根据文件路径查找标签页。
  ///
  /// [filePath] 文件路径
  ///
  /// 返回匹配的标签页，如果未找到则返回 null。
  TabItem? findTabByFilePath(String filePath) {
    try {
      return state.tabs.firstWhere((tab) => tab.filePath == filePath);
    } catch (_) {
      return null;
    }
  }
}
