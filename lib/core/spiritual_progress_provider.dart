import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_db.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_models.dart';
import 'package:muslim_pro/features/tasbeh/data/zikr_database.dart';

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SPIRITUAL PROGRESS — One Mountain, Two Paths
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

/// Mountain levels — 5 stages of spiritual elevation
enum MountainLevel {
  base,       // Level 1: 0-99 score
  elevation,  // Level 2: 100-299
  ridge,      // Level 3: 300-599
  nearPeak,   // Level 4: 600-999
  peak,       // Level 5: 1000+
}

extension MountainLevelExt on MountainLevel {
  int get index {
    switch (this) {
      case MountainLevel.base: return 1;
      case MountainLevel.elevation: return 2;
      case MountainLevel.ridge: return 3;
      case MountainLevel.nearPeak: return 4;
      case MountainLevel.peak: return 5;
    }
  }

  String get nameUz {
    switch (this) {
      case MountainLevel.base: return 'Boshlang\'ich';
      case MountainLevel.elevation: return 'Ko\'tarilish';
      case MountainLevel.ridge: return 'Tizma';
      case MountainLevel.nearPeak: return 'Cho\'qqi yaqini';
      case MountainLevel.peak: return 'Cho\'qqi';
    }
  }
}

/// Spiritual Progress State — all visual feedback derives from this
class SpiritualProgressState {
  final int totalScore;
  final MountainLevel level;
  final double mountainDotPosition;  // 0.0 (base) → 1.0 (peak)
  final double ambientLight;         // 0.0 → 1.0 (brighter at higher levels)
  final double skyGradientShift;     // 0.0 → 1.0 (warmer sky at peaks)
  final int todayPrayerScore;
  final int todayDhikrScore;
  final int weeklyBonus;
  final int monthlyBonus;
  final int lifetimeDhikr;
  final int lifetimePrayers;

  const SpiritualProgressState({
    this.totalScore = 0,
    this.level = MountainLevel.base,
    this.mountainDotPosition = 0.0,
    this.ambientLight = 0.0,
    this.skyGradientShift = 0.0,
    this.todayPrayerScore = 0,
    this.todayDhikrScore = 0,
    this.weeklyBonus = 0,
    this.monthlyBonus = 0,
    this.lifetimeDhikr = 0,
    this.lifetimePrayers = 0,
  });
}

/// Scaling constants
class _Scaling {
  /// Each prayed prayer = 2 points
  static const int prayerPoint = 2;

  /// Each qaza completed = 1 point
  static const int qazaPoint = 1;

  /// Weekly 7/7 bonus
  static const int weeklyBonus = 10;

  /// Monthly 90%+ bonus
  static const int monthlyBonus = 25;

  /// Each 33 dhikr cycle = 1 point
  static const double dhikrCyclePoint = 1.0;

  /// Mountain level thresholds
  static const List<int> levelThresholds = [0, 100, 300, 600, 1000];

  /// After peak, the journey continues. Score resets visual at each 1000
  static const int peakCycle = 1000;
}

class SpiritualProgressNotifier extends StateNotifier<SpiritualProgressState> {
  SpiritualProgressNotifier() : super(const SpiritualProgressState()) {
    recalculate();
  }

  Future<void> recalculate() async {
    // ─── 1. Prayer Score ───
    final allRecords = await PrayerTrackerDB.getAllRecords();

    int prayerScore = 0;
    int lifetimePrayers = 0;

    for (var r in allRecords) {
      // Each prayed = 2 pts
      for (var s in [r.fajr, r.dhuhr, r.asr, r.maghrib, r.isha]) {
        if (s == PrayerStatus.prayed) {
          prayerScore += _Scaling.prayerPoint;
          lifetimePrayers++;
        } else if (s == PrayerStatus.qazaCompleted) {
          prayerScore += _Scaling.qazaPoint;
          lifetimePrayers++;
        }
      }
    }

    // ─── 2. Today's Prayer Score ───
    final now = DateTime.now();
    final todayKey = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final todayRecord = allRecords.where((r) => r.date == todayKey);
    int todayPrayerScore = 0;
    if (todayRecord.isNotEmpty) {
      final r = todayRecord.first;
      for (var s in [r.fajr, r.dhuhr, r.asr, r.maghrib, r.isha]) {
        if (s == PrayerStatus.prayed) todayPrayerScore += _Scaling.prayerPoint;
        else if (s == PrayerStatus.qazaCompleted) todayPrayerScore += _Scaling.qazaPoint;
      }
    }

    // ─── 3. Weekly 7/7 Bonus ───
    int weeklyBonus = 0;
    int consecutive5 = 0;

    // Sort descending
    final sorted = List<DailyPrayerRecord>.from(allRecords)
      ..sort((a, b) => b.date.compareTo(a.date));

    for (var r in sorted) {
      if (r.isAllCompleted) {
        consecutive5++;
        if (consecutive5 >= 7) {
          weeklyBonus = _Scaling.weeklyBonus;
          break;
        }
      } else {
        break;
      }
    }

    // ─── 4. Monthly 90%+ Bonus ───
    int monthlyBonus = 0;
    final ym = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final monthRecords = allRecords.where((r) => r.date.startsWith(ym)).toList();
    if (monthRecords.isNotEmpty) {
      int totalSlots = monthRecords.length * 5;
      int completedSlots = 0;
      for (var r in monthRecords) {
        completedSlots += r.completedCount;
      }
      if (totalSlots > 0 && (completedSlots / totalSlots) >= 0.9) {
        monthlyBonus = _Scaling.monthlyBonus;
      }
    }

    // ─── 5. Dhikr Score ───
    int dhikrScore = 0;
    int lifetimeDhikr = 0;
    try {
      final sessions = await ZikrDatabase.getSessions();
      for (var s in sessions) {
        lifetimeDhikr += s.count;
        // Each 33 zikr = 1 point
        dhikrScore += (s.count / 33).floor();
      }
    } catch (_) {
      // DB might not exist yet
    }

    // Today's dhikr
    int todayDhikrScore = 0;
    try {
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      final todaySessions = await ZikrDatabase.getSessionsInRange(todayStart, todayEnd);
      for (var s in todaySessions) {
        todayDhikrScore += (s.count / 33).floor();
      }
    } catch (_) {}

    // ─── 6. Total Score ───
    final totalScore = prayerScore + dhikrScore + weeklyBonus + monthlyBonus;

    // ─── 7. Mountain Level ───
    final level = _calculateLevel(totalScore);

    // ─── 8. Mountain dot position (0.0 → 1.0) ───
    final cyclicScore = totalScore % _Scaling.peakCycle;
    final dotPosition = math.min(1.0, cyclicScore / _Scaling.peakCycle);

    // ─── 9. Ambient light (subtle increase with level) ───
    final ambientLight = math.min(1.0, level.index / 5.0);

    // ─── 10. Sky gradient shift ───
    final skyShift = math.min(1.0, totalScore / 2000.0);

    state = SpiritualProgressState(
      totalScore: totalScore,
      level: level,
      mountainDotPosition: dotPosition,
      ambientLight: ambientLight,
      skyGradientShift: skyShift,
      todayPrayerScore: todayPrayerScore,
      todayDhikrScore: todayDhikrScore,
      weeklyBonus: weeklyBonus,
      monthlyBonus: monthlyBonus,
      lifetimeDhikr: lifetimeDhikr,
      lifetimePrayers: lifetimePrayers,
    );

    // Persist score
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('spiritual_total_score', totalScore);
  }

  MountainLevel _calculateLevel(int score) {
    if (score >= _Scaling.levelThresholds[4]) return MountainLevel.peak;
    if (score >= _Scaling.levelThresholds[3]) return MountainLevel.nearPeak;
    if (score >= _Scaling.levelThresholds[2]) return MountainLevel.ridge;
    if (score >= _Scaling.levelThresholds[1]) return MountainLevel.elevation;
    return MountainLevel.base;
  }
}

/// Global provider
final spiritualProgressProvider =
    StateNotifierProvider<SpiritualProgressNotifier, SpiritualProgressState>((ref) {
  return SpiritualProgressNotifier();
});
