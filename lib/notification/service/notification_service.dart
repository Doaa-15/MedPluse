import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  @pragma('vm:entry-point')
  static void onNotificationTap(NotificationResponse details) async {
    final String? actionId = details.actionId;
    final String? medicationId = details.payload;

    if (medicationId == null) return;

    // 1. تهيئة الـ Timezones والـ Hive ضروري جداً في الـ Isolate المنفصل
    tz.initializeTimeZones();
    await Hive.initFlutter();
    
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicationModelAdapter());
    }

    // 2. فتح الـ Boxes للوصول للبيانات
    final settings = await Hive.openBox('users_box');
    final String boxName = settings.get('current_user_box', defaultValue: 'default_box');
    final box = await Hive.openBox<MedicationModel>(boxName);

    if (actionId == 'take_action') {
      final med = box.get(medicationId);
      if (med != null) {
        med.isTaken = true; 
        await box.put(medicationId, med);
        print("Done: Medication marked as taken");
      }
    } 
    else if (actionId == 'snooze_action') {
      final med = box.get(medicationId);
      if (med != null) {
        // تنفيذ السنوز
        await snoozeNotification(med);
        print("Snooze: Scheduled for 5 minutes later");
      }
    }
  }

static Future<void> scheduleNotification({
    required String medicationId,
    required int id,
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
    required String frequency,
    int? intervalHours,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'med_channel',
      'Medication Reminders',
      importance: Importance.max,
      priority: Priority.high,
      fullScreenIntent: true,
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'take_action',
          'Take',
          showsUserInterface: true,
          cancelNotification: true,
        ),
        AndroidNotificationAction(
          'snooze_action',
          'Snooze',
          showsUserInterface: false,
          cancelNotification: true,
        ),
      ],
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

    if (frequency == 'Interval' && intervalHours != null && intervalHours > 0) {
      int occurrencesPerDay = 24 ~/ intervalHours;
      
      for (int i = 0; i < occurrencesPerDay; i++) {
        DateTime instanceTime = scheduledTime.add(Duration(hours: i * intervalHours));
        tz.TZDateTime scheduledDate = tz.TZDateTime.from(instanceTime, tz.local);
        
        if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        await _notificationsPlugin.zonedSchedule(
          id + i, 
          'MedSync Reminder',
          'It\'s time for $medicationName ($dosage)',
          scheduledDate,
          platformDetails,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.time,
          payload: medicationId,
        );
      }
    } else {
      // الجدولة العادية (يومي أو أسبوعي أو مرة واحدة)
      await _notificationsPlugin.zonedSchedule(
        id,
        'MedPluse Reminder',
        'It\'s time for $medicationName ($dosage)',
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformDetails,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: frequency == 'Daily'
            ? DateTimeComponents.time
            : (frequency == 'Weekly' ? DateTimeComponents.dayOfWeekAndTime : null),
        payload: medicationId,
      );
    }
  }
  static Future<void> snoozeNotification(MedicationModel medication) async {
    // تحديد وقت الغفوة (5 دقائق من الآن)
    final nextTime = DateTime.now().add(const Duration(minutes: 5));
    
    // التأكد من تهيئة الوقت قبل الجدولة (احتياطاً للـ Isolate)
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    await scheduleNotification(
      medicationId: medication.id,
      id: (medication.id.hashCode + DateTime.now().millisecond).abs(), // ID مختلف عشان ميمسحش القديم
      medicationName: medication.name,
      dosage: medication.dosage,
      scheduledTime: nextTime,
      frequency: 'Once',
    );
  }

  static Future<void> requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  }
  // داخل كلاس NotificationService
static Future<void> cancelNotification(int id) async {
    // 1. مسح الـ ID الأساسي
    await _notificationsPlugin.cancel(id);
    
    // 2. مسح أي احتمالات لـ IDs تانية لو كان الدواء Interval
    for (int i = 1; i <= 24; i++) {
      await _notificationsPlugin.cancel(id + i);
    }
    print("All scheduled notifications for ID $id have been canceled.");
  }
}