import 'package:flutter/material.dart';

/// Enterprise Design System Color Tokens for Acadyk Admin Panel.
/// Restrained palette: deep slate navy, warm/cool grays, muted semantics.
class AppColors {
  // ── Brand ──
  static const Color brand = Color(0xFF0F172A);       // Deep Slate Navy
  static const Color brandDark = Color(0xFF020617);
  static const Color accent = Color(0xFF2563EB);       // Royal Blue — used sparingly

  // ── Light Mode ──
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceAlt = Color(0xFFF1F5F9);
  static const Color lightBorder = Color(0xFFE2E8F0);
  static const Color lightBorderSubtle = Color(0xFFF1F5F9);
  static const Color lightText = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF94A3B8);

  // ── Dark Mode ──
  static const Color darkBg = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceAlt = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkBorderSubtle = Color(0xFF1E293B);
  static const Color darkText = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  // ── Semantic Status ──
  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFF0FDF4);
  static const Color successText = Color(0xFF15803D);

  static const Color warning = Color(0xFFD97706);
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningText = Color(0xFFB45309);

  static const Color error = Color(0xFFDC2626);
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorText = Color(0xFFB91C1C);

  static const Color info = Color(0xFF2563EB);
  static const Color infoBg = Color(0xFFEFF6FF);
  static const Color infoText = Color(0xFF1D4ED8);

  // ── Convenience Aliases (backward compat) ──
  static const Color primary = brand;
  static const Color primaryDark = brandDark;
  static const Color secondary = Color(0xFF475569);
  static const Color xBlue = accent;
  static const Color surface = lightSurface;
  static const Color textPrimary = lightText;
  static const Color textSecondary = lightTextSecondary;
  static const Color divider = lightBorder;
  static const Color heartPink = Color(0xFFE11D48);

  // Old admin aliases (backward compat)
  static const Color adminPrimary = brand;
  static const Color adminSurface = lightSurface;
  static const Color adminMuted = lightTextSecondary;
  static const Color adminBorder = lightBorder;
  static const Color adminDarkSurface = darkSurface;
  static const Color adminDarkBorder = darkBorder;

  // Old light-mode aliases
  static const Color lightBackground = lightBg;
  static const Color lightCard = lightSurface;
  static const Color lightTextPrimary = lightText;
  static const Color lightDivider = lightBorder;

  // Old dark-mode aliases
  static const Color darkBackground = darkBg;
  static const Color darkCard = darkSurfaceAlt;
  static const Color darkTextPrimary = darkText;
  static const Color darkDivider = darkBorderSubtle;

  // ── Dynamic Helpers ──
  static Color bg(bool isDark) => isDark ? darkBg : lightBg;
  static Color surfaceColor(bool isDark) => isDark ? darkSurface : lightSurface;
  static Color surfaceAlt(bool isDark) => isDark ? darkSurfaceAlt : lightSurfaceAlt;
  static Color border(bool isDark) => isDark ? darkBorder : lightBorder;
  static Color borderSubtle(bool isDark) => isDark ? darkBorderSubtle : lightBorderSubtle;
  static Color text(bool isDark) => isDark ? darkText : lightText;
  static Color textSec(bool isDark) => isDark ? darkTextSecondary : lightTextSecondary;
  static Color textMut(bool isDark) => isDark ? darkTextMuted : lightTextMuted;
}