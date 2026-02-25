import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/namoz/prayer_provider.dart';
import 'package:muslim_pro/features/quran/presentation/quran_screen.dart';
import 'package:muslim_pro/features/duolar/presentation/duolar_screen.dart';
import 'package:muslim_pro/features/tasbeh/presentation/tasbeh_screen.dart';
import 'package:muslim_pro/features/qibla/presentation/qibla_screen.dart';
import 'package:muslim_pro/features/settings/presentation/settings_screen.dart';
import 'package:muslim_pro/features/namoz/presentation/namoz_vaqtlari_page.dart';
import 'package:muslim_pro/features/quran/download_manager.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Background downloadni boshlaymiz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(AudioDownloadManager.provider).startBackgroundDownload();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prayerState = ref.watch(prayerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Assalomu alaykum',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              'Muslim Pro',
                              style: GoogleFonts.poppins(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => const SettingsScreen(),
                            ),
                          ),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.emeraldLight.withOpacity(0.2),
                              ),
                            ),
                            child: const Icon(
                              Icons.settings_outlined,
                              color: AppColors.softGold,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(builder: (_) => const NamozVaqtlariPage()),
                      ),
                      child: _PrayerCard(prayerState: prayerState),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Bo\'limlar',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.15,
                children: [
                  _MenuCard(
                    icon: Icons.headphones_rounded,
                    title: 'Audio Qur\'on',
                    subtitle: 'Tinglash',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D4A36), Color(0xFF022C22)],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const QuranScreen()),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.auto_stories,
                    title: 'Duolar',
                    subtitle: '8 bo\'lim',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF2D1B00), Color(0xFF1A1000)],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const DuolarScreen()),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.touch_app_rounded,
                    title: 'Tasbeh',
                    subtitle: 'Zikr sanagich',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF1A0D2E), Color(0xFF0F0820)],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const TasbehScreen()),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.explore_rounded,
                    title: 'Qibla',
                    subtitle: 'Yo\'nalish',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF002244), Color(0xFF001122)],
                    ),
                    onTap: () => Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const QiblaScreen()),
                    ),
                  ),
                ],
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}

class _PrayerCard extends StatelessWidget {
  final PrayerState prayerState;
  const _PrayerCard({required this.prayerState});

  @override
  Widget build(BuildContext context) {
    final nextPrayer = prayerState.prayerTimes?.prayers
        .where((p) => p.isNext)
        .firstOrNull;

    final countdown = prayerState.countdown;
    final hours = countdown != null ? countdown.inHours : 0;
    final minutes = countdown != null ? countdown.inMinutes.remainder(60) : 0;
    final seconds = countdown != null ? countdown.inSeconds.remainder(60) : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D5A42),
            Color(0xFF073D2C),
            Color(0xFF022C22),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.softGold.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldMid.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: prayerState.isLoading
          ? const Center(
              child: SizedBox(
                height: 50,
                child: CircularProgressIndicator(
                  color: AppColors.softGold,
                  strokeWidth: 2,
                ),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Keyingi namoz',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.softGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '🕌 ${nextPrayer?.name ?? "Bomdod"}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.softGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CountdownUnit(value: hours, label: 'soat'),
                    _CountdownSeparator(),
                    _CountdownUnit(value: minutes, label: 'daqiqa'),
                    _CountdownSeparator(),
                    _CountdownUnit(value: seconds, label: 'soniya'),
                  ],
                ),
              ],
            ),
    );
  }
}

class _CountdownUnit extends StatelessWidget {
  final int value;
  final String label;
  const _CountdownUnit({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString().padLeft(2, '0'),
          style: GoogleFonts.poppins(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: AppColors.softGold,
            height: 1,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

class _CountdownSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        ':',
        style: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: AppColors.softGold.withOpacity(0.2),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.emeraldLight.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.softGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: AppColors.softGold,
                  size: 26,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
