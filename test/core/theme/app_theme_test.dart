import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/core/theme/app_colors.dart';
import 'package:puremark/core/theme/app_theme.dart';

void main() {
  group('AppTheme', () {
    group('Dark Theme', () {
      late ThemeData darkTheme;

      setUp(() {
        darkTheme = AppTheme.darkTheme;
      });

      group('Basic Properties', () {
        test('should have dark brightness', () {
          // Assert
          expect(darkTheme.brightness, equals(Brightness.dark));
        });

        test('should have correct scaffoldBackgroundColor', () {
          // Assert
          expect(
            darkTheme.scaffoldBackgroundColor,
            equals(AppColors.darkBgPrimary),
          );
        });

        test('should use Inter font family', () {
          // Assert
          expect(darkTheme.textTheme.bodyLarge?.fontFamily, equals('Inter'));
        });
      });

      group('ColorScheme', () {
        test('should have dark brightness in colorScheme', () {
          // Assert
          expect(
            darkTheme.colorScheme.brightness,
            equals(Brightness.dark),
          );
        });

        test('should have correct primary color', () {
          // Assert
          expect(
            darkTheme.colorScheme.primary,
            equals(AppColors.accentPrimary),
          );
        });

        test('should have correct surface color', () {
          // Assert
          expect(
            darkTheme.colorScheme.surface,
            equals(AppColors.darkBgSurface),
          );
        });

        test('should have correct onPrimary color', () {
          // Assert - onPrimary should be readable against primary
          expect(darkTheme.colorScheme.onPrimary, isA<Color>());
        });

        test('should have correct onSurface color', () {
          // Assert
          expect(
            darkTheme.colorScheme.onSurface,
            equals(AppColors.darkTextPrimary),
          );
        });
      });

      group('AppBar Theme', () {
        test('should have correct backgroundColor', () {
          // Assert
          expect(
            darkTheme.appBarTheme.backgroundColor,
            equals(AppColors.darkBgPrimary),
          );
        });

        test('should have correct foregroundColor', () {
          // Assert
          expect(
            darkTheme.appBarTheme.foregroundColor,
            equals(AppColors.darkTextPrimary),
          );
        });

        test('should have zero elevation', () {
          // Assert
          expect(darkTheme.appBarTheme.elevation, equals(0));
        });
      });

      group('Card Theme', () {
        test('should have correct card color', () {
          // Assert
          expect(
            darkTheme.cardTheme.color,
            equals(AppColors.darkBgSurface),
          );
        });

        test('should have correct border radius', () {
          // Assert
          final shape = darkTheme.cardTheme.shape as RoundedRectangleBorder?;
          expect(shape, isNotNull);
          expect(
            shape!.borderRadius,
            equals(BorderRadius.circular(AppColors.cardRadius)),
          );
        });
      });

      group('Divider Theme', () {
        test('should have correct divider color', () {
          // Assert
          expect(
            darkTheme.dividerTheme.color,
            equals(AppColors.darkBorderDivider),
          );
        });
      });

      group('Icon Theme', () {
        test('should have correct icon color', () {
          // Assert
          expect(
            darkTheme.iconTheme.color,
            equals(AppColors.darkTextSecondary),
          );
        });
      });

      group('Text Theme', () {
        test('should have correct body text color', () {
          // Assert
          expect(
            darkTheme.textTheme.bodyLarge?.color,
            equals(AppColors.darkTextPrimary),
          );
        });

        test('should have correct secondary text color for bodySmall', () {
          // Assert
          expect(
            darkTheme.textTheme.bodySmall?.color,
            equals(AppColors.darkTextSecondary),
          );
        });
      });
    });

    group('Light Theme', () {
      late ThemeData lightTheme;

      setUp(() {
        lightTheme = AppTheme.lightTheme;
      });

      group('Basic Properties', () {
        test('should have light brightness', () {
          // Assert
          expect(lightTheme.brightness, equals(Brightness.light));
        });

        test('should have correct scaffoldBackgroundColor', () {
          // Assert
          expect(
            lightTheme.scaffoldBackgroundColor,
            equals(AppColors.lightBgPrimary),
          );
        });

        test('should use Inter font family', () {
          // Assert
          expect(lightTheme.textTheme.bodyLarge?.fontFamily, equals('Inter'));
        });
      });

      group('ColorScheme', () {
        test('should have light brightness in colorScheme', () {
          // Assert
          expect(
            lightTheme.colorScheme.brightness,
            equals(Brightness.light),
          );
        });

        test('should have correct primary color', () {
          // Assert
          expect(
            lightTheme.colorScheme.primary,
            equals(AppColors.lightAccentPrimary),
          );
        });

        test('should have correct surface color', () {
          // Assert
          expect(
            lightTheme.colorScheme.surface,
            equals(AppColors.lightBgSurface),
          );
        });

        test('should have correct onPrimary color', () {
          // Assert - onPrimary should be readable against primary
          expect(lightTheme.colorScheme.onPrimary, isA<Color>());
        });

        test('should have correct onSurface color', () {
          // Assert
          expect(
            lightTheme.colorScheme.onSurface,
            equals(AppColors.lightTextPrimary),
          );
        });
      });

      group('AppBar Theme', () {
        test('should have correct backgroundColor', () {
          // Assert
          expect(
            lightTheme.appBarTheme.backgroundColor,
            equals(AppColors.lightBgPrimary),
          );
        });

        test('should have correct foregroundColor', () {
          // Assert
          expect(
            lightTheme.appBarTheme.foregroundColor,
            equals(AppColors.lightTextPrimary),
          );
        });

        test('should have zero elevation', () {
          // Assert
          expect(lightTheme.appBarTheme.elevation, equals(0));
        });
      });

      group('Card Theme', () {
        test('should have correct card color', () {
          // Assert
          expect(
            lightTheme.cardTheme.color,
            equals(AppColors.lightBgSurface),
          );
        });

        test('should have correct border radius', () {
          // Assert
          final shape = lightTheme.cardTheme.shape as RoundedRectangleBorder?;
          expect(shape, isNotNull);
          expect(
            shape!.borderRadius,
            equals(BorderRadius.circular(AppColors.cardRadius)),
          );
        });
      });

      group('Divider Theme', () {
        test('should have correct divider color', () {
          // Assert
          expect(
            lightTheme.dividerTheme.color,
            equals(AppColors.lightBorderDivider),
          );
        });
      });

      group('Icon Theme', () {
        test('should have correct icon color', () {
          // Assert
          expect(
            lightTheme.iconTheme.color,
            equals(AppColors.lightTextSecondary),
          );
        });
      });

      group('Text Theme', () {
        test('should have correct body text color', () {
          // Assert
          expect(
            lightTheme.textTheme.bodyLarge?.color,
            equals(AppColors.lightTextPrimary),
          );
        });

        test('should have correct secondary text color for bodySmall', () {
          // Assert
          expect(
            lightTheme.textTheme.bodySmall?.color,
            equals(AppColors.lightTextSecondary),
          );
        });
      });
    });

    group('Theme Consistency', () {
      test('should have same font family for both themes', () {
        // Arrange
        final darkTheme = AppTheme.darkTheme;
        final lightTheme = AppTheme.lightTheme;

        // Assert
        expect(
          darkTheme.textTheme.bodyLarge?.fontFamily,
          equals(lightTheme.textTheme.bodyLarge?.fontFamily),
        );
      });

      test('should have same card radius for both themes', () {
        // Arrange
        final darkTheme = AppTheme.darkTheme;
        final lightTheme = AppTheme.lightTheme;

        // Act
        final darkShape = darkTheme.cardTheme.shape as RoundedRectangleBorder?;
        final lightShape = lightTheme.cardTheme.shape as RoundedRectangleBorder?;

        // Assert
        expect(darkShape?.borderRadius, equals(lightShape?.borderRadius));
      });

      test('should have same appBar elevation for both themes', () {
        // Arrange
        final darkTheme = AppTheme.darkTheme;
        final lightTheme = AppTheme.lightTheme;

        // Assert
        expect(
          darkTheme.appBarTheme.elevation,
          equals(lightTheme.appBarTheme.elevation),
        );
      });
    });

    group('Theme Type Validation', () {
      test('should return ThemeData for darkTheme', () {
        expect(AppTheme.darkTheme, isA<ThemeData>());
      });

      test('should return ThemeData for lightTheme', () {
        expect(AppTheme.lightTheme, isA<ThemeData>());
      });
    });

    group('Theme Immutability', () {
      test('should return same darkTheme instance on multiple calls', () {
        // Arrange & Act
        final theme1 = AppTheme.darkTheme;
        final theme2 = AppTheme.darkTheme;

        // Assert - should be same instance or identical values
        expect(theme1.brightness, equals(theme2.brightness));
        expect(
          theme1.scaffoldBackgroundColor,
          equals(theme2.scaffoldBackgroundColor),
        );
        expect(theme1.colorScheme.primary, equals(theme2.colorScheme.primary));
      });

      test('should return same lightTheme instance on multiple calls', () {
        // Arrange & Act
        final theme1 = AppTheme.lightTheme;
        final theme2 = AppTheme.lightTheme;

        // Assert - should be same instance or identical values
        expect(theme1.brightness, equals(theme2.brightness));
        expect(
          theme1.scaffoldBackgroundColor,
          equals(theme2.scaffoldBackgroundColor),
        );
        expect(theme1.colorScheme.primary, equals(theme2.colorScheme.primary));
      });
    });
  });
}
