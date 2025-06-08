import 'dart:convert';
import 'package:flutter/material.dart';
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
    enableVibration: true,
    playSound: true,
  );

  static Future<void> init() async {
    tz.initializeTimeZones();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(_channel);

    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        notificationCategories: [
          DarwinNotificationCategory(
            'daily_quotes',
            actions: <DarwinNotificationAction>[
              DarwinNotificationAction.plain('id_1', 'Voir'),
            ],
          )
        ],
      ),
    );
    await _plugin.initialize(initSettings);
  }

  /* ------------------ Vérification des permissions ------------------ */
  static Future<bool> checkPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final iOS = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();

    bool? enabled;
    if (android != null) {
      enabled = await android.areNotificationsEnabled();
    } else if (iOS != null) {
      enabled = await iOS.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    return enabled ?? false;
  }

  /* ------------------ Planification quotidienne ------------------ */
  static Future<void> scheduleDaily(int hour, int minute) async {
    try {
      await _plugin.cancel(0);

      final quote = await QuoteService.daily();
      final payload = jsonEncode({
        'citation': quote.citation,
        'auteur': quote.auteur,
        'date': DateTime.now().toIso8601String(),
      });

      await _plugin.zonedSchedule(
        0,
        'Citation du jour',
        '"${quote.citation}" — ${quote.auteur}',
        _nextInstance(hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableLights: true,
            ledColor: Colors.blue,
          ),
          iOS: DarwinNotificationDetails(
            categoryIdentifier: 'daily_quotes',
            threadIdentifier: 'daily-quotes',
          ),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('enabled', true);
      await prefs.setString(
          'time', '${hour.toString().padLeft(2, '0')}:$minute');
    } catch (e, stack) {
      debugPrint('Erreur de planification: $e');
      debugPrint(stack.toString());
      // Fallback: Réessayer avec des paramètres simplifiés
      await _scheduleFallback(hour, minute);
    }
  }

  static Future<void> _scheduleFallback(int h, int m) async {
    await _plugin.zonedSchedule(
      0,
      'Citation du jour',
      'Nouvelle citation disponible',
      _nextInstance(h, m),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_quotes',
          'Daily Quotes',
          channelDescription: 'Citation quotidienne',
        ),
      ),
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstance(int h, int m) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, h, m);
    return scheduled.isBefore(now)
        ? scheduled.add(const Duration(days: 1))
        : scheduled;
  }

  /* ------------------ Désactivation ------------------ */
  static Future<void> disable() async {
    await _plugin.cancel(0);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enabled', false);
  }

  /* ------------------ Helpers ------------------ */
  static Future<(bool enabled, int hour, int minute)> prefs() async {
    final p = await SharedPreferences.getInstance();
    final enabled = p.getBool('enabled') ?? false;
    final timeStr = p.getString('time') ?? '10:00';
    final parts = timeStr.split(':').map(int.parse).toList();
    return (enabled, parts[0], parts[1]);
  }
}
