import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
    // Avvalgi barcha bildirishnomalarni o'chirish
    await _notificationsPlugin.cancelAll();

    for (var prayer in prayerTimes.prayers) {
      if (prayer.name == 'Quyosh') continue; // Quyosh uchun bildirishnoma shart emas

      final scheduledDate = tz.TZDateTime.from(prayer.time, tz.local);
      
      // Agar vaqt o'tib ketgan bo'lsa, rejalashtirmaymiz
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) continue;

      await _notificationsPlugin.zonedSchedule(
        prayer.name.hashCode,
        'Namoz vaqti',
        '${prayer.name} vaqti bo\'ldi',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_reminders',
            'Namoz vaqtlari',
            channelDescription: 'Namoz vaqtlari uchun bildirishnomalar',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
