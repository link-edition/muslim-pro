import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/prayer_model.dart';

/// Namoz vaqtlarini lokal xotiraga saqlash/o'qish xizmati
class PrayerStorage {
  static const String _keyPrayerTimes = 'cached_prayer_times';
  static const String _keyLastUpdate = 'prayer_times_last_update';

  /// Namoz vaqtlarini saqlash
  static Future<void> savePrayerTimes(DailyPrayerTimes prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(prayerTimes.toJson());
    await prefs.setString(_keyPrayerTimes, jsonString);
    await prefs.setString(_keyLastUpdate, DateTime.now().toIso8601String());
  }

  /// Saqlangan namoz vaqtlarini o'qish
  static Future<DailyPrayerTimes?> loadPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyPrayerTimes);
    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return DailyPrayerTimes.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  /// Saqlangan ma'lumotlar bugungi kunga tegishlimi?
  static Future<bool> isCacheValid() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString(_keyLastUpdate);
    if (lastUpdate == null) return false;

    final lastDate = DateTime.parse(lastUpdate);
    final now = DateTime.now();

    // Faqat bugungi kun uchun kesh amal qiladi
    return lastDate.year == now.year &&
        lastDate.month == now.month &&
        lastDate.day == now.day;
  }

  /// Keshni tozalash
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPrayerTimes);
    await prefs.remove(_keyLastUpdate);
  }
}
