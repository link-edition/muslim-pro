/// Ilovadagi umumiy konstantalar
class AppConstants {
  // Ilova nomi
  static const String appName = 'Muslim Pro';
  static const String appVersion = '1.0.0';

  // API URL (kelajakda ishlatiladi)
  static const String baseApiUrl = 'https://api.aladhan.com/v1';

  // Namoz vaqtlari
  static const List<String> prayerNames = [
    'Bomdod',
    'Quyosh',
    'Peshin',
    'Asr',
    'Shom',
    'Xufton',
  ];

  // Tasbeh uchun zikrlar
  static const List<Map<String, dynamic>> defaultDhikrs = [
    {'name': 'SubhanAlloh', 'arabic': 'سبحان الله', 'target': 33},
    {'name': 'Alhamdulillah', 'arabic': 'الحمد لله', 'target': 33},
    {'name': 'Allohu Akbar', 'arabic': 'الله أكبر', 'target': 34},
    {'name': 'La ilaha illAlloh', 'arabic': 'لا إله إلا الله', 'target': 100},
    {'name': 'Astag\'firulloh', 'arabic': 'أستغفر الله', 'target': 100},
    {'name': 'Salavot', 'arabic': 'اللهم صل على محمد', 'target': 100},
  ];

  // SharedPreferences kalitlari
  static const String prefThemeMode = 'theme_mode';
  static const String prefLastLatitude = 'last_latitude';
  static const String prefLastLongitude = 'last_longitude';
  static const String prefCalculationMethod = 'calculation_method';
  static const String prefTasbehCount = 'tasbeh_count';
}
