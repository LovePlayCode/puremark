/// 搜索选项（参考 VS Code 的 IEditorFindOptions）。
///
/// 用于配置搜索行为，包括大小写敏感、整词匹配和正则表达式。
///
/// 使用示例：
/// ```dart
/// final options = SearchOptions(
///   caseSensitive: true,
///   wholeWord: false,
///   useRegex: false,
/// );
/// ```
class SearchOptions {
  /// 创建搜索选项实例。
  const SearchOptions({
    this.caseSensitive = false,
    this.wholeWord = false,
    this.useRegex = false,
  });

  /// 大小写敏感 (VS Code: matchCase)
  final bool caseSensitive;

  /// 整词匹配 (VS Code: wholeWord)
  final bool wholeWord;

  /// 正则表达式 (VS Code: isRegex)
  final bool useRegex;

  /// 创建默认搜索选项。
  factory SearchOptions.defaults() => const SearchOptions();

  /// 创建一个新的 SearchOptions 副本，可选择性地更新某些字段。
  SearchOptions copyWith({
    bool? caseSensitive,
    bool? wholeWord,
    bool? useRegex,
  }) {
    return SearchOptions(
      caseSensitive: caseSensitive ?? this.caseSensitive,
      wholeWord: wholeWord ?? this.wholeWord,
      useRegex: useRegex ?? this.useRegex,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchOptions &&
        other.caseSensitive == caseSensitive &&
        other.wholeWord == wholeWord &&
        other.useRegex == useRegex;
  }

  @override
  int get hashCode {
    return Object.hash(caseSensitive, wholeWord, useRegex);
  }

  @override
  String toString() {
    return 'SearchOptions(caseSensitive: $caseSensitive, '
        'wholeWord: $wholeWord, useRegex: $useRegex)';
  }
}

/// 搜索状态实体类。
///
/// 用于管理搜索功能的状态信息，包括查询词、匹配数量、当前匹配位置、
/// 加载状态、搜索版本号和搜索选项。
///
/// 使用示例：
/// ```dart
/// final state = SearchState(
///   query: 'flutter',
///   totalMatches: 12,
///   currentMatch: 3,
///   isVisible: true,
///   isLoading: false,
///   searchVersion: 1,
///   options: SearchOptions(caseSensitive: true),
/// );
/// ```
class SearchState {
  /// 创建一个搜索状态实例。
  const SearchState({
    this.query = '',
    this.totalMatches = 0,
    this.currentMatch = 0,
    this.isVisible = false,
    this.isLoading = false,
    this.searchVersion = 0,
    SearchOptions? options,
  }) : options = options ?? const SearchOptions();

  /// 匹配数量限制（参考 VS Code）
  static const int matchesLimit = 9999;

  /// 搜索查询词
  final String query;

  /// 总匹配数量
  final int totalMatches;

  /// 当前匹配位置（1-indexed，0 表示无匹配）
  final int currentMatch;

  /// 搜索栏是否可见
  final bool isVisible;

  /// 搜索加载状态
  final bool isLoading;

  /// 搜索版本号（用于防止竞态条件）
  final int searchVersion;

  /// 搜索选项
  final SearchOptions options;

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
    bool? isLoading,
    int? searchVersion,
    SearchOptions? options,
  }) {
    return SearchState(
      query: query ?? this.query,
      totalMatches: totalMatches ?? this.totalMatches,
      currentMatch: currentMatch ?? this.currentMatch,
      isVisible: isVisible ?? this.isVisible,
      isLoading: isLoading ?? this.isLoading,
      searchVersion: searchVersion ?? this.searchVersion,
      options: options ?? this.options,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchState &&
        other.query == query &&
        other.totalMatches == totalMatches &&
        other.currentMatch == currentMatch &&
        other.isVisible == isVisible &&
        other.isLoading == isLoading &&
        other.searchVersion == searchVersion &&
        other.options == options;
  }

  @override
  int get hashCode {
    return Object.hash(
      query,
      totalMatches,
      currentMatch,
      isVisible,
      isLoading,
      searchVersion,
      options,
    );
  }

  @override
  String toString() {
    return 'SearchState(query: $query, totalMatches: $totalMatches, '
        'currentMatch: $currentMatch, isVisible: $isVisible, '
        'isLoading: $isLoading, searchVersion: $searchVersion, '
        'options: $options)';
  }
}
