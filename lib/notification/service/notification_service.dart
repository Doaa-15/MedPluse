import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // 1. تهيئة النظام
  static Future<void> init() async {
    tz.initializeTimeZones();
    // ضبط التوقيت المحلي للجهاز
tz.initializeTimeZones();
      
      // السطر ده اتغير لـ FlutterTimezone بدلاً من FlutterNativeTimezone
      final String timeZoneName = await FlutterTimezone.getLocalTimezone(); 
      tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher'); // تأكدي من وجود الأيقونة

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        // هنا هندلة الأزرار (Take / Snooze)
        if (details.actionId == 'take') {
          print("User marked medication as Taken");
          // هنا ممكن تنادي ميثود من الـ Cubit لتحديث الـ Hive
        } else if (details.actionId == 'snooze') {
          print("User clicked Snooze");
          // هنا ممكن تعملي جدولة تانية بعد 10 دقائق
        }
      },
    );
  }

  // 2. طلب الصلاحيات (Permissions)
  static Future<void> requestPermissions() async {
    // إذن الإشعارات للأندرويد 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    // إذن المنبه الدقيق (Exact Alarm)
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }

  // 3. جدولة التنبيه (Schedule)
  static Future<void> scheduleNotification({
  required int id,
  required String medicationName,
  required String dosage,
  required DateTime scheduledTime,
  required String frequency, // 'Daily' or 'Weekly'
}) async {
  await _notificationsPlugin.zonedSchedule(
    id,
    'PluseMed Reminder',
    'It\'s time for your $medicationName ($dosage)',
    tz.TZDateTime.from(scheduledTime, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'med_sync_channel',
        'Medication Reminders',
        channelDescription: 'Notifications for medication schedules',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',

        // 👇 الأزرار
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'take',
            'Take',
            showsUserInterface: true,
            cancelNotification: true,
          ),
          AndroidNotificationAction(
            'snooze',
            'Snooze',
            showsUserInterface: false,
          ),
        ],
      ),
    ),

    // ✅ مهم جدًا
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,

    // ✅ مهم للأندرويد الحديث
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

    // ✅ التكرار
    matchDateTimeComponents: frequency == 'Daily'
        ? DateTimeComponents.time
        : DateTimeComponents.dayOfWeekAndTime,
  );
}

  // 4. إلغاء تنبيه معين (عند حذف الدواء مثلاً)
  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // 5. إلغاء كل التنبيهات
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}