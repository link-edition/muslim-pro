import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_pro/core/notification_service.dart';
import 'package:muslim_pro/features/namoz/data/prayer_storage.dart';

class SettingsState {
  final bool notificationsEnabled;
  final String language;
  final Map<String, bool> enabledPrayers;

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
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    String? language,
    Map<String, bool>? enabledPrayers,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      enabledPrayers: enabledPrayers ?? this.enabledPrayers,
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
