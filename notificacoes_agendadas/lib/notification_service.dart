import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          windows: const WindowsInitializationSettings(
            appName: 'Notificações Agendadas',
            appUserModelId: 'com.example.notificacoes_agendadas',
            // Use um GUID gerado para seu app, exemplo abaixo:
            guid: 'd49b0314-ee7a-4626-bf79-97cdb8a991bb',
          ),
        );
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Apenas para debug, pode abrir uma tela ou logar
        print('Notificação clicada: ${response.payload}');
      },
    );
  }

  static Future<void> scheduleNotification(
    DateTime scheduledDate,
    String title,
    String body,
  ) async {
    print('Agendando notificação para: $scheduledDate');
    await _notificationsPlugin.zonedSchedule(
      0,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'main_channel',
          'Main Channel',
          channelDescription: 'Main channel notifications',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
