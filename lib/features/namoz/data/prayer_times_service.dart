import 'package:adhan/adhan.dart';
import 'prayer_model.dart';

/// Namoz vaqtlarini adhan paketi orqali hisoblaydigan servis
class PrayerTimesService {
  /// Muayyan sana bo'yicha namoz vaqtlarini hisoblash
  static DailyPrayerTimes calculateForDate({
    required DateTime date,
    required double latitude,
    required double longitude,
    String method = 'Muslim World League',
    String madhab = 'Hanafi',
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final dateComponents = DateComponents.from(date);

    CalculationParameters params;

    // Metod bo'yicha parametrlarni tanlash
    switch (method) {
      case 'uzbekistan':
        params = CalculationMethod.muslim_world_league.getParameters();
        params.fajrAngle = 18.0;
        params.ishaAngle = 17.0;
        break;
      case 'mwl':
        params = CalculationMethod.muslim_world_league.getParameters();
        break;
      case 'umm_al_qura':
        params = CalculationMethod.umm_al_qura.getParameters();
        break;
      case 'diyanet':
        params = CalculationMethod.turkey.getParameters();
        break;
      case 'isna':
        params = CalculationMethod.north_america.getParameters();
        break;
      case 'egyptian':
        params = CalculationMethod.egyptian.getParameters();
        break;
      case 'kuwait':
        params = CalculationMethod.kuwait.getParameters();
        break;
      case 'qatar':
        params = CalculationMethod.qatar.getParameters();
        break;
      case 'uae':
        params = CalculationMethod.dubai.getParameters();
        break;
      case 'algeria':
        params = CalculationMethod.egyptian.getParameters();
        params.fajrAngle = 18.0;
        params.ishaAngle = 17.0;
        break;
      case 'morocco':
        params = CalculationMethod.egyptian.getParameters();
        params.fajrAngle = 18.0;
        params.ishaAngle = 19.0;
        break;
      case 'tunisia':
        params = CalculationMethod.egyptian.getParameters();
        params.fajrAngle = 18.0;
        params.ishaAngle = 18.0;
        break;
      case 'singapore':
        params = CalculationMethod.singapore.getParameters();
        break;
      case 'malaysia':
        params = CalculationMethod.singapore.getParameters();
        break;
      case 'indonesia':
        params = CalculationMethod.singapore.getParameters(); // or standard Kemenag params (20, 18)
        params.fajrAngle = 20.0;
        params.ishaAngle = 18.0;
        break;
      case 'karachi':
        params = CalculationMethod.karachi.getParameters();
        break;
      case 'india':
      case 'bangladesh':
        params = CalculationMethod.karachi.getParameters();
        break;
      case 'uk_birmingham':
        params = CalculationMethod.muslim_world_league.getParameters();
        // custom adjustment can be specified
        break;
      case 'france_uoif':
        params = CalculationMethod.muslim_world_league.getParameters();
        params.fajrAngle = 12.0;
        params.ishaAngle = 12.0;
        break;
      default:
        params = CalculationMethod.muslim_world_league.getParameters();
    }

    params.madhab = madhab == 'Hanafi' ? Madhab.hanafi : Madhab.shafi;


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

  static DailyPrayerTimes calculateForToday({
    required double latitude,
    required double longitude,
    String method = 'Muslim World League',
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
