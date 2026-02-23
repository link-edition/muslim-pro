import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'quran_screen.dart';
import 'quran_text_screen.dart';

class QuranLandingPage extends StatelessWidget {
  const QuranLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: AppColors.textPrimary),
        ),
        title: Text(
          'Qur\'oni Karim',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            // Bismilloh
            Text(
              'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
              style: GoogleFonts.amiri(
                fontSize: 26,
                color: AppColors.softGold,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),

            Text(
              'Qur\'on o\'qish yoki tinglash uchun\nbo\'limni tanlang',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textMuted,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 48),

            // 📖 Qur'on — Text Only
            _LandingCard(
              icon: Icons.menu_book_rounded,
              title: 'Qur\'on',
              subtitle: 'Suralarni o\'qish',
              description: 'Kitob formatida. Lotin/Kirill tarjima.',
              gradientColors: const [Color(0xFF0D5A42), Color(0xFF073D2C), Color(0xFF022C22)],
              iconBgColor: AppColors.emeraldMid,
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const QuranTextScreen()),
              ),
            ),

            const SizedBox(height: 20),

            // 🎧 Audio Qur'on
            _LandingCard(
              icon: Icons.headphones_rounded,
              title: 'Audio Qur\'on',
              subtitle: 'Tinglash va o\'qish',
              description: 'Mishary Rashid qiroati. Tarjima bilan.',
              gradientColors: const [Color(0xFF2D1B00), Color(0xFF1A1000), Color(0xFF0F0A00)],
              iconBgColor: const Color(0xFF8B6914),
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const QuranScreen()),
              ),
            ),

            const Spacer(),

            // Pastdagi eslatma
            Padding(
              padding: const EdgeInsets.only(bottom: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 14, color: AppColors.textMuted.withOpacity(0.5)),
                  const SizedBox(width: 6),
                  Text(
                    'Internet talab qilinadi',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textMuted.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LandingCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String description;
  final List<Color> gradientColors;
  final Color iconBgColor;
  final VoidCallback onTap;

  const _LandingCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.gradientColors,
    required this.iconBgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: AppColors.softGold.withOpacity(0.15),
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: iconBgColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: AppColors.softGold,
                size: 30,
              ),
            ),
            const SizedBox(width: 20),
            // Texts
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.softGold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.softGold.withOpacity(0.5),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
