import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_db.dart';
import 'package:muslim_pro/features/namoz/data/prayer_tracker_models.dart';

class StreakData {
  final int currentStreak;
  final int longestStreak;

  const StreakData({
    required this.currentStreak,
    required this.longestStreak,
  });

  StreakData copyWith({int? currentStreak, int? longestStreak}) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
    );
  }
}

class StreakNotifier extends StateNotifier<StreakData> {
  StreakNotifier() : super(const StreakData(currentStreak: 0, longestStreak: 0)) {
    _init();
  }

  Future<void> _init() async {
    final data = await PrayerTrackerDB.getStreakData();
    state = StreakData(
      currentStreak: data['current_streak'] ?? 0,
      longestStreak: data['longest_streak'] ?? 0,
    );
  }

  Future<void> recalculateStreak(String today, DailyPrayerRecord todayRecord) async {
    // Basic recalculation.
    // If today is completed, we add 1 to streak, check if > longest.
    // This is a naive logic. Ideal logic iterates backwards.
    
    // For robust logic, we query all records, sort them descending by date
    final all = await PrayerTrackerDB.getAllRecords(); // Normally we should do this directly via DB query but keeping it simple for now
    if (all.isEmpty) return;
    
    // We expect date format: 'yyyy-MM-dd'
    all.sort((a, b) => b.date.compareTo(a.date));

    int current = 0;
    int longest = 0;
    int tempStreak = 0;

    // Check if the latest record is today or yesterday
    DateTime now = DateTime.now();
    DateTime checkDate = DateTime(now.year, now.month, now.day);
    
    // Track continuous dates
    for (var r in all) {
      if (!r.isAllCompleted) {
        // Break current streak
        if (current == 0 && tempStreak > 0) {
          current = tempStreak;
        }
        tempStreak = 0;
        continue;
      }
      
      // r is completed
      tempStreak++;
      if (tempStreak > longest) longest = tempStreak;
    }
    
    if (current == 0 && tempStreak > 0) {
      current = tempStreak;
    }

    // Update state
    state = StreakData(
      currentStreak: current,
      longestStreak: longest,
    );

    // Update DB
    await PrayerTrackerDB.updateStreak(current, longest, todayRecord.isAllCompleted ? today : '');
  }
}

final streakProvider = StateNotifierProvider<StreakNotifier, StreakData>((ref) {
  return StreakNotifier();
});
