import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/core/localization.dart';
import 'quran_screen.dart';
import 'digital_quran_screen.dart';

class QuranEntryScreen extends ConsumerWidget {
  const QuranEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF040E0A) : context.colors.background,
      body: Container(
        decoration: isDark
            ? null
            : BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.colors.creamBgTop,
                    context.colors.creamBgBottom,
                  ],
                ),
              ),
        child: Column(
          children: [
            // Custom App Bar
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back_ios_new, size: 20,
                        color: isDark ? Colors.white : context.colors.deepEmerald),
                    ),
                    const Spacer(),
                    Text(
                      l10n.translate('quran_karim'),
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : context.colors.deepEmerald,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48), // Balance
                  ],
                ),
              ),
            ),
            
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                child: Column(
                  children: [
                    _QuranOptionCard(
                      title: l10n.translate('audio_quran'),
                      subtitle: 'Oyatma-oyat o\'qish va qorilar audiosi',
                      icon: Icons.headphones_outlined,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (_) => const QuranScreen()),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _QuranOptionCard(
                      title: l10n.translate('mushaf'),
                      subtitle: 'Tajvidli Quron (Raqamli)',
                      icon: Icons.menu_book_outlined,
                      isDark: isDark,
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (_) => const DigitalQuranScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuranOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isDark;
  final Widget? trailing;
  final VoidCallback onTap;

  const _QuranOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isDark,
    this.trailing,
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
          gradient: isDark
              ? const LinearGradient(
                  colors: [Color(0xFF0D2E22), Color(0xFF091E16)],
                )
              : null,
          color: isDark ? null : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark
                ? const Color(0x18D4AF37)
                : const Color(0xFFD4AF37).withOpacity(0.1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            if (!isDark)
              BoxShadow(
                color: const Color(0xFFD4AF37).withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0x33D4AF37)
                    : const Color(0xFFD4AF37).withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD4AF37).withOpacity(0.12),
                  width: 0.8,
                ),
              ),
              child: Icon(icon, color: const Color(0xFFD4AF37), size: 28),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0F3D2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark ? Colors.white54 : const Color(0xFF5E6D63),
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right,
                color: isDark ? const Color(0xFFD4AF37) : const Color(0xFF0F3D2E).withOpacity(0.4)),
          ],
        ),
      ),
    );
  }
}
