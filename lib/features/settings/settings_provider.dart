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
    );
  }

  Future<void> toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    state = state.copyWith(notificationsEnabled: value);
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
