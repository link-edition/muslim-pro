import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_db.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_models.dart';

class PrayerAnalyticsState {
  final MonthlySummary? currentMonth;
  final YearlySummary? currentYear;
  final int lifetimePrayers;

  const PrayerAnalyticsState({
    this.currentMonth,
    this.currentYear,
    this.lifetimePrayers = 0,
  });

  bool get isLoading => currentMonth == null && currentYear == null && lifetimePrayers == 0;
}

class PrayerAnalyticsNotifier extends StateNotifier<PrayerAnalyticsState> {
  PrayerAnalyticsNotifier() : super(const PrayerAnalyticsState()) {
    _load();
  }

  Future<void> _load() async {
    final now = DateTime.now();
    final ym = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final y = '${now.year}';

    final monthRecords = await PrayerTrackerDB.getRecordsInMonth(ym);
    final yearRecords = await PrayerTrackerDB.getRecordsInYear(y);
    final allRecords = await PrayerTrackerDB.getAllRecords();

    // 1. Monthly logic
    int mPrayed = 0, mMissed = 0, mQaza = 0;
    int maxDays = DateTime(now.year, now.month + 1, 0).day; // Full month
    int mTotal = maxDays * 5;

    for (var r in monthRecords) {
      mPrayed += r.prayedCount;
      // We can count exact missed and qaza based on status loops
      for (var s in [r.fajr, r.dhuhr, r.asr, r.maghrib, r.isha]) {
        if (s == PrayerStatus.missed) mMissed++;
        if (s == PrayerStatus.qazaCompleted) mQaza++;
      }
    }

    final currentMonth = MonthlySummary(
      month: ym,
      totalPrayers: mTotal,
      prayedCount: mPrayed,
      missedCount: mMissed,
      qazaCount: mQaza,
      longestStreak: 0, // Should be fetched from streak db
    );

    // 2. Yearly logic
    int yPrayed = 0, yMissed = 0, yQaza = 0;
    int yTotal = 365 * 5; // Simplified

    for (var r in yearRecords) {
      yPrayed += r.prayedCount;
      for (var s in [r.fajr, r.dhuhr, r.asr, r.maghrib, r.isha]) {
        if (s == PrayerStatus.missed) yMissed++;
        if (s == PrayerStatus.qazaCompleted) yQaza++;
      }
    }

    final double yRate = yTotal > 0 ? ((yPrayed + yQaza) / yTotal) : 0;
    final currentYear = YearlySummary(
      year: y,
      totalCompletionRate: yRate,
      totalQaza: yQaza,
      totalMissed: yMissed,
    );

    // 3. Lifetime
    int lPrayed = 0;
    for (var r in allRecords) {
      lPrayed += r.completedCount;
    }

    state = PrayerAnalyticsState(
      currentMonth: currentMonth,
      currentYear: currentYear,
      lifetimePrayers: lPrayed,
    );
  }

  Future<void> refresh() => _load();
}

final prayerAnalyticsProvider = StateNotifierProvider<PrayerAnalyticsNotifier, PrayerAnalyticsState>((ref) {
  return PrayerAnalyticsNotifier();
});
