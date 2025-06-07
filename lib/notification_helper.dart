import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';
import 'quote_service.dart';

class NotifHelper {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static const _channel = AndroidNotificationChannel(
    'daily_quotes',
    'Daily Quotes',
    description: 'Notification quotidienne de la citation du jour',
    importance: Importance.high,
  );

  static Future<void> init() async {
    tz.initializeTimeZones();
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await _plugin.initialize(initSettings);
  }

  /* ---------------- scheduling ---------------- */
  static Future<void> scheduleDaily(int hour, int minute) async {
    // Annule l'ancienne
    await _plugin.cancel(0);

    final quote = await QuoteService.daily();

    await _plugin.zonedSchedule(
      0,
      'Citation du jour',
      '"${quote.citation}" — ${quote.auteur}',
      _nextInstance(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quotes',
          'Daily Quotes',
          channelDescription: 'Citation quotidienne',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // répète chaque jour
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enabled', true);
    await prefs.setString('time', '${hour.toString().padLeft(2, '0')}:$minute');
  }

  static Future<void> disable() async {
    await _plugin.cancel(0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enabled', false);
  }

  static tz.TZDateTime _nextInstance(int h, int m) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
    if (scheduled.isBefore(now))
      scheduled = scheduled.add(const Duration(days: 1));
    return scheduled;
  }

  /* ---------------- helpers ---------------- */
  static Future<(bool enabled, int hour, int minute)> prefs() async {
    final p = await SharedPreferences.getInstance();
    final enabled = p.getBool('enabled') ?? true;
    final timeStr = p.getString('time') ?? '10:00';
    final parts = timeStr.split(':').map(int.parse).toList();
    return (enabled, parts[0], parts[1]);
  }
}
