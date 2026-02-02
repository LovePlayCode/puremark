import 'dart:math' show min;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_state.dart';

/// 搜索状态 Provider。
///
/// 使用 StateNotifierProvider 管理搜索功能的状态。
///
/// 使用示例：
/// ```dart
/// // 读取当前搜索状态
/// final searchState = ref.watch(searchProvider);
///
/// // 设置搜索查询词
/// ref.read(searchProvider.notifier).setQuery('flutter');
///
/// // 导航到下一个匹配
/// ref.read(searchProvider.notifier).nextMatch();
/// ```
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>(
  (ref) => SearchNotifier(),
);

/// 搜索输入 Provider（即时响应用户输入）。
///
/// 用于临时存储用户输入，与 [debouncedSearchProvider] 配合使用。
final searchInputProvider = StateProvider<String>((ref) => '');

/// 搜索选项 Provider。
final searchOptionsProvider = StateProvider<SearchOptions>(
  (ref) => const SearchOptions(),
);

/// 搜索状态 Notifier。
///
/// 管理搜索查询、匹配导航和可见性切换。
class SearchNotifier extends StateNotifier<SearchState> {
  /// 创建一个搜索状态 Notifier。
  SearchNotifier() : super(SearchState.empty());

  /// 内部搜索版本号，用于防止竞态条件
  int _searchVersion = 0;

  /// 获取当前搜索版本号。
  int get currentVersion => _searchVersion;

  /// 设置搜索查询词。
  ///
  /// 会递增搜索版本号并设置加载状态。
  void setQuery(String query) {
    if (state.query == query) return;

    _searchVersion++;
    state = state.copyWith(
      query: query,
      searchVersion: _searchVersion,
      isLoading: query.isNotEmpty, // 只有非空查询才设置加载状态
      totalMatches: 0,
      currentMatch: 0,
    );
  }

  /// 设置匹配数量。
  ///
  /// [totalMatches] 总匹配数量
  /// [currentMatch] 当前匹配位置，默认为 1（如果有匹配）
  /// [version] 搜索版本号，用于验证结果是否过期
  void setMatches(int totalMatches, {int? currentMatch, int? version}) {
    // 如果提供了版本号且不匹配当前版本，忽略过期结果
    if (version != null && version != _searchVersion) {
      debugPrint(
        '[SearchProvider] Ignoring stale search results: '
        'version $version != $_searchVersion',
      );
      return;
    }

    // 限制匹配数量
    final limitedMatches = totalMatches.clamp(0, SearchState.matchesLimit);

    state = state.copyWith(
      totalMatches: limitedMatches,
      currentMatch: currentMatch ?? (limitedMatches > 0 ? 1 : 0),
      isLoading: false,
    );
  }

  /// 导航到下一个匹配。
  ///
  /// 如果当前是最后一个匹配，则循环到第一个。
  void nextMatch() {
    if (state.totalMatches == 0) return;

    final next = state.currentMatch >= state.totalMatches
        ? 1
        : state.currentMatch + 1;

    state = state.copyWith(currentMatch: next);
  }

  /// 导航到上一个匹配。
  ///
  /// 如果当前是第一个匹配，则循环到最后一个。
  void previousMatch() {
    if (state.totalMatches == 0) return;

    final prev = state.currentMatch <= 1
        ? state.totalMatches
        : state.currentMatch - 1;

    state = state.copyWith(currentMatch: prev);
  }

  /// 清除搜索状态。
  void clearSearch() {
    _searchVersion++; // 递增版本号，使任何进行中的搜索结果失效
    state = SearchState.empty();
  }

  /// 更新搜索选项。
  void updateOptions(SearchOptions options) {
    if (state.options == options) return;

    _searchVersion++;
    state = state.copyWith(
      options: options,
      searchVersion: _searchVersion,
      isLoading: state.query.isNotEmpty,
      totalMatches: 0,
      currentMatch: 0,
    );
  }

  /// 切换大小写敏感选项。
  void toggleCaseSensitive() {
    updateOptions(state.options.copyWith(
      caseSensitive: !state.options.caseSensitive,
    ));
  }

  /// 切换整词匹配选项。
  void toggleWholeWord() {
    updateOptions(state.options.copyWith(
      wholeWord: !state.options.wholeWord,
    ));
  }

  /// 切换正则表达式选项。
  void toggleUseRegex() {
    updateOptions(state.options.copyWith(
      useRegex: !state.options.useRegex,
    ));
  }

  /// 切换搜索栏可见性。
  void toggleVisibility() {
    final newVisibility = !state.isVisible;
    debugPrint(
      '[SearchProvider] toggleVisibility: ${state.isVisible} -> $newVisibility',
    );
    state = state.copyWith(isVisible: newVisibility);
  }

  /// 显示搜索栏。
  void show() {
    state = state.copyWith(isVisible: true);
  }

  /// 隐藏搜索栏。
  void hide() {
    state = state.copyWith(isVisible: false);
  }
}
