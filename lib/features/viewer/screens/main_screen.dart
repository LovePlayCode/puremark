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
import '../../../features/settings/providers/settings_provider.dart';
import '../../../features/settings/widgets/settings_panel.dart';
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
  final GlobalKey<WebViewContainerState> _webViewKey = GlobalKey<WebViewContainerState>();

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
    debugPrint('[MainScreen] _toggleSearch called');
    ref.read(searchProvider.notifier).toggleVisibility();
  }

  void _openSettings() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => Consumer(
        builder: (dialogContext, ref, child) {
          final settingsAsync = ref.watch(settingsProvider);
          return settingsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('加载设置失败: $e')),
            data: (settings) => SettingsPanel(
              settings: settings,
              onThemeModeChanged: (mode) =>
                  ref.read(settingsProvider.notifier).setThemeMode(mode),
              onFontSizeIncrement: () =>
                  ref.read(settingsProvider.notifier).increaseFontSize(),
              onFontSizeDecrement: () =>
                  ref.read(settingsProvider.notifier).decreaseFontSize(),
              onAutoRefreshChanged: (_) =>
                  ref.read(settingsProvider.notifier).toggleAutoRefresh(),
              onShowOutlineChanged: (_) =>
                  ref.read(settingsProvider.notifier).toggleShowOutline(),
              onClose: () => Navigator.of(dialogContext).pop(),
            ),
          );
        },
      ),
    );
  }

  /// 是否有已加载的 Markdown 文件（用于决定是否显示大纲）
  bool _hasFileLoaded(AsyncValue<FileState> fileStateAsync) {
    return fileStateAsync.when(
      data: (state) => state.status == FileStatus.loaded,
      loading: () => false,
      error: (_, __) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileStateAsync = ref.watch(fileProvider);
    final tabsState = ref.watch(tabsProvider);
    final outlineState = ref.watch(outlineProvider);
    final searchState = ref.watch(searchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        const SingleActivator(LogicalKeyboardKey.keyO, meta: true): const _OpenFileIntent(),
        const SingleActivator(LogicalKeyboardKey.keyF, meta: true): const _ToggleSearchIntent(),
        const SingleActivator(LogicalKeyboardKey.comma, meta: true): const _OpenSettingsIntent(),
        const SingleActivator(LogicalKeyboardKey.escape): const _CloseSearchIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _OpenFileIntent: CallbackAction<_OpenFileIntent>(
            onInvoke: (_) {
              _openFile();
              return null;
            },
          ),
          _ToggleSearchIntent: CallbackAction<_ToggleSearchIntent>(
            onInvoke: (_) {
              _toggleSearch();
              return null;
            },
          ),
          _OpenSettingsIntent: CallbackAction<_OpenSettingsIntent>(
            onInvoke: (_) {
              _openSettings();
              return null;
            },
          ),
          _CloseSearchIntent: CallbackAction<_CloseSearchIntent>(
            onInvoke: (_) {
              if (searchState.isVisible) {
                ref.read(searchProvider.notifier).toggleVisibility();
              }
              return null;
            },
          ),
        },
        child: Scaffold(
          backgroundColor: isDark
              ? AppColors.darkBgPrimary
              : AppColors.lightBgPrimary,
          body: Focus(
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
                  // 搜索选项回调
                  onToggleCaseSensitive: () {
                    ref.read(searchProvider.notifier).toggleCaseSensitive();
                  },
                  onToggleWholeWord: () {
                    ref.read(searchProvider.notifier).toggleWholeWord();
                  },
                ),
              // 主内容区
              Expanded(
                child: Row(
                  children: [
                    // 大纲侧边栏（仅在有文件加载时显示）
                    if (_isOutlineVisible && _hasFileLoaded(fileStateAsync))
                      OutlineSidebar(
                        headings: outlineState.headings,
                        activeHeadingId: outlineState.activeHeadingId,
                        isCollapsed: false,
                        onToggleCollapse: _toggleOutline,
                        onHeadingTap: (heading) {
                          ref.read(outlineProvider.notifier).setActiveHeading(heading.id);
                          _webViewKey.currentState?.scrollToHeading(heading.id);
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
        final searchState = ref.watch(searchProvider);
        debugPrint('[MainScreen] Rendering loaded state, content length: ${fileState.content?.length ?? 0}');
        return WebViewContainer(
          key: _webViewKey,
          content: fileState.content ?? '',
          isDarkMode: isDark,
          searchQuery: searchState.query,
          currentMatch: searchState.currentMatch,
          searchOptions: searchState.options,         // 搜索选项
          searchVersion: searchState.searchVersion,   // 搜索版本号
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
          onSearchResults: (totalMatches, version) {  // 更新签名，添加 version 参数
            debugPrint('[MainScreen] onSearchResults: $totalMatches, version: $version');
            ref.read(searchProvider.notifier).setMatches(totalMatches, version: version);
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

// Intent 类定义
class _OpenFileIntent extends Intent {
  const _OpenFileIntent();
}

class _ToggleSearchIntent extends Intent {
  const _ToggleSearchIntent();
}

class _OpenSettingsIntent extends Intent {
  const _OpenSettingsIntent();
}

class _CloseSearchIntent extends Intent {
  const _CloseSearchIntent();
}
