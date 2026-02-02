import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:puremark/core/theme/app_colors.dart';

void main() {
  group('AppColors', () {
    group('Dark Theme Colors', () {
      group('Background Colors', () {
        test('should have correct darkBgPrimary color value', () {
          // Arrange
          const expectedColor = Color(0xFF1A1A1C);

          // Act
          final actualColor = AppColors.darkBgPrimary;

          // Assert
          expect(actualColor, equals(expectedColor));
        });

        test('should have correct darkBgSurface color value', () {
          // Arrange
          const expectedColor = Color(0xFF242426);

          // Act
          final actualColor = AppColors.darkBgSurface;

          // Assert
          expect(actualColor, equals(expectedColor));
        });

        test('should have correct darkBgElevated color value', () {
          // Arrange
          const expectedColor = Color(0xFF2A2A2C);

          // Act
          final actualColor = AppColors.darkBgElevated;

          // Assert
          expect(actualColor, equals(expectedColor));
        });
      });

      group('Text Colors', () {
        test('should have correct darkTextPrimary color value', () {
          // Arrange
          const expectedColor = Color(0xFFF5F5F0);

          // Act
          final actualColor = AppColors.darkTextPrimary;

          // Assert
          expect(actualColor, equals(expectedColor));
        });

        test('should have correct darkTextSecondary color value', () {
          // Arrange
          const expectedColor = Color(0xFF6E6E70);

          // Act
          final actualColor = AppColors.darkTextSecondary;

          // Assert
          expect(actualColor, equals(expectedColor));
        });

        test('should have correct darkTextTertiary color value', () {
          // Arrange
          const expectedColor = Color(0xFF4A4A4C);

          // Act
          final actualColor = AppColors.darkTextTertiary;

          // Assert
          expect(actualColor, equals(expectedColor));
        });
      });

      group('Border Colors', () {
        test('should have correct darkBorderPrimary color value', () {
          // Arrange
          const expectedColor = Color(0xFF3A3A3C);

          // Act
          final actualColor = AppColors.darkBorderPrimary;

          // Assert
          expect(actualColor, equals(expectedColor));
        });

        test('should have correct darkBorderDivider color value', () {
          // Arrange
          const expectedColor = Color(0xFF2A2A2C);

          // Act
          final actualColor = AppColors.darkBorderDivider;

          // Assert
          expect(actualColor, equals(expectedColor));
        });
      });
    });

    group('Light Theme Colors', () {
      group('Background Colors', () {
        test('should have correct lightBgPrimary color value', () {
          // Arrange
          const expectedColor = Color(0xFFFFFFFF);

          // Act
          final actualColor = AppColors.lightBgPrimary;

          // Assert
          expect(actualColor, equals(expectedColor));
        });

        test('should have correct lightBgSurface color value', () {
          // Arrange
          const expectedColor = Color(0xFFF5F5F7);

          // Act
          final actualColor = AppColors.lightBgSurface;

          // Assert
          expect(actualColor, equals(expectedColor));
        });

        test('should have correct lightBgElevated color value', () {
          // Arrange
          const expectedColor = Color(0xFFEAEAEC);

          // Act
          final actualColor = AppColors.lightBgElevated;

          // Assert
          expect(actualColor, equals(expectedColor));
        });
      });

      group('Text Colors', () {
        test('should have correct lightTextPrimary color value', () {
          // Arrange
          const expectedColor = Color(0xFF1D1D1F);

          // Act
          final actualColor = AppColors.lightTextPrimary;

          // Assert
          expect(actualColor, equals(expectedColor));
        });

        test('should have correct lightTextSecondary color value', () {
          // Arrange
          const expectedColor = Color(0xFF6E6E73);

          // Act
          final actualColor = AppColors.lightTextSecondary;

          // Assert
          expect(actualColor, equals(expectedColor));
        });

        test('should have correct lightTextTertiary color value', () {
          // Arrange
          const expectedColor = Color(0xFFAEAEB2);

          // Act
          final actualColor = AppColors.lightTextTertiary;

          // Assert
          expect(actualColor, equals(expectedColor));
        });
      });

      group('Border Colors', () {
        test('should have correct lightBorderPrimary color value', () {
          // Arrange
          const expectedColor = Color(0xFFD1D1D6);

          // Act
          final actualColor = AppColors.lightBorderPrimary;

          // Assert
          expect(actualColor, equals(expectedColor));
        });

        test('should have correct lightBorderDivider color value', () {
          // Arrange
          const expectedColor = Color(0xFFD1D1D6);

          // Act
          final actualColor = AppColors.lightBorderDivider;

          // Assert
          expect(actualColor, equals(expectedColor));
        });
      });
    });

    group('Accent Colors', () {
      test('should have correct accentPrimary color value', () {
        // Arrange
        const expectedColor = Color(0xFF8B9EFF);

        // Act
        final actualColor = AppColors.accentPrimary;

        // Assert
        expect(actualColor, equals(expectedColor));
      });

      test('should have correct accentSecondary color value', () {
        // Arrange
        const expectedColor = Color(0xFF6E9E6E);

        // Act
        final actualColor = AppColors.accentSecondary;

        // Assert
        expect(actualColor, equals(expectedColor));
      });

      test('should have correct lightAccentPrimary color value', () {
        // Arrange
        const expectedColor = Color(0xFF6366F1);

        // Act
        final actualColor = AppColors.lightAccentPrimary;

        // Assert
        expect(actualColor, equals(expectedColor));
      });

      test('should have correct lightAccentSecondary color value', () {
        // Arrange
        const expectedColor = Color(0xFF22C55E);

        // Act
        final actualColor = AppColors.lightAccentSecondary;

        // Assert
        expect(actualColor, equals(expectedColor));
      });
    });

    group('macOS Traffic Light Colors', () {
      test('should have correct trafficRed color value', () {
        // Arrange
        const expectedColor = Color(0xFFFF5F57);

        // Act
        final actualColor = AppColors.trafficRed;

        // Assert
        expect(actualColor, equals(expectedColor));
      });

      test('should have correct trafficYellow color value', () {
        // Arrange
        const expectedColor = Color(0xFFFEBC2E);

        // Act
        final actualColor = AppColors.trafficYellow;

        // Assert
        expect(actualColor, equals(expectedColor));
      });

      test('should have correct trafficGreen color value', () {
        // Arrange
        const expectedColor = Color(0xFF28C840);

        // Act
        final actualColor = AppColors.trafficGreen;

        // Assert
        expect(actualColor, equals(expectedColor));
      });
    });

    group('Dimension Constants', () {
      test('should have correct windowRadius value', () {
        // Arrange
        const expectedValue = 16.0;

        // Act
        final actualValue = AppColors.windowRadius;

        // Assert
        expect(actualValue, equals(expectedValue));
      });

      test('should have correct cardRadius value', () {
        // Arrange
        const expectedValue = 12.0;

        // Act
        final actualValue = AppColors.cardRadius;

        // Assert
        expect(actualValue, equals(expectedValue));
      });

      test('should have correct buttonRadius value', () {
        // Arrange
        const expectedValue = 8.0;

        // Act
        final actualValue = AppColors.buttonRadius;

        // Assert
        expect(actualValue, equals(expectedValue));
      });
    });

    group('Color Type Validation', () {
      test('should return Color type for all color constants', () {
        // Assert all dark theme colors are Color type
        expect(AppColors.darkBgPrimary, isA<Color>());
        expect(AppColors.darkBgSurface, isA<Color>());
        expect(AppColors.darkBgElevated, isA<Color>());
        expect(AppColors.darkTextPrimary, isA<Color>());
        expect(AppColors.darkTextSecondary, isA<Color>());
        expect(AppColors.darkTextTertiary, isA<Color>());
        expect(AppColors.darkBorderPrimary, isA<Color>());
        expect(AppColors.darkBorderDivider, isA<Color>());

        // Assert all light theme colors are Color type
        expect(AppColors.lightBgPrimary, isA<Color>());
        expect(AppColors.lightBgSurface, isA<Color>());
        expect(AppColors.lightBgElevated, isA<Color>());
        expect(AppColors.lightTextPrimary, isA<Color>());
        expect(AppColors.lightTextSecondary, isA<Color>());
        expect(AppColors.lightTextTertiary, isA<Color>());
        expect(AppColors.lightBorderPrimary, isA<Color>());
        expect(AppColors.lightBorderDivider, isA<Color>());

        // Assert all accent colors are Color type
        expect(AppColors.accentPrimary, isA<Color>());
        expect(AppColors.accentSecondary, isA<Color>());
        expect(AppColors.lightAccentPrimary, isA<Color>());
        expect(AppColors.lightAccentSecondary, isA<Color>());

        // Assert all traffic light colors are Color type
        expect(AppColors.trafficRed, isA<Color>());
        expect(AppColors.trafficYellow, isA<Color>());
        expect(AppColors.trafficGreen, isA<Color>());
      });

      test('should return double type for all dimension constants', () {
        expect(AppColors.windowRadius, isA<double>());
        expect(AppColors.cardRadius, isA<double>());
        expect(AppColors.buttonRadius, isA<double>());
      });
    });

    group('Color Opacity', () {
      test('should have full opacity for all color constants', () {
        // All colors should have alpha value of 255 (fully opaque)
        expect(AppColors.darkBgPrimary.alpha, equals(255));
        expect(AppColors.darkBgSurface.alpha, equals(255));
        expect(AppColors.darkBgElevated.alpha, equals(255));
        expect(AppColors.darkTextPrimary.alpha, equals(255));
        expect(AppColors.lightBgPrimary.alpha, equals(255));
        expect(AppColors.accentPrimary.alpha, equals(255));
        expect(AppColors.trafficRed.alpha, equals(255));
      });
    });
  });
}
