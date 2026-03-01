import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_db.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_models.dart';
import 'package:muslim_pro/features/namoz/streak_provider.dart';
import 'package:muslim_pro/features/namoz/qaza_manager_provider.dart';
import 'package:muslim_pro/core/spiritual_progress_provider.dart';

class DailyPrayerTrackerState {
  final DailyPrayerRecord record;
  final int streak;
  
  const DailyPrayerTrackerState({
    required this.record,
    this.streak = 0,
  });

  bool get isLoading => record.date == '';
}

class PrayerTrackerNotifier extends StateNotifier<DailyPrayerTrackerState> {
  final Ref ref;

  PrayerTrackerNotifier(this.ref) : super(const DailyPrayerTrackerState(
      record: DailyPrayerRecord(date: ''),
      streak: 0,
    )) {
    _init();
  }

  Future<void> _init() async {
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    var record = await PrayerTrackerDB.getRecord(today);
    if (record == null) {
      record = DailyPrayerRecord(date: today);
      await PrayerTrackerDB.saveRecord(record);
    }
    
    // Streak Provider must be read carefully. Wait for its initialization if needed.
    // We will just read the current state for now, but UI will read streak directly.
    final streakData = ref.read(streakProvider);

    state = DailyPrayerTrackerState(
      record: record, 
      streak: streakData.currentStreak
    );
  }

  Future<void> togglePrayer(String prayerName) async {
    if (state.isLoading) return;
    
    final record = state.record;
    PrayerStatus fajr = record.fajr;
    PrayerStatus dhuhr = record.dhuhr;
    PrayerStatus asr = record.asr;
    PrayerStatus maghrib = record.maghrib;
    PrayerStatus isha = record.isha;

    // We toggle between Prayed and Unknown for today's tracker.
    PrayerStatus toggle(PrayerStatus s) {
      if (s == PrayerStatus.unknown || s == PrayerStatus.missed) return PrayerStatus.prayed;
      return PrayerStatus.unknown;
    }

    switch (prayerName.toLowerCase()) {
      case 'bomdod':
        fajr = toggle(fajr);
        break;
      case 'peshin':
        dhuhr = toggle(dhuhr);
        break;
      case 'asr':
        asr = toggle(asr);
        break;
      case 'shom':
        maghrib = toggle(maghrib);
        break;
      case 'xufton':
        isha = toggle(isha);
        break;
    }

    await _updateAndSave(fajr, dhuhr, asr, maghrib, isha);
  }

  Future<void> setPrayerStatus(String prayerName, PrayerStatus newStatus) async {
    if (state.isLoading) return;

    final record = state.record;
    PrayerStatus fajr = record.fajr;
    PrayerStatus dhuhr = record.dhuhr;
    PrayerStatus asr = record.asr;
    PrayerStatus maghrib = record.maghrib;
    PrayerStatus isha = record.isha;

    switch (prayerName.toLowerCase()) {
      case 'bomdod':
        fajr = newStatus;
        break;
      case 'peshin':
        dhuhr = newStatus;
        break;
      case 'asr':
        asr = newStatus;
        break;
      case 'shom':
        maghrib = newStatus;
        break;
      case 'xufton':
        isha = newStatus;
        break;
    }

    await _updateAndSave(fajr, dhuhr, asr, maghrib, isha);
  }

  Future<void> _updateAndSave(
    PrayerStatus fajr,
    PrayerStatus dhuhr,
    PrayerStatus asr,
    PrayerStatus maghrib,
    PrayerStatus isha,
  ) async {
    final updated = state.record.copyWith(
      fajr: fajr,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
    );

    await PrayerTrackerDB.saveRecord(updated);
    
    // Recalculate streaks immediately
    await ref.read(streakProvider.notifier).recalculateStreak(updated.date, updated);
    
    // Update Qaza Manager since stats might have changed
    ref.invalidate(qazaManagerProvider);
    
    // Recalculate spiritual mountain progress
    ref.read(spiritualProgressProvider.notifier).recalculate();
    
    state = DailyPrayerTrackerState(
      record: updated, 
      streak: ref.read(streakProvider).currentStreak,
    );
  }
}


final prayerTrackerProvider = StateNotifierProvider<PrayerTrackerNotifier, DailyPrayerTrackerState>((ref) {
  return PrayerTrackerNotifier(ref);
});
