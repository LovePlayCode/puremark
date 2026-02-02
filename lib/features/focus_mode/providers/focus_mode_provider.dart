import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 专注模式状态。
///
/// 包含专注模式的启用状态和阅读进度。
///
/// 使用示例：
/// ```dart
/// final state = FocusModeState(
///   isEnabled: true,
///   readingProgress: 0.5,
/// );
/// ```
class FocusModeState {
  /// 创建一个专注模式状态实例。
  const FocusModeState({
    this.isEnabled = false,
    this.readingProgress = 0.0,
  });

  /// 是否启用专注模式
  final bool isEnabled;

  /// 阅读进度（0.0-1.0）
  final double readingProgress;

  /// 阅读进度百分比（0-100）
  int get readingProgressPercent => (readingProgress * 100).round();

  /// 创建一个新的 FocusModeState 副本，可选择性地更新某些字段。
  FocusModeState copyWith({
    bool? isEnabled,
    double? readingProgress,
  }) {
    return FocusModeState(
      isEnabled: isEnabled ?? this.isEnabled,
      readingProgress: readingProgress ?? this.readingProgress,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FocusModeState &&
        other.isEnabled == isEnabled &&
        other.readingProgress == readingProgress;
  }

  @override
  int get hashCode => Object.hash(isEnabled, readingProgress);

  @override
  String toString() {
    return 'FocusModeState(isEnabled: $isEnabled, '
        'readingProgress: $readingProgress)';
  }
}

/// 专注模式 Provider。
///
/// 使用 StateNotifierProvider 管理专注模式状态。
///
/// 使用示例：
/// ```dart
/// // 读取当前专注模式状态
/// final focusState = ref.watch(focusModeProvider);
///
/// // 进入专注模式
/// ref.read(focusModeProvider.notifier).enterFocusMode();
///
/// // 更新阅读进度
/// ref.read(focusModeProvider.notifier).updateProgress(0.5);
/// ```
final focusModeProvider =
    StateNotifierProvider<FocusModeNotifier, FocusModeState>(
  (ref) => FocusModeNotifier(),
);

/// 专注模式状态 Notifier。
///
/// 管理专注模式的进入、退出和阅读进度更新。
class FocusModeNotifier extends StateNotifier<FocusModeState> {
  /// 创建一个专注模式状态 Notifier。
  FocusModeNotifier() : super(const FocusModeState());

  /// 进入专注模式。
  ///
  /// 启用专注模式并重置阅读进度为 0。
  void enterFocusMode() {
    state = state.copyWith(
      isEnabled: true,
      readingProgress: 0.0,
    );
  }

  /// 退出专注模式。
  ///
  /// 禁用专注模式并重置阅读进度为 0。
  void exitFocusMode() {
    state = state.copyWith(
      isEnabled: false,
      readingProgress: 0.0,
    );
  }

  /// 更新阅读进度。
  ///
  /// [progress] 阅读进度值，会被限制在 0.0-1.0 之间。
  void updateProgress(double progress) {
    final clampedProgress = progress.clamp(0.0, 1.0);
    state = state.copyWith(readingProgress: clampedProgress);
  }

  /// 重置阅读进度为 0。
  void resetProgress() {
    state = state.copyWith(readingProgress: 0.0);
  }

  /// 切换专注模式。
  ///
  /// 如果当前启用则退出，否则进入。
  void toggleFocusMode() {
    if (state.isEnabled) {
      exitFocusMode();
    } else {
      enterFocusMode();
    }
  }
}
