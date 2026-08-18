import 'package:flutter/material.dart';

/// Enterprise Design System Tokens for Acadyk Admin Panel.
/// Designed for a calm, professional, academic & enterprise administrative software look.
class AppColors {
  // Brand Primary & Accent
  static const Color primary = Color(0xFF0F172A); // Deep Slate Navy
  static const Color primaryDark = Color(0xFF020617);
  static const Color accent = Color(0xFF2563EB); // Royal Blue Accent
  static const Color secondary = Color(0xFF475569);
  static const Color xBlue = Color(0xFF2563EB);

  // Surface & Neutrals (Light Mode)
  static const Color surface = Color(0xFFFFFFFF);
  static const Color lightBackground = Color(0xFFF8FAFC); // Clean light slate background
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0); // Subtle 1px border
  static const Color lightBorderSubtle = Color(0xFFF1F5F9);
  static const Color lightTextPrimary = Color(0xFF0F172A); // High contrast dark slate
  static const Color lightTextSecondary = Color(0xFF64748B); // Muted slate
  static const Color lightTextMuted = Color(0xFF94A3B8);
  static const Color lightDivider = Color(0xFFE2E8F0);

  // Common Aliases
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color divider = lightDivider;

  // Dark Mode Tokens (Clean dark slate, not pitch black)
  static const Color darkBackground = Color(0xFF0B0F19);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkCard = Color(0xFF1E293B);
  static const Color darkBorder = Color(0xFF334155);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkDivider = Color(0xFF1E293B);

  // Semantic & Status Colors (Restrained, Enterprise Standards)
  static const Color success = Color(0xFF16A34A); // Emerald Green
  static const Color successBg = Color(0xFFF0FDF4);
  static const Color successText = Color(0xFF15803D);

  static const Color warning = Color(0xFFD97706); // Amber Warning
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color warningText = Color(0xFFB45309);

  static const Color error = Color(0xFFDC2626); // Crimson Error
  static const Color errorBg = Color(0xFFFEF2F2);
  static const Color errorText = Color(0xFFB91C1C);

  static const Color info = Color(0xFF2563EB); // Cobalt Info
  static const Color infoBg = Color(0xFFEFF6FF);
  static const Color infoText = Color(0xFF1D4ED8);

  static const Color heartPink = Color(0xFFE11D48);

  // Admin Specific Semantic Tokens
  static const Color adminPrimary = Color(0xFF0F172A);
  static const Color adminSurface = Color(0xFFFFFFFF);
  static const Color adminMuted = Color(0xFF64748B);
  static const Color adminBorder = Color(0xFFE2E8F0);
  static const Color adminDarkSurface = Color(0xFF111827);
  static const Color adminDarkBorder = Color(0xFF334155);
}