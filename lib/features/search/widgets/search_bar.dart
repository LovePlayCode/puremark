import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../models/search_state.dart';

/// 搜索栏 Widget。
///
/// 提供搜索输入框、匹配计数显示和导航按钮。
///
/// 使用示例：
/// ```dart
/// SearchBarWidget(
///   searchState: SearchState(query: 'test', totalMatches: 5, currentMatch: 2),
///   onQueryChanged: (query) => handleSearch(query),
///   onNextMatch: () => goToNextMatch(),
///   onPreviousMatch: () => goToPreviousMatch(),
///   onClose: () => hideSearchBar(),
/// )
/// ```
class SearchBarWidget extends StatefulWidget {
  /// 创建一个搜索栏。
  const SearchBarWidget({
    super.key,
    required this.searchState,
    this.onQueryChanged,
    this.onNextMatch,
    this.onPreviousMatch,
    this.onClose,
  });

  /// 搜索状态
  final SearchState searchState;

  /// 查询词变化回调
  final void Function(String query)? onQueryChanged;

  /// 下一个匹配回调
  final VoidCallback? onNextMatch;

  /// 上一个匹配回调
  final VoidCallback? onPreviousMatch;

  /// 关闭回调
  final VoidCallback? onClose;

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.searchState.query);
    _focusNode = FocusNode();

    // 自动聚焦
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void didUpdateWidget(SearchBarWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchState.query != widget.searchState.query) {
      _controller.text = widget.searchState.query;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (HardwareKeyboard.instance.isShiftPressed) {
          widget.onPreviousMatch?.call();
        } else {
          widget.onNextMatch?.call();
        }
      } else if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onClose?.call();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // 颜色定义
    final backgroundColor =
        isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor =
        isDark ? AppColors.darkBorderPrimary : AppColors.lightBorderPrimary;

    return KeyboardListener(
      focusNode: FocusNode(),
      onKeyEvent: _handleKeyEvent,
      child: Container(
        key: const Key('searchBar'),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            // 搜索图标
            Icon(
              Icons.search,
              size: 18,
              color: secondaryTextColor,
            ),
            const SizedBox(width: 8),

            // 搜索输入框
            Expanded(
              child: TextField(
                key: const Key('searchInput'),
                controller: _controller,
                focusNode: _focusNode,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '搜索...',
                  hintStyle: TextStyle(color: secondaryTextColor),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: widget.onQueryChanged,
                onSubmitted: (_) => widget.onNextMatch?.call(),
              ),
            ),

            // 匹配计数
            if (widget.searchState.query.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                widget.searchState.matchCountText,
                key: const Key('matchCount'),
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],

            // 导航按钮
            if (widget.searchState.hasMatches) ...[
              const SizedBox(width: 4),
              _buildIconButton(
                key: const Key('previousButton'),
                icon: Icons.keyboard_arrow_up,
                tooltip: '上一个 (Shift+Enter)',
                onPressed: widget.onPreviousMatch,
                color: secondaryTextColor,
              ),
              _buildIconButton(
                key: const Key('nextButton'),
                icon: Icons.keyboard_arrow_down,
                tooltip: '下一个 (Enter)',
                onPressed: widget.onNextMatch,
                color: secondaryTextColor,
              ),
            ],

            // 关闭按钮
            const SizedBox(width: 4),
            _buildIconButton(
              key: const Key('closeButton'),
              icon: Icons.close,
              tooltip: '关闭 (Esc)',
              onPressed: widget.onClose,
              color: secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required Key key,
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    required Color color,
  }) {
    return IconButton(
      key: key,
      icon: Icon(icon, size: 18, color: color),
      onPressed: onPressed,
      tooltip: tooltip,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(
        minWidth: 28,
        minHeight: 28,
      ),
      splashRadius: 14,
    );
  }
}
