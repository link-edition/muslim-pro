import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_db.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_models.dart';
import 'package:muslim_pro/features/namoz/prayer_tracker_provider.dart';

class QazaStats {
  final int totalQaza;
  final int completedQaza;
  
  const QazaStats({
    required this.totalQaza,
    required this.completedQaza,
  });

  int get remainingQaza => totalQaza - completedQaza;
}

class QazaManagerNotifier extends StateNotifier<QazaStats> {
  final Ref ref;

  QazaManagerNotifier(this.ref) : super(const QazaStats(totalQaza: 0, completedQaza: 0)) {
    _init();
  }

  Future<void> _init() async {
    final all = await PrayerTrackerDB.getAllRecords();
    
    int tQaza = 0;
    int cQaza = 0;

    for (var r in all) {
      if (r.fajr == PrayerStatus.missed) tQaza++;
      if (r.dhuhr == PrayerStatus.missed) tQaza++;
      if (r.asr == PrayerStatus.missed) tQaza++;
      if (r.maghrib == PrayerStatus.missed) tQaza++;
      if (r.isha == PrayerStatus.missed) tQaza++;

      if (r.fajr == PrayerStatus.qazaCompleted) cQaza++;
      if (r.dhuhr == PrayerStatus.qazaCompleted) cQaza++;
      if (r.asr == PrayerStatus.qazaCompleted) cQaza++;
      if (r.maghrib == PrayerStatus.qazaCompleted) cQaza++;
      if (r.isha == PrayerStatus.qazaCompleted) cQaza++;
    }

    state = QazaStats(totalQaza: tQaza + cQaza, completedQaza: cQaza);
  }

  Future<void> markQazaDone(String date, String prayerName) async {
    final record = await PrayerTrackerDB.getRecord(date);
    if (record == null) return;

    PrayerStatus newStatus = PrayerStatus.qazaCompleted;
    DailyPrayerRecord updated = record;

    switch (prayerName.toLowerCase()) {
      case 'bomdod':
        updated = record.copyWith(fajr: newStatus);
        break;
      case 'peshin':
        updated = record.copyWith(dhuhr: newStatus);
        break;
      case 'asr':
        updated = record.copyWith(asr: newStatus);
        break;
      case 'shom':
        updated = record.copyWith(maghrib: newStatus);
        break;
      case 'xufton':
        updated = record.copyWith(isha: newStatus);
        break;
    }

    await PrayerTrackerDB.saveRecord(updated);
    
    // Refresh stats
    await _init();

    // Optionally notify tracker if today
    final now = DateTime.now();
    final today = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    
    if (date == today) {
      ref.invalidate(prayerTrackerProvider);
    }
  }
}

final qazaManagerProvider = StateNotifierProvider<QazaManagerNotifier, QazaStats>((ref) {
  return QazaManagerNotifier(ref);
});
