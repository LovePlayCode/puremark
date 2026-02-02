import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/viewer/providers/theme_provider.dart';
import 'features/viewer/screens/main_screen.dart';

/// PureMark 应用主入口 Widget
class PureMarkApp extends ConsumerWidget {
  const PureMarkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    // 同步持久化设置中的主题到 themeModeProvider（启动与设置变更时）
    ref.listen(settingsProvider, (_, next) {
      next.whenData((settings) {
        ref.read(themeModeProvider.notifier).state = settings.themeMode;
      });
    });

    return MaterialApp(
      title: 'PureMark',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const MainScreen(),
    );
  }
}
