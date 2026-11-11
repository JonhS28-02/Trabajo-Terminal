import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Valores tomados del archivo de Figma (frames de 402 x 874).
class AppColors {
  static const background = Color(0xFF000000);
  static const purpleDark = Color(0xFF350268);
  static const purple = Color(0xFF57078E);

  /// #3A3A3A al 60 % sobre negro.
  static const field = Color(0x993A3A3A);
  static const hint = Color(0xFF827E7E);
  static const codeBox = Color(0x33D9D9D9);
  static const textPrimary = Colors.white;

  /// Degradado de botones, bordes y figuras.
  static const gradient = LinearGradient(
    colors: [purpleDark, purple],
  );

  /// Degradado de las figuras de la animación y la pantalla morada completa.
  static const shapeGradient = LinearGradient(
    colors: [purpleDark, purple],
    stops: [0, 0.74],
  );
}

class AppSizes {
  /// Margen lateral del contenido.
  static const gutter = 35.0;
  static const radius = 10.0;
  static const buttonHeight = 51.0;
  static const fieldHeight = 51.0;
  static const headerRadius = 30.0;
}

class AppText {
  static TextStyle get title => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      );

  static TextStyle get subtitle => GoogleFonts.inter(
        fontSize: 12,
        color: AppColors.textPrimary,
      );

  static TextStyle get label => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  static TextStyle get input => GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.textPrimary,
      );

  static TextStyle get hint => GoogleFonts.inter(
        fontSize: 14,
        color: AppColors.hint,
      );

  static TextStyle get button => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );
}

class AppTheme {
  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.purple,
        surface: Color(0xFF1A1A1A),
      ),
    );
    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Color(0xFF8A3FD1),
        selectionColor: Color(0x6657078E),
        selectionHandleColor: AppColors.purple,
      ),
    );
  }
}
