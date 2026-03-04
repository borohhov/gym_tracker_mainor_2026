import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get darkTheme {
    const appColors = AppColors(
      backgroundStart: Color(0xFF0F1320),
      backgroundEnd: Color(0xFF121A2C),
      surface: Color(0xFF242A37),
      surfaceElevated: Color(0xFF2A3140),
      border: Color(0x3D8D9AB6),
      textPrimary: Color(0xFFE9EDF4),
      textSecondary: Color(0xFFADB6C6),
      accent: Color(0xFF2ED3C6),
      accentSoft: Color(0xFF176760),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.transparent,
      colorScheme: ColorScheme.dark(
        primary: appColors.accent,
        secondary: appColors.accent,
        surface: appColors.surface,
        onSurface: appColors.textPrimary,
        onPrimary: Color(0xFF001F1D),
        error: Color(0xFFFF6E6E),
      ),
      textTheme: TextTheme(
        headlineMedium: TextStyle(
          fontSize: 46,
          fontWeight: FontWeight.w800,
          letterSpacing: -1,
          color: appColors.textPrimary,
        ),
        headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: appColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: appColors.textPrimary,
        ),
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: appColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
          color: appColors.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: appColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: appColors.accent,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: appColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: appColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: appColors.accent,
        foregroundColor: Color(0xFF051513),
      ),
      iconTheme: IconThemeData(color: appColors.textSecondary),
      dividerColor: appColors.border.withValues(alpha: 0.35),
      extensions: const <ThemeExtension<dynamic>>[appColors],
    );
  }
}

@immutable
class AppColors extends ThemeExtension<AppColors> {
  final Color backgroundStart;
  final Color backgroundEnd;
  final Color surface;
  final Color surfaceElevated;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accent;
  final Color accentSoft;

  const AppColors({
    required this.backgroundStart,
    required this.backgroundEnd,
    required this.surface,
    required this.surfaceElevated,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accent,
    required this.accentSoft,
  });

  LinearGradient get screenGradient {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[backgroundStart, backgroundEnd],
    );
  }

  @override
  ThemeExtension<AppColors> copyWith({
    Color? backgroundStart,
    Color? backgroundEnd,
    Color? surface,
    Color? surfaceElevated,
    Color? border,
    Color? textPrimary,
    Color? textSecondary,
    Color? accent,
    Color? accentSoft,
  }) {
    return AppColors(
      backgroundStart: backgroundStart ?? this.backgroundStart,
      backgroundEnd: backgroundEnd ?? this.backgroundEnd,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      border: border ?? this.border,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
    );
  }

  @override
  ThemeExtension<AppColors> lerp(
    covariant ThemeExtension<AppColors>? other,
    double t,
  ) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      backgroundStart: Color.lerp(backgroundStart, other.backgroundStart, t)!,
      backgroundEnd: Color.lerp(backgroundEnd, other.backgroundEnd, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      border: Color.lerp(border, other.border, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
    );
  }
}
