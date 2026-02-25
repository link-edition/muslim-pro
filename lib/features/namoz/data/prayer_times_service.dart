import 'package:adhan/adhan.dart';
import 'prayer_model.dart';

/// Namoz vaqtlarini adhan paketi orqali hisoblaydigan servis
class PrayerTimesService {
  /// Muayyan sana bo'yicha namoz vaqtlarini hisoblash
  static DailyPrayerTimes calculateForDate({
    required DateTime date,
    required double latitude,
    required double longitude,
    String method = 'Uzbekistan',
    String madhab = 'Hanafi',
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final dateComponents = DateComponents.from(date);

    CalculationParameters params;

    // Metod bo'yicha parametrlarni tanlash
    switch (method) {
      case 'Uzbekistan':
        params = CalculationMethod.muslim_world_league.getParameters();
        params.fajrAngle = 18.0;
        params.ishaAngle = 17.0;
        break;
      case 'Muslim World League':
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'Egyptian':
        params = CalculationMethod.egyptian.getParameters();
        break;
      case 'Karachi':
        params = CalculationMethod.karachi.getParameters();
        break;
      case 'Umm Al-Qura':
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'Dubai':
        params = CalculationMethod.dubai.getParameters();
        break;
      case 'North America':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'Kuwait':
        params = CalculationMethod.kuwait.getParameters();
        break;
      case 'Qatar':
        params = CalculationMethod.qatar.getParameters();
        break;
      case 'Singapore':
        params = CalculationMethod.singapore.getParameters();
        break;
      case 'Turkey':
        params = CalculationMethod.turkey.getParameters();
        break;
      case 'Tehran':
        params = CalculationMethod.tehran.getParameters();
        break;
      default:
        params = CalculationMethod.muslim_world_league.getParameters();
    }

    params.madhab = madhab == 'Hanafi' ? Madhab.hanafi : Madhab.shafi;

    print('DEBUG: Calculating for Date: ${date.toIso8601String()}, Method: $method, Madhab: $madhab, Lat: $latitude, Lng: $longitude');

    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);

    final prayers = [
      PrayerModel(name: 'Bomdod', nameArabic: 'الفجر', time: prayerTimes.fajr),
      PrayerModel(name: 'Quyosh', nameArabic: 'الشروق', time: prayerTimes.sunrise),
      PrayerModel(name: 'Peshin', nameArabic: 'الظهر', time: prayerTimes.dhuhr),
      PrayerModel(name: 'Asr', nameArabic: 'العصر', time: prayerTimes.asr),
      PrayerModel(name: 'Shom', nameArabic: 'المغرب', time: prayerTimes.maghrib),
      PrayerModel(name: 'Xufton', nameArabic: 'العشاء', time: prayerTimes.isha),
    ];

    // Agar hisoblash bugun uchun bo'lsa, keyingi namozni belgilaymiz
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    
    final prayersWithNext = isToday ? _markNextPrayer(prayers, now) : prayers;

    return DailyPrayerTimes(
      prayers: prayersWithNext,
      date: date,
      latitude: latitude,
      longitude: longitude,
    );
  }

  /// Bugun uchun hisoblash (eskicha qulaylik uchun)
  static DailyPrayerTimes calculateForToday({
    required double latitude,
    required double longitude,
    String method = 'Uzbekistan',
    String madhab = 'Hanafi',
  }) {
    return calculateForDate(
      date: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      method: method,
      madhab: madhab,
    );
  }

  /// Keyingi namozni belgilash
  static List<PrayerModel> _markNextPrayer(
    List<PrayerModel> prayers,
    DateTime now,
  ) {
    bool nextFound = false;
    
    // Bugungi barcha namozlarni tekshiramiz
    for (var i = 0; i < prayers.length; i++) {
      if (!nextFound && prayers[i].time.isAfter(now)) {
        prayers[i] = prayers[i].copyWith(isNext: true);
        nextFound = true;
      } else {
        prayers[i] = prayers[i].copyWith(isNext: false);
      }
    }
    
    // Agar bugun barcha namozlar o'tib ketgan bo'lsa, ertangi bomdod keyingi bo'ladi
    // Lekin hozircha faqat bugungi ro'yxatda belgilaymiz.
    
    return prayers;
  }
}
