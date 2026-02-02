import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../models/settings_state.dart';

/// 设置面板 Widget。
///
/// 模态弹窗形式显示设置选项，包括主题切换、字号调节、自动刷新和显示大纲开关。
///
/// 使用示例：
/// ```dart
/// showDialog(
///   context: context,
///   builder: (context) => SettingsPanel(
///     settings: settingsState,
///     onThemeModeChanged: (mode) => updateTheme(mode),
///     onFontSizeChanged: (size) => updateFontSize(size),
///     onAutoRefreshChanged: (value) => updateAutoRefresh(value),
///     onShowOutlineChanged: (value) => updateShowOutline(value),
///     onClose: () => Navigator.pop(context),
///   ),
/// );
/// ```
class SettingsPanel extends StatelessWidget {
  /// 创建一个设置面板。
  const SettingsPanel({
    super.key,
    required this.settings,
    this.onThemeModeChanged,
    this.onFontSizeIncrement,
    this.onFontSizeDecrement,
    this.onAutoRefreshChanged,
    this.onShowOutlineChanged,
    this.onClose,
  });

  /// 当前设置状态
  final SettingsState settings;

  /// 主题模式变更回调
  final void Function(ThemeMode mode)? onThemeModeChanged;

  /// 字号增加回调
  final VoidCallback? onFontSizeIncrement;

  /// 字号减少回调
  final VoidCallback? onFontSizeDecrement;

  /// 自动刷新变更回调
  final void Function(bool value)? onAutoRefreshChanged;

  /// 显示大纲变更回调
  final void Function(bool value)? onShowOutlineChanged;

  /// 关闭回调
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    // 颜色定义
    final backgroundColor =
        isDark ? AppColors.darkBgSurface : AppColors.lightBgSurface;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final secondaryTextColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final borderColor =
        isDark ? AppColors.darkBorderPrimary : AppColors.lightBorderPrimary;
    final elevatedBg =
        isDark ? AppColors.darkBgElevated : AppColors.lightBgElevated;

    return Dialog(
      key: const Key('settingsPanel'),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 标题栏
            _buildHeader(textColor),
            const SizedBox(height: 24),

            // 主题切换
            _buildThemeSection(
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
              borderColor: borderColor,
              elevatedBg: elevatedBg,
            ),
            const SizedBox(height: 20),

            // 字号调节
            _buildFontSizeSection(
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
              borderColor: borderColor,
              elevatedBg: elevatedBg,
            ),
            const SizedBox(height: 20),

            // 开关选项
            _buildSwitchSection(
              textColor: textColor,
              secondaryTextColor: secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  /// 构建标题栏。
  Widget _buildHeader(Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '设置',
          key: const Key('settingsTitle'),
          style: TextStyle(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          key: const Key('closeButton'),
          icon: Icon(Icons.close, color: textColor, size: 20),
          onPressed: onClose,
          tooltip: '关闭',
        ),
      ],
    );
  }

  /// 构建主题切换部分。
  Widget _buildThemeSection({
    required Color textColor,
    required Color secondaryTextColor,
    required Color borderColor,
    required Color elevatedBg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '主题',
          key: const Key('themeLabel'),
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          key: const Key('themeSelector'),
          decoration: BoxDecoration(
            color: elevatedBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            children: [
              _buildThemeOption(
                key: const Key('themeDark'),
                label: '深色',
                mode: ThemeMode.dark,
                isSelected: settings.themeMode == ThemeMode.dark,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildThemeOption(
                key: const Key('themeLight'),
                label: '亮色',
                mode: ThemeMode.light,
                isSelected: settings.themeMode == ThemeMode.light,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
              _buildThemeOption(
                key: const Key('themeSystem'),
                label: '跟随系统',
                mode: ThemeMode.system,
                isSelected: settings.themeMode == ThemeMode.system,
                textColor: textColor,
                secondaryTextColor: secondaryTextColor,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建主题选项。
  Widget _buildThemeOption({
    required Key key,
    required String label,
    required ThemeMode mode,
    required bool isSelected,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Expanded(
      child: GestureDetector(
        key: key,
        onTap: () => onThemeModeChanged?.call(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.accentPrimary.withOpacity(0.2) : null,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.accentPrimary : secondaryTextColor,
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  /// 构建字号调节部分。
  Widget _buildFontSizeSection({
    required Color textColor,
    required Color secondaryTextColor,
    required Color borderColor,
    required Color elevatedBg,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '字号',
          key: const Key('fontSizeLabel'),
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          key: const Key('fontSizeSelector'),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: elevatedBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 减小按钮
              IconButton(
                key: const Key('fontSizeDecrement'),
                icon: Icon(
                  Icons.remove,
                  color: settings.canDecreaseFontSize
                      ? textColor
                      : secondaryTextColor.withOpacity(0.3),
                  size: 20,
                ),
                onPressed:
                    settings.canDecreaseFontSize ? onFontSizeDecrement : null,
                tooltip: '减小字号',
              ),
              // 当前字号
              Text(
                '${settings.fontSize}',
                key: const Key('fontSizeValue'),
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // 增大按钮
              IconButton(
                key: const Key('fontSizeIncrement'),
                icon: Icon(
                  Icons.add,
                  color: settings.canIncreaseFontSize
                      ? textColor
                      : secondaryTextColor.withOpacity(0.3),
                  size: 20,
                ),
                onPressed:
                    settings.canIncreaseFontSize ? onFontSizeIncrement : null,
                tooltip: '增大字号',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建开关选项部分。
  Widget _buildSwitchSection({
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Column(
      children: [
        // 自动刷新开关
        _buildSwitchItem(
          key: const Key('autoRefreshSwitch'),
          label: '自动刷新',
          description: '文件变更时自动刷新预览',
          value: settings.autoRefresh,
          onChanged: onAutoRefreshChanged,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        ),
        const SizedBox(height: 12),
        // 显示大纲开关
        _buildSwitchItem(
          key: const Key('showOutlineSwitch'),
          label: '显示大纲',
          description: '在侧边栏显示文档大纲',
          value: settings.showOutline,
          onChanged: onShowOutlineChanged,
          textColor: textColor,
          secondaryTextColor: secondaryTextColor,
        ),
      ],
    );
  }

  /// 构建开关项。
  Widget _buildSwitchItem({
    required Key key,
    required String label,
    required String description,
    required bool value,
    required void Function(bool)? onChanged,
    required Color textColor,
    required Color secondaryTextColor,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          key: key,
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.accentPrimary,
        ),
      ],
    );
  }
}
