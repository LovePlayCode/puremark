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

/// 搜索状态 Notifier。
///
/// 管理搜索查询、匹配导航和可见性切换。
class SearchNotifier extends StateNotifier<SearchState> {
  /// 创建一个搜索状态 Notifier。
  SearchNotifier() : super(SearchState.empty());

  /// 设置搜索查询词。
  ///
  /// [query] 新的查询词
  void setQuery(String query) {
    state = state.copyWith(
      query: query,
      // 清除匹配状态，等待外部设置新的匹配数
      totalMatches: 0,
      currentMatch: 0,
    );
  }

  /// 设置匹配数量。
  ///
  /// [totalMatches] 总匹配数量
  /// [currentMatch] 当前匹配位置，默认为 1（如果有匹配）
  void setMatches(int totalMatches, {int? currentMatch}) {
    state = state.copyWith(
      totalMatches: totalMatches,
      currentMatch: currentMatch ?? (totalMatches > 0 ? 1 : 0),
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
    state = SearchState.empty();
  }

  /// 切换搜索栏可见性。
  void toggleVisibility() {
    state = state.copyWith(isVisible: !state.isVisible);
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
