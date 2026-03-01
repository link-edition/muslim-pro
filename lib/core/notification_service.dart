import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import '../features/namoz/data/prayer_model.dart';
import '../features/namoz/data/prayer_times_service.dart';

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

  static Future<void> schedulePrayerNotifications(DailyPrayerTimes basePrayerTimes) async {
    final prefs = await SharedPreferences.getInstance();
    final isNotificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
    final isAdhanEnabled = prefs.getBool('adhan_enabled') ?? false;
    final selectedAdhan = prefs.getString('selected_adhan') ?? 'makkah';
    
    // Namoz hisoblari sozlamalari
    final method = prefs.getString('calculation_method') ?? 'Uzbekistan';
    final madhab = prefs.getString('madhab') ?? 'Hanafi';
    
    final isPrePrayerEnabled = prefs.getBool('pre_prayer_reminder') ?? true;
    final isJumaEnabled = prefs.getBool('juma_reminder') ?? true;

    // Avvalgi barcha bildirishnomalarni o'chirish
    await _notificationsPlugin.cancelAll();

    if (!isNotificationsEnabled) return;

    // Eng ko'pi bilan 30 kunlik (on-device, offline) rejalashtiramiz
    // Adhan kutubxonasi xotirada tez hisoblaydi, internet talab qilmaydi
    for (int i = 0; i < 30; i++) {
       final targetDate = DateTime.now().add(Duration(days: i));
       
       final dailyTimes = PrayerTimesService.calculateForDate(
         date: targetDate,
         latitude: basePrayerTimes.latitude,
         longitude: basePrayerTimes.longitude,
         method: method,
         madhab: madhab,
       );

       for (var prayer in dailyTimes.prayers) {
         if (prayer.name == 'Quyosh') continue; // Quyosh uchun bildirishnoma shart emas

         // Har bir namoz uchun alohida sozlamani tekshirish
         final isPrayerEnabled = prefs.getBool('enabled_${prayer.name}') ?? true;
         if (!isPrayerEnabled) continue;

         final scheduledDate = tz.TZDateTime.from(prayer.time, tz.local);
         
         // Agar vaqt o'tib ketgan bo'lsa, rejalashtirmaymiz
         if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) continue;

         // Maxsus Notification ID (Misol: 12051 - i.e. 12 oy, 05 kun, id 1)
         final notificationId = int.parse('${targetDate.month}${targetDate.day}${prayer.name.hashCode.abs().toString().substring(0, 3)}');

         final androidDetails = AndroidNotificationDetails(
           isAdhanEnabled ? 'adhan_channel_id_$selectedAdhan' : 'prayer_reminders_id_silent',
           isAdhanEnabled ? 'Azon (Ovozli)' : 'Namoz (Ovozsiz)',
           channelDescription: 'Namoz vaqtlari uchun ogohlantirish',
           importance: Importance.max,
           priority: Priority.high,
           playSound: isAdhanEnabled,
           enableVibration: true,
           sound: isAdhanEnabled ? RawResourceAndroidNotificationSound(selectedAdhan) : null,
           audioAttributesUsage: isAdhanEnabled ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
           category: isAdhanEnabled ? AndroidNotificationCategory.alarm : AndroidNotificationCategory.reminder,
           actions: isAdhanEnabled
               ? <AndroidNotificationAction>[
                   const AndroidNotificationAction(
                     'stop_sound',
                     '          🛑 OVOZNI TO\'XTATISH 🛑          ',
                     cancelNotification: true,
                     showsUserInterface: true,
                   ),
                 ]
               : null,
         );

         final iosDetails = DarwinNotificationDetails(
           presentSound: isAdhanEnabled,
           sound: isAdhanEnabled ? '$selectedAdhan.mp3' : null,
         );

         try {
           await _notificationsPlugin.zonedSchedule(
             notificationId,
             '🕌 Namoz vaqti: ${prayer.name}',
             '${prayer.name} namozi vaqti bo\'ldi.',
             scheduledDate,
             NotificationDetails(
               android: androidDetails,
               iOS: iosDetails,
             ),
             androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
             uiLocalNotificationDateInterpretation:
                 UILocalNotificationDateInterpretation.absoluteTime,
           );
         } catch (e) {
           // Agar exact alarm ruxsati berilmagan bo'lsa (Android 12+ xususiyligi), inexact rejimda rejalashtiramiz
           await _notificationsPlugin.zonedSchedule(
             notificationId,
             '🕌 Namoz vaqti: ${prayer.name}',
             '${prayer.name} namozi vaqti kirdi',
             scheduledDate,
             NotificationDetails(
               android: androidDetails,
               iOS: iosDetails,
             ),
             androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
             uiLocalNotificationDateInterpretation:
                 UILocalNotificationDateInterpretation.absoluteTime,
           );
         }

         // PRE-PRAYER REMINDER (10 MINUTES BEFORE)
         if (isPrePrayerEnabled) {
           final prePrayerDate = scheduledDate.subtract(const Duration(minutes: 10));
           if (prePrayerDate.isAfter(tz.TZDateTime.now(tz.local))) {
             final prePrayerId = int.parse('10${targetDate.month}${targetDate.day}${prayer.name.hashCode.abs().toString().substring(0, 3)}');
             
             const preAndroidDetails = AndroidNotificationDetails(
               'pre_prayer_id',
               'Namozdan oldin',
               channelDescription: 'Namozdan 10 daqiqa oldin eslatma',
               importance: Importance.max,
               priority: Priority.high,
               playSound: true,
               sound: RawResourceAndroidNotificationSound('tasbeh_done'),
             );
             
             const preIosDetails = DarwinNotificationDetails(
               presentSound: true,
               sound: 'tasbeh_done.wav',
             );

             try {
               await _notificationsPlugin.zonedSchedule(
                 prePrayerId,
                 'Namoz vaqti yaqinlashmoqda',
                 '${prayer.name} namoziga 10 daqiqa qoldi.',
                 prePrayerDate,
                 const NotificationDetails(android: preAndroidDetails, iOS: preIosDetails),
                 androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
                 uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
               );
             } catch (e) {
               await _notificationsPlugin.zonedSchedule(
                 prePrayerId,
                 'Namoz vaqti yaqinlashmoqda',
                 '${prayer.name} namoziga 10 daqiqa qoldi.',
                 prePrayerDate,
                 const NotificationDetails(android: preAndroidDetails, iOS: preIosDetails),
                 androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
                 uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
               );
             }
           }
         }
       }

       // JUMA SALAWAT REMINDER (FRIDAY ONLY 10:00 AM)
       if (isJumaEnabled && targetDate.weekday == DateTime.friday) {
         final jumaDate = tz.TZDateTime(tz.local, targetDate.year, targetDate.month, targetDate.day, 10, 0);
         if (jumaDate.isAfter(tz.TZDateTime.now(tz.local))) {
           final jumaId = int.parse('99${targetDate.month}${targetDate.day}');
           
           const jumaAndroidDetails = AndroidNotificationDetails(
             'juma_reminder_id',
             'Juma salovoti',
             channelDescription: 'Juma kunlari salovot aytish eslatmasi',
             importance: Importance.defaultImportance,
             priority: Priority.defaultPriority,
             playSound: false,
             enableVibration: false,
           );
           
           const jumaIosDetails = DarwinNotificationDetails(presentSound: false);

           try {
             await _notificationsPlugin.zonedSchedule(
               jumaId,
               'Bugun Juma',
               'Siz bugun Payg\'ambarimizga salovat aytdingizmi?',
               jumaDate,
               const NotificationDetails(android: jumaAndroidDetails, iOS: jumaIosDetails),
               androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
               uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
             );
           } catch (e) {
             await _notificationsPlugin.zonedSchedule(
               jumaId,
               'Bugun Juma',
               'Siz bugun Payg\'ambarimizga salovat aytdingizmi?',
               jumaDate,
               const NotificationDetails(android: jumaAndroidDetails, iOS: jumaIosDetails),
               androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
               uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
             );
           }
         }
       }
    }
  }

  static Future<void> testAdhanNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final isAdhanEnabled = prefs.getBool('adhan_enabled') ?? false;
    final selectedAdhan = prefs.getString('selected_adhan') ?? 'makkah';

    final androidDetails = AndroidNotificationDetails(
      isAdhanEnabled ? 'adhan_channel_id_$selectedAdhan' : 'prayer_reminders_id_silent',
      isAdhanEnabled ? 'Azon (Ovozli)' : 'Namoz (Ovozsiz)',
      channelDescription: 'Namoz vaqtlari uchun test',
      importance: Importance.max,
      priority: Priority.high,
      playSound: isAdhanEnabled,
      enableVibration: true,
      sound: isAdhanEnabled ? RawResourceAndroidNotificationSound(selectedAdhan) : null,
      audioAttributesUsage: isAdhanEnabled ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
      category: isAdhanEnabled ? AndroidNotificationCategory.alarm : AndroidNotificationCategory.reminder,
      actions: isAdhanEnabled
          ? <AndroidNotificationAction>[
              const AndroidNotificationAction(
                'stop_sound',
                '          🛑 OVOZNI TO\'XTATISH 🛑          ',
                cancelNotification: true,
                showsUserInterface: true,
              ),
            ]
          : null,
    );

    final iosDetails = DarwinNotificationDetails(
      presentSound: isAdhanEnabled,
      sound: isAdhanEnabled ? '$selectedAdhan.mp3' : null,
    );

    final targetDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 2));

    await _notificationsPlugin.zonedSchedule(
      99999,
      '🕌 Sinov Azoni',
      'Bu azon ishlashini tekshirish uchun sinov bildirishnomasi.',
      targetDate,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
