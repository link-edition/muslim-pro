import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'dua_categories_screen.dart';
import 'salovatlar_screen.dart';
import 'saved_duolar_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/core/localization.dart';
import 'package:muslim_pro/core/widgets/premium_card.dart';

class DuolarEntryScreen extends ConsumerWidget {
  const DuolarEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(localizationProvider);
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(
          l10n.translate('duas'),
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: context.colors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          children: [
            _BigMenuButton(
              title: l10n.translate('duolar'),
              icon: Icons.volunteer_activism_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DuaCategoriesScreen()),
              ),
            ),
            const SizedBox(height: 20),
            _BigMenuButton(
              title: l10n.translate('salovatlar'),
              icon: Icons.mosque_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SalovatlarScreen()),
              ),
            ),
            const SizedBox(height: 20),
            _BigMenuButton(
              title: l10n.translate('saqlanganlar') ?? 'Saqlanganlar',
              icon: Icons.bookmark_rounded,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SavedDuolarScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BigMenuButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _BigMenuButton({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PremiumCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      customGradient: isDark ? context.colors.prayerCardGradient : context.colors.cardGradient,
      child: Container(
        width: double.infinity,
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? context.colors.iconBg.withValues(alpha: 0.1)
                    : context.colors.emeraldMid.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 42,
                color: isDark ? context.colors.softGold : context.colors.emeraldMid,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : context.colors.textPrimary,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
