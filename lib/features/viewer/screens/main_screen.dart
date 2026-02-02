import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/theme/app_colors.dart';
import '../../../features/outline/models/heading.dart';
import '../../../features/outline/providers/outline_provider.dart';
import '../../../features/outline/widgets/outline_sidebar.dart';
import '../../../features/search/providers/search_provider.dart';
import '../../../features/search/widgets/search_bar.dart';
import '../../../features/tabs/providers/tabs_provider.dart';
import '../../../features/tabs/widgets/tab_bar.dart';
import '../providers/file_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_state.dart';
import '../widgets/webview_container.dart';
import '../models/file_state.dart';

/// PureMark 主屏幕
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  bool _isOutlineVisible = true;

  Future<void> _openFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['md', 'markdown'],
    );

    if (result != null && result.files.single.path != null) {
      final filePath = result.files.single.path!;
      ref.read(tabsProvider.notifier).addTab(filePath);
      await ref.read(fileProvider.notifier).openFile(filePath);
    }
  }

  void _toggleOutline() {
    setState(() {
      _isOutlineVisible = !_isOutlineVisible;
    });
  }

  void _toggleSearch() {
    ref.read(searchProvider.notifier).toggleVisibility();
  }

  @override
  Widget build(BuildContext context) {
    final fileStateAsync = ref.watch(fileProvider);
    final tabsState = ref.watch(tabsProvider);
    final outlineState = ref.watch(outlineProvider);
    final searchState = ref.watch(searchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBgPrimary
          : AppColors.lightBgPrimary,
      body: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.keyO, meta: true): _openFile,
          const SingleActivator(LogicalKeyboardKey.keyF, meta: true): _toggleSearch,
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (searchState.isVisible) {
              ref.read(searchProvider.notifier).toggleVisibility();
            }
          },
        },
        child: Focus(
          autofocus: true,
          child: Column(
            children: [
              // 标签栏
              StandaloneTabBar(
                tabs: tabsState.tabs,
                activeTabId: tabsState.activeTabId,
                onTabSelected: (tab) {
                  ref.read(tabsProvider.notifier).setActiveTab(tab.id);
                  ref.read(fileProvider.notifier).openFile(tab.filePath);
                },
                onTabClosed: (tab) {
                  ref.read(tabsProvider.notifier).closeTab(tab.id);
                  if (tabsState.tabs.length <= 1) {
                    ref.read(fileProvider.notifier).closeFile();
                  }
                },
                onNewTab: _openFile,
              ),
              // 搜索栏
              if (searchState.isVisible)
                SearchBarWidget(
                  searchState: searchState,
                  onQueryChanged: (query) {
                    ref.read(searchProvider.notifier).setQuery(query);
                  },
                  onNextMatch: () {
                    ref.read(searchProvider.notifier).nextMatch();
                  },
                  onPreviousMatch: () {
                    ref.read(searchProvider.notifier).previousMatch();
                  },
                  onClose: _toggleSearch,
                ),
              // 主内容区
              Expanded(
                child: Row(
                  children: [
                    // 大纲侧边栏
                    if (_isOutlineVisible)
                      OutlineSidebar(
                        headings: outlineState.headings,
                        activeHeadingId: outlineState.activeHeadingId,
                        isCollapsed: false,
                        onToggleCollapse: _toggleOutline,
                        onHeadingTap: (heading) {
                          ref.read(outlineProvider.notifier).setActiveHeading(heading.id);
                        },
                      ),
                    // 内容区
                    Expanded(
                      child: fileStateAsync.when(
                        data: (fileState) => _buildContent(fileState),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => Center(
                          child: Text(
                            'Error: $error',
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(FileState fileState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    switch (fileState.status) {
      case FileStatus.empty:
        return EmptyState(
          onOpenFile: _openFile,
        );

      case FileStatus.loading:
        return const LoadingState();

      case FileStatus.loaded:
        debugPrint('[MainScreen] Rendering loaded state, content length: ${fileState.content?.length ?? 0}');
        return WebViewContainer(
          content: fileState.content ?? '',
          isDarkMode: isDark,
          onOutlineGenerated: (items) {
            debugPrint('[MainScreen] onOutlineGenerated: ${items.length} items');
            final headings = items.map((item) => Heading(
              id: item.id,
              text: item.text,
              level: item.level,
            )).toList();
            ref.read(outlineProvider.notifier).setHeadings(headings);
          },
          onLinkClicked: (url) {
            debugPrint('Link clicked: $url');
          },
        );

      case FileStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.trafficRed,
              ),
              const SizedBox(height: 16),
              Text(
                fileState.errorMessage ?? '加载失败',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        );
    }
  }
}
