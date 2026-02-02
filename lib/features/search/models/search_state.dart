/// 搜索状态实体类。
///
/// 用于管理搜索功能的状态信息，包括查询词、匹配数量和当前匹配位置。
///
/// 使用示例：
/// ```dart
/// final state = SearchState(
///   query: 'flutter',
///   totalMatches: 12,
///   currentMatch: 3,
///   isVisible: true,
/// );
/// ```
class SearchState {
  /// 创建一个搜索状态实例。
  const SearchState({
    this.query = '',
    this.totalMatches = 0,
    this.currentMatch = 0,
    this.isVisible = false,
  });

  /// 搜索查询词
  final String query;

  /// 总匹配数量
  final int totalMatches;

  /// 当前匹配位置（1-indexed，0 表示无匹配）
  final int currentMatch;

  /// 搜索栏是否可见
  final bool isVisible;

  /// 是否有匹配结果。
  bool get hasMatches => totalMatches > 0;

  /// 格式化的匹配计数显示文本（如 "3 of 12"）。
  String get matchCountText {
    if (totalMatches == 0) {
      return '无匹配';
    }
    return '$currentMatch of $totalMatches';
  }

  /// 创建一个空的搜索状态。
  factory SearchState.empty() {
    return const SearchState();
  }

  /// 创建一个新的 SearchState 副本，可选择性地更新某些字段。
  SearchState copyWith({
    String? query,
    int? totalMatches,
    int? currentMatch,
    bool? isVisible,
  }) {
    return SearchState(
      query: query ?? this.query,
      totalMatches: totalMatches ?? this.totalMatches,
      currentMatch: currentMatch ?? this.currentMatch,
      isVisible: isVisible ?? this.isVisible,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchState &&
        other.query == query &&
        other.totalMatches == totalMatches &&
        other.currentMatch == currentMatch &&
        other.isVisible == isVisible;
  }

  @override
  int get hashCode {
    return Object.hash(query, totalMatches, currentMatch, isVisible);
  }

  @override
  String toString() {
    return 'SearchState(query: $query, totalMatches: $totalMatches, '
        'currentMatch: $currentMatch, isVisible: $isVisible)';
  }
}
