import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:muslim_pro/core/theme.dart';
import '../prayer_provider.dart';
import '../data/prayer_model.dart';

/// Namoz vaqtlari asosiy sahifasi
class NamozScreen extends ConsumerWidget {
  const NamozScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prayerState = ref.watch(prayerProvider);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(prayerProvider.notifier).refreshPrayerTimes();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            // Yuqori qism — Countdown kartasi (RepaintBoundary — har soniya yangilanadi)
            RepaintBoundary(
              child: _buildCountdownCard(context, prayerState),
            ),

            const SizedBox(height: 16),

            // Bugungi sana
            _buildDateHeader(context),

            const SizedBox(height: 8),

            // Xatolik xabari (agar bo'lsa)
            if (prayerState.error != null)
              _buildErrorBanner(context, prayerState.error!, ref),

            // Namoz vaqtlari ro'yxati
            if (prayerState.isLoading && prayerState.prayerTimes == null)
              _buildLoadingState()
            else if (prayerState.prayerTimes != null)
              _buildPrayerList(context, prayerState.prayerTimes!.prayers)
            else
              _buildEmptyState(context, ref),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Countdown karta — keyingi namozgacha qolgan vaqt
  Widget _buildCountdownCard(BuildContext context, PrayerState state) {
    final nextPrayer = state.prayerTimes?.nextPrayer;
    final countdown = state.countdown;

    String countdownText = '--:--:--';
    String nextPrayerName = 'Yuklanmoqda...';

    if (nextPrayer != null && countdown != null && !countdown.isNegative) {
      final hours = countdown.inHours.toString().padLeft(2, '0');
      final minutes = (countdown.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (countdown.inSeconds % 60).toString().padLeft(2, '0');
      countdownText = '$hours:$minutes:$seconds';
      nextPrayerName = nextPrayer.name;
    } else if (state.prayerTimes != null && nextPrayer == null) {
      countdownText = '00:00:00';
      nextPrayerName = 'Bugungi namozlar tugadi';
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        gradient: AppColors.darkGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Islomiy bismillah
          Text(
            'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
            style: GoogleFonts.amiri(
              fontSize: 18,
              color: AppColors.gold,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 20),

          // Keyingi namoz nomi
          Text(
            nextPrayer != null ? 'Keyingi namoz' : '',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.7),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (nextPrayer != null) ...[
                Text(
                  nextPrayerName,
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  nextPrayer.nameArabic,
                  style: GoogleFonts.amiri(
                    fontSize: 20,
                    color: AppColors.gold,
                  ),
                ),
              ] else
                Text(
                  nextPrayerName,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Countdown taymer
          if (state.isLoading && state.prayerTimes == null)
            const SizedBox(
              height: 48,
              child: CircularProgressIndicator(
                color: AppColors.gold,
                strokeWidth: 2,
              ),
            )
          else
            Text(
              countdownText,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 48,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 4,
              ),
            ),

          if (nextPrayer != null) ...[
            const SizedBox(height: 8),
            Text(
              '${nextPrayer.formattedTime} da',
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppColors.goldLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Bugungi sana — hisoblash build tashqarisida
  /// DateFormat har buildda yaratilmaydi, static holatda saqlanadi
  static final DateFormat _dateFormat = DateFormat('d MMMM, yyyy — EEEE');

  Widget _buildDateHeader(BuildContext context) {
    // Provider dagi date'dan foydalanamiz yoki bugunni olamiz
    final dateText = _dateFormat.format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            dateText,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  /// Xatolik banneri
  Widget _buildErrorBanner(
    BuildContext context,
    String error,
    WidgetRef ref,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 13,
                color: Colors.orange.shade900,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(prayerProvider.notifier).refreshPrayerTimes();
            },
            child: const Text('Qayta'),
          ),
        ],
      ),
    );
  }

  /// Yuklanish holati
  Widget _buildLoadingState() {
    return const Padding(
      padding: EdgeInsets.all(64),
      child: Center(
        child: Column(
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: 16),
            Text(
              'Joylashuv aniqlanmoqda...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  /// Bo'sh holat
  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Namoz vaqtlarini ko\'rish uchun\njoylashuvga ruxsat bering',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(prayerProvider.notifier).refreshPrayerTimes();
            },
            icon: const Icon(Icons.my_location),
            label: const Text('Joylashuvni aniqlash'),
          ),
        ],
      ),
    );
  }

  /// Namoz vaqtlari ro'yxati
  Widget _buildPrayerList(
    BuildContext context,
    List<PrayerModel> prayers,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: prayers.map((prayer) {
          return _PrayerTimeCard(prayer: prayer);
        }).toList(),
      ),
    );
  }
}

/// Bitta namoz vaqti kartasi
class _PrayerTimeCard extends StatelessWidget {
  final PrayerModel prayer;

  const _PrayerTimeCard({required this.prayer});

  IconData _getIcon() {
    switch (prayer.name) {
      case 'Bomdod':
        return Icons.nightlight_round;
      case 'Quyosh':
        return Icons.wb_sunny_outlined;
      case 'Peshin':
        return Icons.wb_sunny;
      case 'Asr':
        return Icons.wb_twilight;
      case 'Shom':
        return Icons.nights_stay_outlined;
      case 'Xufton':
        return Icons.dark_mode;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPassed = prayer.time.isBefore(DateTime.now()) && !prayer.isNext;
    final isNext = prayer.isNext;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isNext
            ? AppColors.primaryGreen.withValues(alpha: 0.1)
            : Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isNext
            ? Border.all(color: AppColors.primaryGreen, width: 2)
            : Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        boxShadow: isNext
            ? [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isNext
                ? AppColors.primaryGreen
                : isPassed
                    ? Colors.grey.shade200
                    : AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIcon(),
            size: 22,
            color: isNext
                ? Colors.white
                : isPassed
                    ? Colors.grey.shade400
                    : AppColors.primaryGreen,
          ),
        ),
        title: Row(
          children: [
            Text(
              prayer.name,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                color: isPassed
                    ? Colors.grey
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              prayer.nameArabic,
              style: GoogleFonts.amiri(
                fontSize: 14,
                color: isPassed ? Colors.grey.shade400 : AppColors.gold,
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              prayer.formattedTime,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 18,
                fontWeight: isNext ? FontWeight.w700 : FontWeight.w500,
                color: isNext
                    ? AppColors.primaryGreen
                    : isPassed
                        ? Colors.grey
                        : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (isNext) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Keyingi',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreenDark,
                  ),
                ),
              ),
            ],
            if (isPassed) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.check_circle,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
