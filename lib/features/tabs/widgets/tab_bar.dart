import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../models/tab_item.dart';
import '../providers/tabs_provider.dart';
import 'tab_item.dart';

/// 标签栏 Widget。
///
/// 显示所有打开的标签页，支持切换、关闭和新建标签。
///
/// 使用示例：
/// ```dart
/// TabBarWidget(
///   onNewTab: () {
///     // 打开文件选择器
///   },
/// )
/// ```
class TabBarWidget extends ConsumerWidget {
  /// 创建一个标签栏 Widget。
  const TabBarWidget({
    super.key,
    this.onNewTab,
    this.onTabSelected,
    this.onTabClosed,
  });

  /// 新建标签回调
  final VoidCallback? onNewTab;

  /// 标签选中回调
  final void Function(TabItem tab)? onTabSelected;

  /// 标签关闭回调
  final void Function(TabItem tab)? onTabClosed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabsState = ref.watch(tabsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const Key('tabBarContainer'),
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface,
        border: Border(
          bottom: BorderSide(
            color:
                isDark ? AppColors.darkBorderDivider : AppColors.lightBorderDivider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 标签列表
          Expanded(
            child: tabsState.tabs.isEmpty
                ? const SizedBox.shrink()
                : ListView.separated(
                    key: const Key('tabBarList'),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 8, top: 0),
                    itemCount: tabsState.tabs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 2),
                    itemBuilder: (context, index) {
                      final tab = tabsState.tabs[index];
                      return TabItemWidget(
                        key: Key('tab_${tab.id}'),
                        title: tab.title,
                        isActive: tab.id == tabsState.activeTabId,
                        onTap: () {
                          ref.read(tabsProvider.notifier).setActiveTab(tab.id);
                          onTabSelected?.call(tab);
                        },
                        onClose: () {
                          ref.read(tabsProvider.notifier).closeTab(tab.id);
                          onTabClosed?.call(tab);
                        },
                      );
                    },
                  ),
          ),
          // 新建标签按钮
          _NewTabButton(
            onTap: onNewTab,
          ),
        ],
      ),
    );
  }
}

/// 新建标签按钮。
class _NewTabButton extends StatefulWidget {
  const _NewTabButton({
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  State<_NewTabButton> createState() => _NewTabButtonState();
}

class _NewTabButtonState extends State<_NewTabButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          key: const Key('newTabButton'),
          width: 36,
          height: 36,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: _isHovered
                ? (isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated)
                : Colors.transparent,
          ),
          child: Center(
            child: Text(
              '+',
              style: TextStyle(
                fontSize: 20,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 独立的标签栏 Widget（不依赖 Provider）。
///
/// 用于测试或自定义场景，可以直接传入标签列表。
///
/// 使用示例：
/// ```dart
/// StandaloneTabBar(
///   tabs: [
///     TabItem(id: '1', filePath: '/path/file.md'),
///   ],
///   activeTabId: '1',
///   onTabSelected: (tab) => print('Selected: ${tab.title}'),
///   onTabClosed: (tab) => print('Closed: ${tab.title}'),
///   onNewTab: () => print('New tab'),
/// )
/// ```
class StandaloneTabBar extends StatelessWidget {
  /// 创建一个独立的标签栏 Widget。
  const StandaloneTabBar({
    super.key,
    required this.tabs,
    this.activeTabId,
    this.onTabSelected,
    this.onTabClosed,
    this.onNewTab,
  });

  /// 标签页列表
  final List<TabItem> tabs;

  /// 活动标签页 ID
  final String? activeTabId;

  /// 标签选中回调
  final void Function(TabItem tab)? onTabSelected;

  /// 标签关闭回调
  final void Function(TabItem tab)? onTabClosed;

  /// 新建标签回调
  final VoidCallback? onNewTab;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const Key('standaloneTabBarContainer'),
      height: 36,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface,
        border: Border(
          bottom: BorderSide(
            color:
                isDark ? AppColors.darkBorderDivider : AppColors.lightBorderDivider,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 标签列表
          Expanded(
            child: tabs.isEmpty
                ? const SizedBox.shrink()
                : ListView.separated(
                    key: const Key('standaloneTabBarList'),
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.only(left: 8, top: 0),
                    itemCount: tabs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 2),
                    itemBuilder: (context, index) {
                      final tab = tabs[index];
                      return TabItemWidget(
                        key: Key('standalone_tab_${tab.id}'),
                        title: tab.title,
                        isActive: tab.id == activeTabId,
                        onTap: () => onTabSelected?.call(tab),
                        onClose: () => onTabClosed?.call(tab),
                      );
                    },
                  ),
          ),
          // 新建标签按钮
          _NewTabButton(
            onTap: onNewTab,
          ),
        ],
      ),
    );
  }
}
