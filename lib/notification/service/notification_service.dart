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


  tz.initializeTimeZones();
  await Hive.initFlutter();
  
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(MedicationModelAdapter());
  }

 
  final settings = await Hive.openBox('users_box');
  final String boxName = settings.get('current_user_box', defaultValue: 'default_box');
  final box = await Hive.openBox<MedicationModel>(boxName);

  if (actionId == 'take_action') {
    final med = box.get(medicationId);
    if (med != null) {
   
    final updatedMed = med.copyWith(
      isTaken: true,
      lastTakenDate: DateTime.now(),
    );
      
      await box.put(medicationId, updatedMed);
      print("Done: Medication marked as taken with timestamp");
    }
  } 
  else if (actionId == 'snooze_action') {
    final med = box.get(medicationId);
    if (med != null) {
      // تنفيذ السنوز بـ 5 دقائق
      await snoozeNotification(med);
      print("Snooze: Scheduled for 5 minutes later");
    }
  }
}static Future<void> scheduleNotification({
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
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);


    AndroidScheduleMode scheduleMode = AndroidScheduleMode.exactAllowWhileIdle;

    if (frequency == 'Interval' && intervalHours != null && intervalHours > 0) {
      int occurrencesPerDay = 24 ~/ intervalHours;

      for (int i = 0; i < occurrencesPerDay; i++) {
        DateTime instanceTime = scheduledTime.add(Duration(hours: i * intervalHours));
        tz.TZDateTime scheduledDate = tz.TZDateTime.from(instanceTime, tz.local);

        while (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
          scheduledDate = scheduledDate.add(const Duration(days: 1));
        }

        try {
          await _notificationsPlugin.zonedSchedule(
            id + i,
            'MedPluse Reminder',
            'It\'s time for $medicationName ($dosage)',
            scheduledDate,
            platformDetails,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: scheduleMode,
            matchDateTimeComponents: DateTimeComponents.time, 
            payload: medicationId,
          );
        } catch (e) {

          print("Switching to standard exact mode due to permission constraints");
          await _notificationsPlugin.zonedSchedule(
            id + i,
            'MedPluse Reminder',
            'It\'s time for $medicationName ($dosage)',
            scheduledDate,
            platformDetails,
            uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.exact,
            matchDateTimeComponents: DateTimeComponents.time, 
            payload: medicationId,
          );
        }
      }
    } else {
      tz.TZDateTime scheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);
      
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5));
      }

      try {
        await _notificationsPlugin.zonedSchedule(
          id,
          'MedPluse Reminder',
          'It\'s time for $medicationName ($dosage)',
          scheduledDate,
          platformDetails,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: scheduleMode,
          matchDateTimeComponents: frequency == 'Daily'
              ? DateTimeComponents.time
              : (frequency == 'Weekly' ? DateTimeComponents.dayOfWeekAndTime : null),
          payload: medicationId,
        );
      } catch (e) {
   
        await _notificationsPlugin.zonedSchedule(
          id,
          'MedPluse Reminder',
          'It\'s time for $medicationName ($dosage)',
          scheduledDate,
          platformDetails,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
          androidScheduleMode: AndroidScheduleMode.exact,
          matchDateTimeComponents: frequency == 'Daily'
              ? DateTimeComponents.time
              : (frequency == 'Weekly' ? DateTimeComponents.dayOfWeekAndTime : null),
          payload: medicationId,
        );
      }
    }
  }
   
  static Future<void> snoozeNotification(MedicationModel medication) async {
   
    final nextTime = DateTime.now().add(const Duration(minutes: 5));
    
    
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    await scheduleNotification(
      medicationId: medication.id,
      id: (medication.id.hashCode + DateTime.now().millisecond).abs(),
      medicationName: medication.name,
      dosage: medication.dosage,
      scheduledTime: nextTime,
      frequency: 'Once',
    );
  }

static Future<void> requestPermissions() async {
  try {

    final androidNotificationPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        
    if (androidNotificationPlugin != null) {
      await androidNotificationPlugin.requestNotificationsPermission();
    }

    
    if (androidNotificationPlugin != null) {
      await androidNotificationPlugin.requestExactAlarmsPermission();
    }
    
    print("Permissions requested successfully sequentially.");
  } catch (e) {
    print("Error while requesting permissions: $e");
  }
}

static Future<void> cancelNotification(int id) async {

    await _notificationsPlugin.cancel(id);
    for (int i = 1; i <= 24; i++) {
      await _notificationsPlugin.cancel(id + i);
    }
    print("All scheduled notifications for ID $id have been canceled.");
  }
}