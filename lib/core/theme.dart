import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class MyColors extends ThemeExtension<MyColors> {
  final Color deepEmerald;
  final Color emeraldDark;
  final Color emeraldMid;
  final Color emeraldLight;
  final Color softGold;
  final Color goldLight;
  final Color goldDark;
  final Color background;
  final Color surface;
  final Color cardBg;
  final Color cardBgLight;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final LinearGradient primaryGradient;
  final LinearGradient goldGradient;
  final LinearGradient cardGradient;
  final LinearGradient prayerCardGradient;
  
  // Additional colors
  final Color goldText;
  final Color iconBg;
  final Color cardShadow;
  
  // NEW: Premium Light Mode specific
  final Color creamBg;
  final Color creamBgTop;
  final Color creamBgBottom;
  final Color warmBorder;
  final Color arabicText;

  const MyColors({
    required this.deepEmerald,
    required this.emeraldDark,
    required this.emeraldMid,
    required this.emeraldLight,
    required this.softGold,
    required this.goldLight,
    required this.goldDark,
    required this.background,
    required this.surface,
    required this.cardBg,
    required this.cardBgLight,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.primaryGradient,
    required this.goldGradient,
    required this.cardGradient,
    required this.prayerCardGradient,
    required this.goldText,
    required this.iconBg,
    required this.cardShadow,
    required this.creamBg,
    required this.creamBgTop,
    required this.creamBgBottom,
    required this.warmBorder,
    required this.arabicText,
  });

  @override
  ThemeExtension<MyColors> copyWith({
    Color? deepEmerald,
    Color? emeraldDark,
    Color? emeraldMid,
    Color? emeraldLight,
    Color? softGold,
    Color? goldLight,
    Color? goldDark,
    Color? background,
    Color? surface,
    Color? cardBg,
    Color? cardBgLight,
    Color? textPrimary,
    Color? textSecondary,
    Color? textMuted,
    LinearGradient? primaryGradient,
    LinearGradient? goldGradient,
    LinearGradient? cardGradient,
    LinearGradient? prayerCardGradient,
    Color? goldText,
    Color? iconBg,
    Color? cardShadow,
    Color? creamBg,
    Color? creamBgTop,
    Color? creamBgBottom,
    Color? warmBorder,
    Color? arabicText,
  }) {
    return MyColors(
      deepEmerald: deepEmerald ?? this.deepEmerald,
      emeraldDark: emeraldDark ?? this.emeraldDark,
      emeraldMid: emeraldMid ?? this.emeraldMid,
      emeraldLight: emeraldLight ?? this.emeraldLight,
      softGold: softGold ?? this.softGold,
      goldLight: goldLight ?? this.goldLight,
      goldDark: goldDark ?? this.goldDark,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      cardBg: cardBg ?? this.cardBg,
      cardBgLight: cardBgLight ?? this.cardBgLight,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textMuted: textMuted ?? this.textMuted,
      primaryGradient: primaryGradient ?? this.primaryGradient,
      goldGradient: goldGradient ?? this.goldGradient,
      cardGradient: cardGradient ?? this.cardGradient,
      prayerCardGradient: prayerCardGradient ?? this.prayerCardGradient,
      goldText: goldText ?? this.goldText,
      iconBg: iconBg ?? this.iconBg,
      cardShadow: cardShadow ?? this.cardShadow,
      creamBg: creamBg ?? this.creamBg,
      creamBgTop: creamBgTop ?? this.creamBgTop,
      creamBgBottom: creamBgBottom ?? this.creamBgBottom,
      warmBorder: warmBorder ?? this.warmBorder,
      arabicText: arabicText ?? this.arabicText,
    );
  }

  @override
  ThemeExtension<MyColors> lerp(ThemeExtension<MyColors>? other, double t) {
    if (other is! MyColors) return this;
    return MyColors(
      deepEmerald: Color.lerp(deepEmerald, other.deepEmerald, t)!,
      emeraldDark: Color.lerp(emeraldDark, other.emeraldDark, t)!,
      emeraldMid: Color.lerp(emeraldMid, other.emeraldMid, t)!,
      emeraldLight: Color.lerp(emeraldLight, other.emeraldLight, t)!,
      softGold: Color.lerp(softGold, other.softGold, t)!,
      goldLight: Color.lerp(goldLight, other.goldLight, t)!,
      goldDark: Color.lerp(goldDark, other.goldDark, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      cardBgLight: Color.lerp(cardBgLight, other.cardBgLight, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      primaryGradient: LinearGradient.lerp(primaryGradient, other.primaryGradient, t)!,
      goldGradient: LinearGradient.lerp(goldGradient, other.goldGradient, t)!,
      cardGradient: LinearGradient.lerp(cardGradient, other.cardGradient, t)!,
      prayerCardGradient: LinearGradient.lerp(prayerCardGradient, other.prayerCardGradient, t)!,
      goldText: Color.lerp(goldText, other.goldText, t)!,
      iconBg: Color.lerp(iconBg, other.iconBg, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      creamBg: Color.lerp(creamBg, other.creamBg, t)!,
      creamBgTop: Color.lerp(creamBgTop, other.creamBgTop, t)!,
      creamBgBottom: Color.lerp(creamBgBottom, other.creamBgBottom, t)!,
      warmBorder: Color.lerp(warmBorder, other.warmBorder, t)!,
      arabicText: Color.lerp(arabicText, other.arabicText, t)!,
    );
  }

  static const MyColors dark = MyColors(
    deepEmerald: Color(0xFF022C22),
    emeraldDark: Color(0xFF011A14),
    emeraldMid: Color(0xFF064E3B),
    emeraldLight: Color(0xFF0D7A5F),
    softGold: Color(0xFFD4AF37),
    goldLight: Color(0xFFE8C95A),
    goldDark: Color(0xFFB8941E),
    background: Color(0xFF010F0B),
    surface: Color(0xFF081C16),
    cardBg: Color(0xFF0A2A1F),
    cardBgLight: Color(0xFF103D2E),
    textPrimary: Color(0xFFF5F5F0),
    textSecondary: Color(0xFF9CA3AF),
    textMuted: Color(0xFF6B7280),
    primaryGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF064E3B), Color(0xFF022C22)],
    ),
    goldGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFD4AF37), Color(0xFFE8C95A)],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0F3D2E), Color(0xFF072A1E)],
    ),
    prayerCardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0D4A36), Color(0xFF022C22)],
    ),
    goldText: Color(0xFFD4AF37),
    iconBg: Color(0x33D4AF37),
    cardShadow: Colors.transparent,
    creamBg: Color(0xFF010F0B),
    creamBgTop: Color(0xFF0A1F17),
    creamBgBottom: Color(0xFF020805),
    warmBorder: Color(0x18D4AF37),
    arabicText: Color(0xFFF5F5F0),
  );

  // ═══════════════════════════════════════════════════════════
  // PREMIUM WARM CREAM LIGHT THEME — Islamic Luxury Aesthetic
  // ═══════════════════════════════════════════════════════════
  static const MyColors light = MyColors(
    // Emerald spectrum — deeper and richer for light mode
    deepEmerald: Color(0xFF0F3D2E),   // Title / primary dark green
    emeraldDark: Color(0xFF145C44),    // Button gradient end
    emeraldMid: Color(0xFF1A7A5A),     // Accent mid
    emeraldLight: Color(0xFF2CB887),   // Accent light

    // Gold spectrum — warm, luxurious
    softGold: Color(0xFFD4AF37),       // Primary accent gold
    goldLight: Color(0xFFE8C95A),      // Lighter gold
    goldDark: Color(0xFFB8941E),       // Deeper gold for small text

    // ── Core Backgrounds — Warm Cream, NOT white ──
    background: Color(0xFFF6F1E8),     // Main warm cream
    surface: Color(0xFFF4EFE6),        // Slightly different cream surface
    cardBg: Color(0xFFFFFFFF),         // Pure white cards
    cardBgLight: Color(0xFFFAF7F2),    // Very light warm card variant

    // ── Typography ──
    textPrimary: Color(0xFF0F3D2E),    // Deep emerald for titles
    textSecondary: Color(0xFF5E6D63),  // Muted green-gray
    textMuted: Color(0xFF7A8E83),      // Inactive / muted

    // ── Gradients ──
    primaryGradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFF8F3EA), Color(0xFFEFE7DA)],
    ),
    goldGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFD4AF37), Color(0xFFB8941E)],
    ),
    cardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFFFFF), Color(0xFFFCF9F4)],
    ),
    prayerCardGradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF0F3D2E), Color(0xFF145C44)],
    ),

    // ── Semantic Colors ──
    goldText: Color(0xFF0F3D2E),       // Titles use deep green
    iconBg: Color(0xFFD4AF37),         // Gold icon accent
    cardShadow: Color(0x0A000000),     // ~4% black for floating cards

    // ── NEW Premium Light Mode Tokens ──
    creamBg: Color(0xFFF6F1E8),        // Primary cream
    creamBgTop: Color(0xFFF8F3EA),     // Top gradient
    creamBgBottom: Color(0xFFEFE7DA),  // Bottom gradient
    warmBorder: Color(0x18D4AF37),     // Subtle gold border
    arabicText: Color(0xFF0A2E20),     // Slightly darker for Arabic elegance
  );
}

extension ColorContext on BuildContext {
  MyColors get colors => Theme.of(this).extension<MyColors>() ?? MyColors.dark;
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: MyColors.dark.background,
      extensions: const <ThemeExtension<dynamic>>[
        MyColors.dark,
      ],
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF064E3B), 
        secondary: Color(0xFFD4AF37),
        surface: Color(0xFF081C16),  
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme,
      ).apply(
        bodyColor: MyColors.dark.textPrimary,
        displayColor: MyColors.dark.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: MyColors.dark.textPrimary,
        ),
        iconTheme: IconThemeData(color: MyColors.dark.softGold),
      ),
      cardTheme: CardThemeData(
        color: MyColors.dark.cardBg,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      iconTheme: IconThemeData(color: MyColors.dark.softGold),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: MyColors.light.background,
      extensions: const <ThemeExtension<dynamic>>[
        MyColors.light,
      ],
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF0F3D2E),
        secondary: Color(0xFFD4AF37),
        surface: Color(0xFFFFFFFF),  
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme,
      ).apply(
        bodyColor: MyColors.light.textPrimary,
        displayColor: MyColors.light.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: MyColors.light.textPrimary,
        ),
        iconTheme: IconThemeData(color: MyColors.light.deepEmerald),
      ),
      cardTheme: CardThemeData(
        color: MyColors.light.cardBg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
      ),
      iconTheme: IconThemeData(color: MyColors.light.deepEmerald),
      dividerTheme: const DividerThemeData(
        color: Colors.transparent,
        thickness: 0,
      ),
    );
  }
}
