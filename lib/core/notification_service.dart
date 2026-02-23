import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../features/namoz/data/prayer_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
    );
  }

  static Future<void> schedulePrayerNotifications(DailyPrayerTimes prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();
    final isNotificationsEnabled = prefs.getBool('notifications_enabled') ?? true;

    // Avvalgi barcha bildirishnomalarni o'chirish
    await _notificationsPlugin.cancelAll();

    if (!isNotificationsEnabled) return;

    for (var prayer in prayerTimes.prayers) {
      if (prayer.name == 'Quyosh') continue; // Quyosh uchun bildirishnoma shart emas

      // Har bir namoz uchun alohida sozlamani tekshirish
      final isPrayerEnabled = prefs.getBool('enabled_${prayer.name}') ?? true;
      if (!isPrayerEnabled) continue;

      final scheduledDate = tz.TZDateTime.from(prayer.time, tz.local);
      
      // Agar vaqt o'tib ketgan bo'lsa, rejalashtirmaymiz
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) continue;

      try {
        await _notificationsPlugin.zonedSchedule(
          prayer.name.hashCode,
          'Namoz vaqti bo\'ldi: ${prayer.name}',
          '${prayer.name} namozi vaqti kirdi.',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_reminders_id',
              'Namoz vaqtlari',
              channelDescription: 'Namoz vaqtlari uchun bildirishnomalar',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      } catch (e) {
        // Agar exact alarm ruxsati berilmagan bo'lsa, inexact rejimda rejalashtiramiz
        await _notificationsPlugin.zonedSchedule(
          prayer.name.hashCode,
          'Namoz vaqti bo\'ldi: ${prayer.name}',
          '${prayer.name} namozi vaqti kirdi.',
          scheduledDate,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'prayer_reminders_id',
              'Namoz vaqtlari',
              channelDescription: 'Namoz vaqtlari uchun bildirishnomalar',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
            iOS: DarwinNotificationDetails(
              presentSound: true,
            ),
          ),
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }
}
