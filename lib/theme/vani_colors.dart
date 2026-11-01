import 'package:flutter/material.dart';

/// Design tokens extracted directly from the Stitch "Editorial Accessibility"
/// and "Obsidian Edition" design specifications for Vani.
class VaniColors {
  // --- Editorial Accessibility (Light Palette) ---
  /// Warm unbleached ivory paper ground to prevent visual fatigue.
  static const Color lightBaseCanvas = Color(0xFFFBF9F5);

  /// Surface paper layer for speaker containers and control panels.
  static const Color lightSurfaceLayer = Color(0xFFF4EFEB);

  /// Lowest container (cards, dialogs).
  static const Color lightContainerLowest = Color(0xFFFFFFFF);

  /// Low container.
  static const Color lightContainerLow = Color(0xFFF2F4F2);

  /// Standard container.
  static const Color lightContainer = Color(0xFFEDEEEC);

  /// High container.
  static const Color lightContainerHigh = Color(0xFFE7E9E6);

  /// Deep forest emerald: primary action, speaker focus, authoritative indicator.
  /// Contrast ratio > 7:1 against light canvas.
  static const Color lightPrimary = Color(0xFF00362A);
  static const Color lightPrimaryContainer = Color(0xFF184E3F);
  static const Color lightActiveDarkEmerald = Color(0xFF0F382C);
  static const Color lightSecondaryContainer = Color(0xFFC1ECDA);
  static const Color lightSecondary = Color(0xFF3F6658);

  /// Deep charcoal primary text: contrast ratio 14.8:1 against ivory base.
  static const Color lightTextPrimary = Color(0xFF191C1B);

  /// Secondary slate for timestamps, confidence scores, metadata.
  static const Color lightTextSecondary = Color(0xFF5A625E);

  /// Hairline sage border for tactile separation without cognitive clutter.
  static const Color lightHairlineBorder = Color(0xFFDCE3DE);

  // --- Obsidian Edition (Dark Palette) ---
  /// Deep obsidian slate background.
  static const Color darkBaseCanvas = Color(0xFF0D0E13);

  /// Surface container for dark reading canvas.
  static const Color darkSurface = Color(0xFF121318);
  static const Color darkSurfaceContainerLow = Color(0xFF1A1B21);
  static const Color darkSurfaceContainer = Color(0xFF1E1F25);
  static const Color darkSurfaceContainerHigh = Color(0xFF292A2F);

  /// Electric Cobalt / Azure primary for dark mode legibility.
  static const Color darkPrimary = Color(0xFF3B82F6);
  static const Color darkPrimaryContainer = Color(0xFF1D4ED8);
  static const Color darkSecondary = Color(0xFF7BD0FF);
  static const Color darkTertiary = Color(0xFF4EDEA3);

  /// Bone white primary text for dark canvas.
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFC4C5D7);
  static const Color darkBorder = Color(0xFF262833);
  static const Color darkOutline = Color(0xFF4B4E60);

  // --- High Contrast Palette (Maximum WCAG AAA > 18:1) ---
  static const Color hcBackground = Color(0xFF000000);
  static const Color hcSurface = Color(0xFF111111);
  static const Color hcTextPrimary = Color(0xFFFFFFFF);
  static const Color hcTextSecondary = Color(
    0xFFFFFF00,
  ); // Yellow for high visibility
  static const Color hcPrimary = Color(
    0xFF00FF66,
  ); // High visibility emerald green
  static const Color hcBorder = Color(0xFFFFFFFF);
}
