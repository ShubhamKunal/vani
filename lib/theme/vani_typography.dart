import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography configuration adhering strictly to Stitch tokens.
/// Utilizes Noto Serif for editorial anchoring and Noto Sans for high-speed
/// real-time transcript streaming with Devanagari and Latin disambiguation.
class VaniTypography {
  static TextStyle getSerifStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w600,
    double lineHeight = 1.3,
    double letterSpacing = 0.0,
    Color? color,
  }) {
    try {
      return GoogleFonts.notoSerif(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: lineHeight,
        letterSpacing: letterSpacing,
        color: color,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'serif',
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: lineHeight,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
  }

  static TextStyle getSansStyle({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double lineHeight = 1.6,
    double letterSpacing = 0.0,
    Color? color,
  }) {
    try {
      return GoogleFonts.notoSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: lineHeight,
        letterSpacing: letterSpacing,
        color: color,
      );
    } catch (_) {
      return TextStyle(
        fontFamily: 'sans-serif',
        fontSize: fontSize,
        fontWeight: fontWeight,
        height: lineHeight,
        letterSpacing: letterSpacing,
        color: color,
      );
    }
  }

  // Display Headings
  static TextStyle displayLg(Color color, [double scale = 1.0]) =>
      getSerifStyle(
        fontSize: 32.0 * scale,
        fontWeight: FontWeight.w700,
        color: color,
        lineHeight: 1.2,
      );

  static TextStyle headlineLg(Color color, [double scale = 1.0]) =>
      getSerifStyle(
        fontSize: 24.0 * scale,
        fontWeight: FontWeight.w600,
        color: color,
        lineHeight: 1.25,
      );

  static TextStyle headlineMd(Color color, [double scale = 1.0]) =>
      getSerifStyle(
        fontSize: 20.0 * scale,
        fontWeight: FontWeight.w600,
        color: color,
        lineHeight: 1.3,
      );

  // Transcript Stream (High legibility focus)
  static TextStyle transcriptFocus(Color color, [double scale = 1.0]) =>
      getSansStyle(
        fontSize: 20.0 * scale,
        fontWeight: FontWeight.w500,
        color: color,
        lineHeight: 1.65,
      );

  static TextStyle transcriptInterim(Color color, [double scale = 1.0]) =>
      getSansStyle(
        fontSize: 20.0 * scale,
        fontWeight: FontWeight.w400,
        color: color,
        lineHeight: 1.65,
      );

  // Controls & Labels
  static TextStyle speakerLabel(Color color) => getSansStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
    color: color,
  );

  static TextStyle labelMd(Color color) =>
      getSansStyle(fontSize: 14.0, fontWeight: FontWeight.w600, color: color);

  static TextStyle bodyMd(Color color, [double scale = 1.0]) => getSansStyle(
    fontSize: 16.0 * scale,
    fontWeight: FontWeight.w400,
    color: color,
    lineHeight: 1.5,
  );

  static TextStyle caption(Color color) => getSansStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    color: color,
  );
}
