import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_pro/core/notification_service.dart';
import 'package:muslim_pro/features/namoz/data/prayer_storage.dart';

class SettingsState {
  final bool notificationsEnabled;
  final String language;
  final Map<String, bool> enabledPrayers;
  final String calculationMethod;
  final String madhab;
  final String cityName;
  final double? latitude;
  final double? longitude;
  final bool isAutoLocation;
  final bool adhanEnabled;
  final String selectedAdhan;
  final bool isDarkMode;
  final double fontScale;
  final bool prePrayerReminderEnabled;
  final bool jumaReminderEnabled;



  SettingsState({
    this.notificationsEnabled = true,
    this.language = 'uz',
    this.enabledPrayers = const {
      'Bomdod': true,
      'Peshin': true,
      'Asr': true,
      'Shom': true,
      'Xufton': true,
    },
    this.calculationMethod = 'Uzbekistan',
    this.madhab = 'Hanafi',
    this.cityName = 'Toshkent',
    this.latitude,
    this.longitude,
    this.isAutoLocation = true,
    this.adhanEnabled = false,
    this.selectedAdhan = 'makkah',
    this.isDarkMode = true,
    this.fontScale = 0.9,
    this.prePrayerReminderEnabled = true,
    this.jumaReminderEnabled = true,
  });



  SettingsState copyWith({
    bool? notificationsEnabled,
    String? language,
    Map<String, bool>? enabledPrayers,
    String? calculationMethod,
    String? madhab,
    String? cityName,
    double? latitude,
    double? longitude,
    bool? isAutoLocation,
    bool? adhanEnabled,
    String? selectedAdhan,
    bool? isDarkMode,
    double? fontScale,
    bool? prePrayerReminderEnabled,
    bool? jumaReminderEnabled,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      enabledPrayers: enabledPrayers ?? this.enabledPrayers,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      cityName: cityName ?? this.cityName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAutoLocation: isAutoLocation ?? this.isAutoLocation,
      adhanEnabled: adhanEnabled ?? this.adhanEnabled,
      selectedAdhan: selectedAdhan ?? this.selectedAdhan,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      fontScale: fontScale ?? this.fontScale,
      prePrayerReminderEnabled: prePrayerReminderEnabled ?? this.prePrayerReminderEnabled,
      jumaReminderEnabled: jumaReminderEnabled ?? this.jumaReminderEnabled,
    );
  }
}



class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    final Map<String, bool> enabled = {};
    final prayers = ['Bomdod', 'Peshin', 'Asr', 'Shom', 'Xufton'];
    for (var prayer in prayers) {
      enabled[prayer] = prefs.getBool('enabled_$prayer') ?? true;
    }

    state = state.copyWith(
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      language: prefs.getString('language') ?? 'uz',
      enabledPrayers: enabled,
      calculationMethod: prefs.getString('calculation_method') ?? 'Uzbekistan',
      madhab: prefs.getString('madhab') ?? 'Hanafi',
      cityName: prefs.getString('city_name') ?? 'Toshkent',
      latitude: prefs.getDouble('latitude'),
      longitude: prefs.getDouble('longitude'),
      isAutoLocation: prefs.getBool('is_auto_location') ?? true,
      adhanEnabled: prefs.getBool('adhan_enabled') ?? false,
      selectedAdhan: prefs.getString('selected_adhan') ?? 'makkah',
      isDarkMode: prefs.getBool('is_dark_mode') ?? true,
      fontScale: prefs.getDouble('font_scale') ?? 0.9,
      prePrayerReminderEnabled: prefs.getBool('pre_prayer_reminder') ?? true,
      jumaReminderEnabled: prefs.getBool('juma_reminder') ?? true,
    );
  }

  Future<void> toggleTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', value);
    state = state.copyWith(isDarkMode: value);
  }

  Future<void> setFontScale(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_scale', value);
    state = state.copyWith(fontScale: value);
  }



  Future<void> toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    state = state.copyWith(notificationsEnabled: value);
    _rescheduleNotifications();
  }

  Future<void> toggleAdhan(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adhan_enabled', value);
    state = state.copyWith(adhanEnabled: value);
    _rescheduleNotifications();
  }

  Future<void> setSelectedAdhan(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_adhan', value);
    state = state.copyWith(selectedAdhan: value);
    _rescheduleNotifications();
  }

  Future<void> togglePrePrayerReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('pre_prayer_reminder', value);
    state = state.copyWith(prePrayerReminderEnabled: value);
    _rescheduleNotifications();
  }

  Future<void> toggleJumaReminder(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('juma_reminder', value);
    state = state.copyWith(jumaReminderEnabled: value);
    _rescheduleNotifications();
  }



  Future<void> togglePrayerNotification(String prayerName, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enabled_$prayerName', value);
    
    final newEnabled = Map<String, bool>.from(state.enabledPrayers);
    newEnabled[prayerName] = value;
    state = state.copyWith(enabledPrayers: newEnabled);
    _rescheduleNotifications();
  }

  Future<void> setCalculationMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('calculation_method', method);
    state = state.copyWith(calculationMethod: method);
  }

  Future<void> setMadhab(String madhab) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('madhab', madhab);
    state = state.copyWith(madhab: madhab);
  }

  Future<void> setCity({
    required String name,
    required double lat,
    required double lng,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('city_name', name);
    await prefs.setDouble('latitude', lat);
    await prefs.setDouble('longitude', lng);
    await prefs.setBool('is_auto_location', false);
    
    state = state.copyWith(
      cityName: name,
      latitude: lat,
      longitude: lng,
      isAutoLocation: false,
    );
  }

  Future<void> setAutoLocation(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_auto_location', value);
    state = state.copyWith(isAutoLocation: value);
  }

  /// Settings o'zgarganda bildirishnomalarni qayta rejalashtirish
  Future<void> _rescheduleNotifications() async {
    // PrayerProvider dan joriy vaqtlarni olib bo'lmaydi (circular dependency bo'lmasligi uchun),
    // shuning uchun PrayerStorage dan yuklaymiz.
    final cached = await PrayerStorage.loadPrayerTimes();
    if (cached != null) {
      await NotificationService.schedulePrayerNotifications(cached);
    }
  }

  Future<void> setLanguage(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', value);
    state = state.copyWith(language: value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});
