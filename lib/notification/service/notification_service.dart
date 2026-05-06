import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:reminder/feature/medications/data/models/medication_model.dart';
import 'package:reminder/feature/medications/data/repositories/medication_repository_impl.dart';

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
      onDidReceiveBackgroundNotificationResponse: onNotificationTap, // ضروري للأزرار
    );
  }

  // نقطة الدخول للأكشنز في الخلفية
@pragma('vm:entry-point')
  static void onNotificationTap(NotificationResponse details) async {
    final String? actionId = details.actionId;
    final String? medicationId = details.payload;

    if (medicationId == null) return;

    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(MedicationModelAdapter());
    }

    // هاتي اسم البوكس الصحيح من الـ settings زي ما بتعملي في الـ Cubit
    final settings = await Hive.openBox('users_box');
    final String boxName = settings.get('current_user_box', defaultValue: 'default_box');

    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox<MedicationModel>(boxName);
    }

    final repository = MedicationRepositoryImpl();

  if (actionId == 'take_action') {
  final repository = MedicationRepositoryImpl();
  // تأكدي إن الميثود دي جواها بتفتح البوكس، بتعدل، ثم بتعمل put
  await repository.updateMedicationStatus(medicationId, true);
  print("Medication marked as taken from Notification Action");
  
  // ملحوظة: الـ Hive بيحتاج أحياناً وقت بسيط عشان يكتب في الملف، 
  // الـ ValueListenableBuilder في الهوم المفروض يلقط ده لوحده.
}
    
      
      
     else if (actionId == 'snooze_action') {
      // 2. تنفيذ الـ Snooze (غفوة 5 دقائق)
      final meds = await repository.getMedications();
      try {
        final med = meds.firstWhere((e) => e.id == medicationId);
        await snoozeNotification(med as MedicationModel);
      } catch (e) {
        print("Error snoozing: $e");
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
      fullScreenIntent: true, // ضيفي السطر ده
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'take_action', 
          'Take', 
          showsUserInterface: true, // ده هيفتح التطبيق ويشغل الـ Listener
          cancelNotification: true, // يقفل الإشعار بعد الضغط
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
          'MedPluse Reminder',
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
    final nextTime = DateTime.now().add(const Duration(minutes: 5));
    await scheduleNotification(
      medicationId: medication.id,
      id: (medication.id.hashCode + 999).abs(), // ID فريد للسنوز
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
}