import 'package:flutter/material.dart';

import 'vani_colors.dart';
import 'vani_typography.dart';

enum AppThemeMode { light, dark, highContrast, system }

class VaniTheme {
  static ThemeData lightTheme([double textScale = 1.0]) {
    final textTheme = TextTheme(
      headlineLarge: VaniTypography.headlineLg(
        VaniColors.lightTextPrimary,
        textScale,
      ),
      headlineMedium: VaniTypography.headlineMd(
        VaniColors.lightTextPrimary,
        textScale,
      ),
      bodyLarge: VaniTypography.transcriptFocus(
        VaniColors.lightTextPrimary,
        textScale,
      ),
      bodyMedium: VaniTypography.bodyMd(VaniColors.lightTextPrimary, textScale),
      labelLarge: VaniTypography.labelMd(VaniColors.lightTextPrimary),
      labelMedium: VaniTypography.caption(VaniColors.lightTextSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: VaniColors.lightBaseCanvas,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: VaniColors.lightPrimary,
        onPrimary: Colors.white,
        primaryContainer: VaniColors.lightPrimaryContainer,
        onPrimaryContainer: Colors.white,
        secondary: VaniColors.lightSecondary,
        onSecondary: Colors.white,
        secondaryContainer: VaniColors.lightSecondaryContainer,
        onSecondaryContainer: VaniColors.lightPrimary,
        surface: VaniColors.lightBaseCanvas,
        onSurface: VaniColors.lightTextPrimary,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        outline: VaniColors.lightHairlineBorder,
        outlineVariant: VaniColors.lightHairlineBorder,
      ),
      cardTheme: CardThemeData(
        color: VaniColors.lightContainerLowest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: VaniColors.lightHairlineBorder,
            width: 1,
          ),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: VaniColors.lightBaseCanvas,
        foregroundColor: VaniColors.lightPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: VaniTypography.headlineMd(VaniColors.lightPrimary),
      ),
      textTheme: textTheme,
    );
  }

  static ThemeData darkTheme([double textScale = 1.0]) {
    final textTheme = TextTheme(
      headlineLarge: VaniTypography.headlineLg(
        VaniColors.darkTextPrimary,
        textScale,
      ),
      headlineMedium: VaniTypography.headlineMd(
        VaniColors.darkTextPrimary,
        textScale,
      ),
      bodyLarge: VaniTypography.transcriptFocus(
        VaniColors.darkTextPrimary,
        textScale,
      ),
      bodyMedium: VaniTypography.bodyMd(VaniColors.darkTextPrimary, textScale),
      labelLarge: VaniTypography.labelMd(VaniColors.darkTextPrimary),
      labelMedium: VaniTypography.caption(VaniColors.darkTextSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: VaniColors.darkBaseCanvas,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: VaniColors.darkPrimary,
        onPrimary: Colors.white,
        primaryContainer: VaniColors.darkPrimaryContainer,
        onPrimaryContainer: Colors.white,
        secondary: VaniColors.darkSecondary,
        onSecondary: Colors.black,
        secondaryContainer: Color(0xFF00374D),
        onSecondaryContainer: VaniColors.darkSecondary,
        surface: VaniColors.darkSurface,
        onSurface: VaniColors.darkTextPrimary,
        error: Color(0xFFFFB4AB),
        onError: Colors.black,
        outline: VaniColors.darkOutline,
        outlineVariant: VaniColors.darkBorder,
      ),
      cardTheme: CardThemeData(
        color: VaniColors.darkSurfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: VaniColors.darkBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: VaniColors.darkSurface,
        foregroundColor: VaniColors.darkTextPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: VaniTypography.headlineMd(VaniColors.darkTextPrimary),
      ),
      textTheme: textTheme,
    );
  }

  static ThemeData highContrastTheme([double textScale = 1.0]) {
    final textTheme = TextTheme(
      headlineLarge: VaniTypography.headlineLg(
        VaniColors.hcTextPrimary,
        textScale,
      ),
      headlineMedium: VaniTypography.headlineMd(
        VaniColors.hcTextPrimary,
        textScale,
      ),
      bodyLarge: VaniTypography.transcriptFocus(
        VaniColors.hcTextPrimary,
        textScale,
      ),
      bodyMedium: VaniTypography.bodyMd(VaniColors.hcTextPrimary, textScale),
      labelLarge: VaniTypography.labelMd(VaniColors.hcTextPrimary),
      labelMedium: VaniTypography.caption(VaniColors.hcTextSecondary),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: VaniColors.hcBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: VaniColors.hcPrimary,
        onPrimary: Colors.black,
        primaryContainer: Colors.white,
        onPrimaryContainer: Colors.black,
        secondary: VaniColors.hcTextSecondary,
        onSecondary: Colors.black,
        secondaryContainer: VaniColors.hcTextSecondary,
        onSecondaryContainer: Colors.black,
        surface: VaniColors.hcSurface,
        onSurface: VaniColors.hcTextPrimary,
        error: Colors.redAccent,
        onError: Colors.black,
        outline: VaniColors.hcBorder,
        outlineVariant: VaniColors.hcBorder,
      ),
      cardTheme: CardThemeData(
        color: VaniColors.hcSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: VaniColors.hcBorder, width: 2),
        ),
      ),
      textTheme: textTheme,
    );
  }
}
