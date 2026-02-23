import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_pro/core/theme.dart';
import 'package:muslim_pro/features/namoz/prayer_provider.dart';
import 'package:intl/intl.dart';
import 'package:muslim_pro/features/settings/settings_provider.dart';

class NamozVaqtlariPage extends ConsumerWidget {
  const NamozVaqtlariPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerProvider);
    final prayers = prayerState.prayerTimes?.prayers ?? [];
    final now = DateTime.now();
    String dateString;
    try {
      dateString = DateFormat('d-MMMM, yyyy', 'uz').format(now);
    } catch (e) {
      dateString = DateFormat('d-MM-yyyy').format(now);
    }
    final settings = ref.watch(settingsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        ),
        title: Text(
          'Namoz vaqtlari',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: prayerState.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.softGold))
          : Column(
              children: [
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 18, color: AppColors.softGold),
                      const SizedBox(width: 8),
                      Text(
                        dateString,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    itemCount: prayers.length,
                    itemBuilder: (context, index) {
                      final prayer = prayers[index];
                      final isNext = prayer.isNext;
                      final isEnabled = settings.enabledPrayers[prayer.name] ?? true;
                      final isQuyosh = prayer.name == 'Quyosh';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        decoration: BoxDecoration(
                          color: isNext ? AppColors.emeraldMid : AppColors.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isNext 
                              ? AppColors.softGold.withOpacity(0.5) 
                              : AppColors.emeraldLight.withOpacity(0.15),
                            width: isNext ? 1.5 : 1,
                          ),
                          boxShadow: isNext ? [
                            BoxShadow(
                              color: AppColors.emeraldMid.withOpacity(0.3),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ] : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Text(
                                  _getPrayerIcon(prayer.name),
                                  style: const TextStyle(fontSize: 22),
                                ),
                                const SizedBox(width: 16),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      prayer.name,
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isNext ? Colors.white : AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      prayer.nameArabic,
                                      style: GoogleFonts.amiri(
                                        fontSize: 14,
                                        color: isNext 
                                          ? Colors.white.withOpacity(0.8) 
                                          : AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  prayer.formattedTime,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: isNext ? AppColors.softGold : AppColors.textPrimary,
                                  ),
                                ),
                                if (!isQuyosh) ...[
                                  const SizedBox(width: 16),
                                  GestureDetector(
                                    onTap: () {
                                      ref.read(settingsProvider.notifier).togglePrayerNotification(prayer.name, !isEnabled);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        isEnabled 
                                            ? Icons.notifications_active_rounded 
                                            : Icons.notifications_off_outlined,
                                        size: 28,
                                        color: isNext 
                                            ? (isEnabled ? AppColors.softGold : Colors.white.withOpacity(0.5))
                                            : (isEnabled ? AppColors.softGold : AppColors.textMuted),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  String _getPrayerIcon(String name) {
    switch (name.toLowerCase()) {
      case 'bomdod': return '🌅';
      case 'quyosh': return '☀️';
      case 'peshin': return '🌞';
      case 'asr': return '🌤️';
      case 'shom': return '🌇';
      case 'xufton': return '🌙';
      default: return '🕌';
    }
  }
}
