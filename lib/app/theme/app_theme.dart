import 'package:material_ui/material_ui.dart';

/// Datei brand palette (docs/PRD.md §5).
abstract final class BrandColors {
  static const primaryOlive = Color(0xFF596B35);
  static const secondaryOlive = Color(0xFF788B4A);
  static const darkOlive = Color(0xFF3F4D28);
  static const softGold = Color(0xFFD6B66A);
  static const warmCream = Color(0xFFF4F1E7);
  static const charcoal = Color(0xFF252A20);
}

abstract final class AppTheme {
  static const fontFamily = 'IBMPlexSansArabic';

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BrandColors.primaryOlive,
      brightness: Brightness.light,
    ).copyWith(
      primary: BrandColors.primaryOlive,
      onPrimary: Colors.white,
      secondary: BrandColors.secondaryOlive,
      onSecondary: Colors.white,
      tertiary: const Color(0xFF8A6D1F),
      tertiaryContainer: const Color(0xFFF3E3B8),
      onTertiaryContainer: const Color(0xFF3A2D05),
      surface: const Color(0xFFFBFAF5),
      onSurface: BrandColors.charcoal,
    );
    return _base(scheme);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: BrandColors.primaryOlive,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFFBCCB93),
      onPrimary: const Color(0xFF243012),
      secondary: const Color(0xFFA9B985),
      tertiary: BrandColors.softGold,
      tertiaryContainer: const Color(0xFF5A4813),
      onTertiaryContainer: const Color(0xFFF7E7BE),
      surface: const Color(0xFF171A13),
    );
    return _base(scheme);
  }

  static ThemeData _base(ColorScheme scheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: scheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: scheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: scheme.surfaceContainerLow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerLowest,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontFamily: fontFamily, fontSize: 15, fontWeight: FontWeight.w500),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontFamily: fontFamily, fontSize: 12, color: scheme.onSurface),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
