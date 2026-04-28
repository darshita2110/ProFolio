import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ── Theme mode provider ───────────────────────────────────────────────
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>(
  (ref) => ThemeModeNotifier(),
);

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.dark);

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  bool get isDark => state == ThemeMode.dark;
}

// ── Theme data ────────────────────────────────────────────────────────
class AppTheme {
  // ── Brand palette (shared) ────────────────────────────────────────
  static const Color primary     = Color(0xFFE8A838);
  static const Color primaryDark = Color(0xFFC8861A);
  static const Color primaryGlow = Color(0xFFF5C462);
  static const Color accent      = Color(0xFF4ECDC4);
  static const Color accentDark  = Color(0xFF2BA8A1);
  static const Color success     = Color(0xFF6BCB77);
  static const Color warning     = Color(0xFFFFD166);
  static const Color error       = Color(0xFFEF6461);

  // ── Dark palette ──────────────────────────────────────────────────
  static const Color bgBase     = Color(0xFF0F0E0C);
  static const Color bgSurface  = Color(0xFF181613);
  static const Color bgCard     = Color(0xFF211E19);
  static const Color bgCardHigh = Color(0xFF2A2620);
  static const Color border     = Color(0xFF3A3530);
  static const Color borderSoft = Color(0xFF4A4540);

  static const Color textPrimary   = Color(0xFFF5F0E8);
  static const Color textSecondary = Color(0xFFB8A898);
  static const Color textMuted     = Color(0xFF7A6E62);

  // ── Light palette ─────────────────────────────────────────────────
  static const Color lightBgBase     = Color(0xFFF8F6F2);
  static const Color lightBgSurface  = Color(0xFFFFFFFF);
  static const Color lightBgCard     = Color(0xFFFFFFFF);
  static const Color lightBgCardHigh = Color(0xFFF0ECE5);
  static const Color lightBorder     = Color(0xFFE0D8CC);
  static const Color lightBorderSoft = Color(0xFFEDE7DD);

  static const Color lightTextPrimary   = Color(0xFF1A1612);
  static const Color lightTextSecondary = Color(0xFF6B5D4F);
  static const Color lightTextMuted     = Color(0xFFA09080);

  // ── Context-aware getters ─────────────────────────────────────────
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bgBaseOf(BuildContext context) =>
      isDark(context) ? bgBase : lightBgBase;
  static Color bgSurfaceOf(BuildContext context) =>
      isDark(context) ? bgSurface : lightBgSurface;
  static Color bgCardOf(BuildContext context) =>
      isDark(context) ? bgCard : lightBgCard;
  static Color bgCardHighOf(BuildContext context) =>
      isDark(context) ? bgCardHigh : lightBgCardHigh;
  static Color borderOf(BuildContext context) =>
      isDark(context) ? border : lightBorder;
  static Color borderSoftOf(BuildContext context) =>
      isDark(context) ? borderSoft : lightBorderSoft;
  static Color textPrimaryOf(BuildContext context) =>
      isDark(context) ? textPrimary : lightTextPrimary;
  static Color textSecondaryOf(BuildContext context) =>
      isDark(context) ? textSecondary : lightTextSecondary;
  static Color textMutedOf(BuildContext context) =>
      isDark(context) ? textMuted : lightTextMuted;
  static Color onPrimaryOf(BuildContext context) =>
      const Color(0xFF0F0E0C);

  // ── DARK THEME ────────────────────────────────────────────────────
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgBase,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        tertiary: success,
        error: error,
        background: bgBase,
        surface: bgSurface,
        onSurface: textPrimary,
        outline: border,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: bgBase,
        foregroundColor: textPrimary,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 20,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      cardTheme: CardTheme(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: _buildTextTheme(textPrimary, textSecondary, textMuted),
      inputDecorationTheme: _buildInputTheme(bgCard, border, primary, error, textMuted, textSecondary),
      elevatedButtonTheme: _buildElevatedButton(),
      outlinedButtonTheme: _buildOutlinedButton(textPrimary, border),
      textButtonTheme: _buildTextButton(),
      dividerTheme: const DividerThemeData(color: border, thickness: 1),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: bgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.dmSerifDisplay(fontSize: 20, color: textPrimary),
        contentTextStyle: GoogleFonts.dmSans(fontSize: 14, color: textSecondary),
      ),
    );
  }

  // ── LIGHT THEME ───────────────────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBgBase,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: accent,
        tertiary: success,
        error: error,
        background: lightBgBase,
        surface: lightBgSurface,
        onSurface: lightTextPrimary,
        outline: lightBorder,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: lightBgBase,
        foregroundColor: lightTextPrimary,
        centerTitle: false,
        titleTextStyle: GoogleFonts.dmSerifDisplay(
          fontSize: 20,
          color: lightTextPrimary,
        ),
        iconTheme: const IconThemeData(color: lightTextPrimary),
      ),
      cardTheme: CardTheme(
        color: lightBgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: lightBorder, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      textTheme: _buildTextTheme(lightTextPrimary, lightTextSecondary, lightTextMuted),
      inputDecorationTheme: _buildInputTheme(
          lightBgCard, lightBorder, primary, error, lightTextMuted, lightTextSecondary),
      elevatedButtonTheme: _buildElevatedButton(),
      outlinedButtonTheme: _buildOutlinedButton(lightTextPrimary, lightBorder),
      textButtonTheme: _buildTextButton(),
      dividerTheme: const DividerThemeData(color: lightBorder, thickness: 1),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: lightBgSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: lightBgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titleTextStyle: GoogleFonts.dmSerifDisplay(fontSize: 20, color: lightTextPrimary),
        contentTextStyle: GoogleFonts.dmSans(fontSize: 14, color: lightTextSecondary),
      ),
    );
  }

  // ── Shared builders ───────────────────────────────────────────────
  static TextTheme _buildTextTheme(Color tp, Color ts, Color tm) => TextTheme(
    displayLarge: GoogleFonts.dmSerifDisplay(fontSize: 40, color: tp),
    displayMedium: GoogleFonts.dmSerifDisplay(fontSize: 32, color: tp),
    displaySmall: GoogleFonts.dmSerifDisplay(fontSize: 26, color: tp),
    headlineMedium: GoogleFonts.dmSerifDisplay(fontSize: 22, color: tp),
    headlineSmall: GoogleFonts.dmSerifDisplay(fontSize: 18, color: tp),
    titleLarge: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: tp),
    titleMedium: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: ts),
    bodyLarge: GoogleFonts.dmSans(fontSize: 16, color: tp),
    bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: ts),
    bodySmall: GoogleFonts.dmSans(fontSize: 12, color: tm),
  );

  static InputDecorationTheme _buildInputTheme(
      Color fill, Color bdr, Color prim, Color err, Color hint, Color label) =>
    InputDecorationTheme(
      filled: true,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: bdr),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: bdr),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: prim, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: err),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: err, width: 1.5),
      ),
      hintStyle: GoogleFonts.dmSans(fontSize: 14, color: hint),
      labelStyle: GoogleFonts.dmSans(fontSize: 14, color: label),
      errorStyle: GoogleFonts.dmSans(fontSize: 12, color: err),
      prefixIconColor: hint,
      suffixIconColor: hint,
    );

  static ElevatedButtonThemeData _buildElevatedButton() =>
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: const Color(0xFF0F0E0C),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    );

  static OutlinedButtonThemeData _buildOutlinedButton(Color fg, Color bdr) =>
    OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: fg,
        side: BorderSide(color: bdr),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );

  static TextButtonThemeData _buildTextButton() =>
    TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        textStyle: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
}