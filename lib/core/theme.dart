import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Asosiy ranglar — Deep Emerald
  static const Color deepEmerald = Color(0xFF022C22);
  static const Color emeraldDark = Color(0xFF011A14);
  static const Color emeraldMid = Color(0xFF064E3B);
  static const Color emeraldLight = Color(0xFF0D7A5F);

  // Oltin — Soft Gold
  static const Color softGold = Color(0xFFD4AF37);
  static const Color goldLight = Color(0xFFE8C95A);
  static const Color goldDark = Color(0xFFB8941E);

  // Fon ranglari
  static const Color background = Color(0xFF010F0B);
  static const Color surface = Color(0xFF081C16);
  static const Color cardBg = Color(0xFF0A2A1F);
  static const Color cardBgLight = Color(0xFF103D2E);

  // Matn ranglari
  static const Color textPrimary = Color(0xFFF5F5F0);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // Gradientlar
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emeraldMid, deepEmerald],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [softGold, goldLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F3D2E), Color(0xFF072A1E)],
  );

  static const LinearGradient prayerCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D4A36), Color(0xFF022C22)],
  );
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.emeraldMid,
        secondary: AppColors.softGold,
        surface: AppColors.surface,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.softGold),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.softGold),
    );
  }
}
