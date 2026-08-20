import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Acadyk Admin — Enterprise Typography Scale.
/// Clear hierarchy: page title → section → subsection → body → caption → metric.
class AppTypography {
  static const String _fontFamily = 'Inter';

  // ── Page-Level ──
  static const TextStyle pageTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColors.lightText,
    height: 1.3,
  );

  // ── Section Headings ──
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 15.0,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: AppColors.lightText,
    height: 1.4,
  );

  static const TextStyle subsection = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.0,
    fontWeight: FontWeight.w600,
    color: AppColors.lightText,
    height: 1.4,
  );

  // ── Body ──
  static const TextStyle body = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w400,
    color: AppColors.lightText,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 13.5,
    fontWeight: FontWeight.w500,
    color: AppColors.lightText,
    height: 1.5,
  );

  // ── Labels & Metadata ──
  static const TextStyle label = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.lightTextSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    color: AppColors.lightTextMuted,
    height: 1.4,
  );

  static const TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.8,
    color: AppColors.lightTextMuted,
    height: 1.4,
  );

  // ── Metrics / Stats ──
  static const TextStyle metric = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28.0,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    color: AppColors.lightText,
    height: 1.1,
  );

  // ── Backward Compat ──
  static const TextStyle headingLarge = pageTitle;

  static const TextStyle headingMedium = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.lightText,
  );
}
