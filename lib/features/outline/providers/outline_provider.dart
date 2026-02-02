import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/heading.dart';

/// 大纲状态实体类。
///
/// 包含标题列表和当前活动标题。
class OutlineState {
  /// 创建一个大纲状态实例。
  const OutlineState({
    this.headings = const [],
    this.activeHeadingId,
  });

  /// 标题列表
  final List<Heading> headings;

  /// 当前活动标题 ID
  final String? activeHeadingId;

  /// 创建一个空的大纲状态。
  factory OutlineState.empty() {
    return const OutlineState();
  }

  /// 创建一个新的 OutlineState 副本，可选择性地更新某些字段。
  OutlineState copyWith({
    List<Heading>? headings,
    String? activeHeadingId,
    bool clearActiveHeading = false,
  }) {
    return OutlineState(
      headings: headings ?? this.headings,
      activeHeadingId:
          clearActiveHeading ? null : (activeHeadingId ?? this.activeHeadingId),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! OutlineState) return false;
    if (other.headings.length != headings.length) return false;
    for (var i = 0; i < headings.length; i++) {
      if (headings[i] != other.headings[i]) return false;
    }
    return other.activeHeadingId == activeHeadingId;
  }

  @override
  int get hashCode {
    return Object.hash(Object.hashAll(headings), activeHeadingId);
  }

  @override
  String toString() {
    return 'OutlineState(headings: ${headings.length} items, '
        'activeHeadingId: $activeHeadingId)';
  }
}

/// 大纲状态 Provider。
///
/// 使用 StateNotifierProvider 管理文档大纲的标题列表和活动状态。
///
/// 使用示例：
/// ```dart
/// // 读取当前大纲状态
/// final outlineState = ref.watch(outlineProvider);
///
/// // 设置标题列表
/// ref.read(outlineProvider.notifier).setHeadings(headings);
///
/// // 设置活动标题
/// ref.read(outlineProvider.notifier).setActiveHeading('heading-1');
/// ```
final outlineProvider = StateNotifierProvider<OutlineNotifier, OutlineState>(
  (ref) => OutlineNotifier(),
);

/// 大纲状态 Notifier。
///
/// 管理标题列表的设置、活动标题的切换和清除操作。
class OutlineNotifier extends StateNotifier<OutlineState> {
  /// 创建一个大纲状态 Notifier。
  OutlineNotifier() : super(OutlineState.empty());

  /// 设置标题列表。
  ///
  /// [headings] 新的标题列表
  void setHeadings(List<Heading> headings) {
    state = state.copyWith(headings: headings);
  }

  /// 设置当前活动标题。
  ///
  /// [headingId] 要激活的标题 ID，可以为 null 表示清除活动状态
  void setActiveHeading(String? headingId) {
    if (headingId == null) {
      state = state.copyWith(clearActiveHeading: true);
    } else {
      state = state.copyWith(activeHeadingId: headingId);
    }
  }

  /// 清除所有标题和活动状态。
  void clearHeadings() {
    state = OutlineState.empty();
  }
}
