import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Spacing tokens ──────────────────────────────────────────────────────────
abstract final class AppSpacing {
  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 28.0;
  static const double xxxl = 40.0;

  // Semantic aliases
  static const double page    = xl;    // horizontal page margin
  static const double section = xxl;   // gap between sections
  static const double card    = lg;    // internal card padding
}

// ── Radius tokens ───────────────────────────────────────────────────────────
abstract final class AppRadius {
  static const double xs   = 6.0;   // chips, tiny badges
  static const double sm   = 8.0;   // icon containers, small elements
  static const double md   = 12.0;  // inputs, buttons, small cards
  static const double lg   = 16.0;  // standard cards
  static const double xl   = 22.0;  // featured cards, modals
  static const double full = 999.0; // pill / circle

  // Semantic aliases
  static const double card   = lg;
  static const double button = md;
  static const double input  = md;
  static const double chip   = xs;
  static const double badge  = sm;
  static const double sheet  = xl;
}

abstract final class AppColors {
  // Brand
  static const primary = Color(0xFF2563EB);
  static const primaryLight = Color(0xFF3B82F6);
  static const primaryDark = Color(0xFF1D4ED8);
  static const primarySurface = Color(0xFFEFF6FF);

  // Accent
  static const accent = Color(0xFF0EA5E9);
  static const accentGreen = Color(0xFF10B981);
  static const accentGreenSurface = Color(0xFFECFDF5);
  static const accentAmber = Color(0xFFF59E0B);
  static const accentAmberSurface = Color(0xFFFFFBEB);
  static const accentRed = Color(0xFFEF4444);
  static const accentRedSurface = Color(0xFFFEF2F2);
  static const accentPurple = Color(0xFF8B5CF6);
  static const accentOrange = Color(0xFFF97316);

  // Neutral – Light
  static const surface = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8FAFC);
  static const backgroundAlt = Color(0xFFF1F5F9);
  static const cardLight = Color(0xFFFFFFFF);
  static const borderLight = Color(0xFFE2E8F0);
  static const borderLighter = Color(0xFFF1F5F9);
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const textTertiary = Color(0xFF94A3B8);

  // Neutral – Dark
  static const surfaceDark = Color(0xFF1E293B);
  static const backgroundDark = Color(0xFF0F172A);
  static const backgroundDarkAlt = Color(0xFF1A2332);
  static const cardDark = Color(0xFF1E293B);
  static const cardDarkElevated = Color(0xFF243047);
  static const borderDark = Color(0xFF334155);
  static const borderDarkLight = Color(0xFF2D3F52);
  static const textPrimaryDark = Color(0xFFF1F5F9);
  static const textSecondaryDark = Color(0xFF94A3B8);

  // Category colors
  static const categoryDocuments = Color(0xFF6366F1);
  static const categoryCar = Color(0xFFF97316);
  static const categoryHealth = Color(0xFF10B981);
  static const categoryFinance = Color(0xFF0EA5E9);
  static const categoryHome = Color(0xFFF59E0B);
  static const categoryDigital = Color(0xFF8B5CF6);
  static const categoryPets = Color(0xFFEC4899);
  static const categoryMaintenance = Color(0xFF14B8A6);
  static const categoryCustom = Color(0xFF64748B);
}

// Shared shadow definitions
List<BoxShadow> cardShadow(bool isDark) => isDark
    ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ]
    : [
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.02),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

List<BoxShadow> elevatedShadow(bool isDark) => isDark
    ? [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ]
    : [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: const Color(0xFF0F172A).withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ];

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark ? _darkColorScheme : _lightColorScheme;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(isDark),
      scaffoldBackgroundColor:
          isDark ? AppColors.backgroundDark : AppColors.background,
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.background,
        foregroundColor:
            isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 64,
        backgroundColor:
            isDark ? AppColors.surfaceDark : AppColors.surface,
        indicatorColor: AppColors.primary.withOpacity(0.1),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? AppColors.primary : AppColors.textSecondary,
          );
        }),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        highlightElevation: 8,
        shape: StadiumBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.cardDarkElevated.withOpacity(0.5)
            : AppColors.backgroundAlt,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.input),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        hintStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textTertiary,
          fontSize: 14,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      chipTheme: ChipThemeData(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.chip)),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1,
        ),
        backgroundColor: isDark ? AppColors.cardDark : AppColors.surface,
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
        space: 1,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        minLeadingWidth: 24,
        iconColor:
            isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle:
              GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
          side: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.button)),
        ),
      ),
    );
  }

  // Single font family (Inter) with clear weight/size hierarchy.
  // Removing Outfit eliminates the "two fonts fighting" effect.
  static TextTheme _buildTextTheme(bool isDark) {
    final color = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

    TextStyle i(double size, FontWeight w,
            {double ls = 0, double h = 1.3}) =>
        GoogleFonts.inter(
            fontSize: size,
            fontWeight: w,
            letterSpacing: ls,
            height: h,
            color: color);

    return GoogleFonts.interTextTheme().copyWith(
      displayLarge:  i(48, FontWeight.w800, ls: -2.0),
      displayMedium: i(40, FontWeight.w700, ls: -1.5),
      displaySmall:  i(32, FontWeight.w700, ls: -1.0),
      headlineLarge: i(28, FontWeight.w700, ls: -0.8),
      headlineMedium:i(24, FontWeight.w700, ls: -0.5),
      headlineSmall: i(20, FontWeight.w700, ls: -0.3),
      titleLarge:    i(18, FontWeight.w600, ls: -0.2),
      titleMedium:   i(16, FontWeight.w600, ls: -0.1),
      titleSmall:    i(14, FontWeight.w600, ls:  0.0),
      bodyLarge:     i(16, FontWeight.w400, ls:  0.0, h: 1.55),
      bodyMedium:    i(14, FontWeight.w400, ls:  0.0, h: 1.55),
      bodySmall:     i(12, FontWeight.w400, ls:  0.0, h: 1.45),
      labelLarge:    i(14, FontWeight.w600, ls:  0.1),
      labelMedium:   i(12, FontWeight.w500, ls:  0.1),
      labelSmall:    i(11, FontWeight.w500, ls:  0.3),
    );
  }

  static const _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFDBEAFE),
    onPrimaryContainer: Color(0xFF1D4ED8),
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFE0F2FE),
    onSecondaryContainer: Color(0xFF0369A1),
    tertiary: AppColors.accentGreen,
    onTertiary: Colors.white,
    error: AppColors.accentRed,
    onError: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    surfaceContainerHighest: AppColors.background,
    outline: AppColors.borderLight,
    outlineVariant: Color(0xFFF1F5F9),
  );

  static const _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryLight,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFF1D4ED8),
    onPrimaryContainer: Color(0xFFDBEAFE),
    secondary: AppColors.accent,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFF0369A1),
    onSecondaryContainer: Color(0xFFE0F2FE),
    tertiary: AppColors.accentGreen,
    onTertiary: Colors.white,
    error: AppColors.accentRed,
    onError: Colors.white,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.textPrimaryDark,
    surfaceContainerHighest: AppColors.backgroundDark,
    outline: AppColors.borderDark,
    outlineVariant: Color(0xFF1E293B),
  );
}
