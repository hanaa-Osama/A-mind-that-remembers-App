import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  NotificationService._internal();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  static const Color roseGold = Color(0xFFB76E79);

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(initSettings);

    tz.initializeTimeZones();
  }

  Future<void> scheduleMemoryNotification({
    required int id,
    required String body,
    required DateTime dateTime,
  }) async {
    final tz.TZDateTime scheduled =
    tz.TZDateTime.from(dateTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'memories_channel',
      'تذكير لحظة ذِكرى',
      channelDescription:
      'إشعارات لتذكيرك بالذكريات المهمة المسجلة في تطبيق لحظة ذِكرى',
      importance: Importance.high,
      priority: Priority.high,
      color: roseGold,
      enableVibration: true,
      playSound: true,
    );

    await _plugin.zonedSchedule(
      id,
      '🌸 لحظة تستحق التذكّر',
      body,
      scheduled,
      const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }
}
