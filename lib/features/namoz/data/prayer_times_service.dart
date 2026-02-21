import 'package:adhan/adhan.dart';
import 'prayer_model.dart';

/// Namoz vaqtlarini adhan paketi orqali hisoblaydigan servis
class PrayerTimesService {
  /// Koordinatalar asosida bugungi namoz vaqtlarini hisoblash
  /// O'zbekiston uchun Muslim World League + Hanafi madhabi
  static DailyPrayerTimes calculateForToday({
    required double latitude,
    required double longitude,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final now = DateTime.now();
    final dateComponents = DateComponents.from(now);

    // O'zbekiston uchun hisoblash metodi
    // Muslim World League — Hanafi madhabi (Asr vaqti uchun)
    final params = CalculationMethod.muslim_world_league.getParameters();
    params.madhab = Madhab.hanafi;

    // Namoz vaqtlarini hisoblash
    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    // Barcha namozlarni ro'yxatga yig'ish
    final prayers = [
      PrayerModel(
        name: 'Bomdod',
        nameArabic: 'الفجر',
        time: prayerTimes.fajr,
      ),
      PrayerModel(
        name: 'Quyosh',
        nameArabic: 'الشروق',
        time: prayerTimes.sunrise,
      ),
      PrayerModel(
        name: 'Peshin',
        nameArabic: 'الظهر',
        time: prayerTimes.dhuhr,
      ),
      PrayerModel(
        name: 'Asr',
        nameArabic: 'العصر',
        time: prayerTimes.asr,
      ),
      PrayerModel(
        name: 'Shom',
        nameArabic: 'المغرب',
        time: prayerTimes.maghrib,
      ),
      PrayerModel(
        name: 'Xufton',
        nameArabic: 'العشاء',
        time: prayerTimes.isha,
      ),
    ];

    // Keyingi namozni aniqlash
    final prayersWithNext = _markNextPrayer(prayers, now);

    return DailyPrayerTimes(
      prayers: prayersWithNext,
      date: now,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Keyingi namozni belgilash
  static List<PrayerModel> _markNextPrayer(
    List<PrayerModel> prayers,
    DateTime now,
  ) {
    bool nextFound = false;
    return prayers.map((prayer) {
      if (!nextFound && prayer.time.isAfter(now)) {
        nextFound = true;
        return prayer.copyWith(isNext: true);
      }
      return prayer;
    }).toList();
  }
}
