import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/features/settings/models/settings_state.dart';
import 'package:puremark/features/settings/widgets/settings_panel.dart';

void main() {
  group('SettingsPanel', () {
    Widget buildTestWidget({
      SettingsState settings = const SettingsState(),
      void Function(ThemeMode mode)? onThemeModeChanged,
      VoidCallback? onFontSizeIncrement,
      VoidCallback? onFontSizeDecrement,
      void Function(bool)? onAutoRefreshChanged,
      void Function(bool)? onShowOutlineChanged,
      VoidCallback? onClose,
      Brightness brightness = Brightness.dark,
    }) {
      return MaterialApp(
        theme: brightness == Brightness.dark
            ? ThemeData.dark()
            : ThemeData.light(),
        home: Scaffold(
          body: Center(
            child: SettingsPanel(
              settings: settings,
              onThemeModeChanged: onThemeModeChanged,
              onFontSizeIncrement: onFontSizeIncrement,
              onFontSizeDecrement: onFontSizeDecrement,
              onAutoRefreshChanged: onAutoRefreshChanged,
              onShowOutlineChanged: onShowOutlineChanged,
              onClose: onClose,
            ),
          ),
        ),
      );
    }

    group('渲染', () {
      testWidgets('应该正确渲染设置面板', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('settingsPanel')), findsOneWidget);
      });

      testWidgets('应该显示标题 "设置"', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('设置'), findsOneWidget);
      });

      testWidgets('应该显示关闭按钮', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.byKey(const Key('closeButton')), findsOneWidget);
      });

      testWidgets('应该显示主题标签', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('主题'), findsOneWidget);
      });

      testWidgets('应该显示字号标签', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('字号'), findsOneWidget);
      });
    });

    group('圆角', () {
      testWidgets('设置面板应该有 16px 圆角', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        final dialog = tester.widget<Dialog>(
          find.byKey(const Key('settingsPanel')),
        );
        final shape = dialog.shape as RoundedRectangleBorder;
        expect(shape.borderRadius, equals(BorderRadius.circular(16)));
      });
    });

    group('主题切换', () {
      testWidgets('应该显示三个主题选项', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('Dark'), findsOneWidget);
        expect(find.text('Light'), findsOneWidget);
        expect(find.text('System'), findsOneWidget);
      });

      testWidgets('点击 Dark 应该触发回调', (tester) async {
        // Arrange
        ThemeMode? selectedMode;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onThemeModeChanged: (mode) => selectedMode = mode,
        ));
        await tester.tap(find.byKey(const Key('themeDark')));
        await tester.pump();

        // Assert
        expect(selectedMode, equals(ThemeMode.dark));
      });

      testWidgets('点击 Light 应该触发回调', (tester) async {
        // Arrange
        ThemeMode? selectedMode;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onThemeModeChanged: (mode) => selectedMode = mode,
        ));
        await tester.tap(find.byKey(const Key('themeLight')));
        await tester.pump();

        // Assert
        expect(selectedMode, equals(ThemeMode.light));
      });

      testWidgets('点击 System 应该触发回调', (tester) async {
        // Arrange
        ThemeMode? selectedMode;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onThemeModeChanged: (mode) => selectedMode = mode,
        ));
        await tester.tap(find.byKey(const Key('themeSystem')));
        await tester.pump();

        // Assert
        expect(selectedMode, equals(ThemeMode.system));
      });
    });

    group('字号调节', () {
      testWidgets('应该显示当前字号', (tester) async {
        // Arrange
        const settings = SettingsState(fontSize: 18);

        // Act
        await tester.pumpWidget(buildTestWidget(settings: settings));

        // Assert
        expect(find.text('18'), findsOneWidget);
      });

      testWidgets('点击增加按钮应该触发回调', (tester) async {
        // Arrange
        var incrementCalled = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onFontSizeIncrement: () => incrementCalled = true,
        ));
        await tester.tap(find.byKey(const Key('fontSizeIncrement')));
        await tester.pump();

        // Assert
        expect(incrementCalled, isTrue);
      });

      testWidgets('点击减少按钮应该触发回调', (tester) async {
        // Arrange
        var decrementCalled = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onFontSizeDecrement: () => decrementCalled = true,
        ));
        await tester.tap(find.byKey(const Key('fontSizeDecrement')));
        await tester.pump();

        // Assert
        expect(decrementCalled, isTrue);
      });

      testWidgets('字号为最大值时增加按钮应该禁用', (tester) async {
        // Arrange
        const settings = SettingsState(fontSize: 24);
        var incrementCalled = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          settings: settings,
          onFontSizeIncrement: () => incrementCalled = true,
        ));
        await tester.tap(find.byKey(const Key('fontSizeIncrement')));
        await tester.pump();

        // Assert
        expect(incrementCalled, isFalse);
      });

      testWidgets('字号为最小值时减少按钮应该禁用', (tester) async {
        // Arrange
        const settings = SettingsState(fontSize: 12);
        var decrementCalled = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          settings: settings,
          onFontSizeDecrement: () => decrementCalled = true,
        ));
        await tester.tap(find.byKey(const Key('fontSizeDecrement')));
        await tester.pump();

        // Assert
        expect(decrementCalled, isFalse);
      });
    });

    group('开关选项', () {
      testWidgets('应该显示自动刷新开关', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('自动刷新'), findsOneWidget);
        expect(find.byKey(const Key('autoRefreshSwitch')), findsOneWidget);
      });

      testWidgets('应该显示显示大纲开关', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget());

        // Assert
        expect(find.text('显示大纲'), findsOneWidget);
        expect(find.byKey(const Key('showOutlineSwitch')), findsOneWidget);
      });

      testWidgets('切换自动刷新开关应该触发回调', (tester) async {
        // Arrange
        bool? newValue;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onAutoRefreshChanged: (value) => newValue = value,
        ));
        await tester.tap(find.byKey(const Key('autoRefreshSwitch')));
        await tester.pump();

        // Assert
        expect(newValue, equals(false));
      });

      testWidgets('切换显示大纲开关应该触发回调', (tester) async {
        // Arrange
        bool? newValue;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onShowOutlineChanged: (value) => newValue = value,
        ));
        await tester.tap(find.byKey(const Key('showOutlineSwitch')));
        await tester.pump();

        // Assert
        expect(newValue, equals(false));
      });
    });

    group('关闭按钮', () {
      testWidgets('点击关闭按钮应该触发 onClose', (tester) async {
        // Arrange
        var closeCalled = false;

        // Act
        await tester.pumpWidget(buildTestWidget(
          onClose: () => closeCalled = true,
        ));
        await tester.tap(find.byKey(const Key('closeButton')));
        await tester.pump();

        // Assert
        expect(closeCalled, isTrue);
      });
    });

    group('主题适配', () {
      testWidgets('深色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.dark));

        // Assert
        expect(find.byKey(const Key('settingsPanel')), findsOneWidget);
      });

      testWidgets('浅色主题下应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(brightness: Brightness.light));

        // Assert
        expect(find.byKey(const Key('settingsPanel')), findsOneWidget);
      });
    });

    group('边界条件', () {
      testWidgets('所有回调都为 null 时应该正确渲染', (tester) async {
        // Act
        await tester.pumpWidget(buildTestWidget(
          onThemeModeChanged: null,
          onFontSizeIncrement: null,
          onFontSizeDecrement: null,
          onAutoRefreshChanged: null,
          onShowOutlineChanged: null,
          onClose: null,
        ));

        // Assert
        expect(find.byKey(const Key('settingsPanel')), findsOneWidget);
      });
    });
  });
}
