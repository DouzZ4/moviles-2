import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _notifications = FlutterLocalNotificationsPlugin();

  // Inicializar las notificaciones
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const WindowsInitializationSettings windowsSettings =
        WindowsInitializationSettings(
          appName: 'CheckINC',
          appUserModelId: 'com.example.checkinc',
          guid: '12345678-1234-1234-1234-123456789abc',
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      windows: windowsSettings,
    );

    await _notifications.initialize(settings);

    // Inicializar zona horaria para programar correctamente
    tz.initializeTimeZones();
  }

  // Programar una notificación futura
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime dateTime,
  }) async {
    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(dateTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'recordatorios_channel',
          'Recordatorios',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  // Cancelar notificación
  static Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }
}
