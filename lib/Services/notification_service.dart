import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/foundation.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    debugPrint('NotificationService: Initialized');
  }

  Future<void> requestPermissions() async {
    if (Platform.isAndroid) {
      // Skip permission request on Android 12 or lower
      final androidPlugin = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (Platform.version.contains('13') || Platform.version.contains('14')) {
        final granted = await androidPlugin?.requestNotificationsPermission();
        debugPrint('NotificationService: Android permission granted: $granted');
        if (granted == null || !granted) {
          debugPrint(
              'NotificationService: Notification permission not granted');
        }
      } else {
        debugPrint(
            'NotificationService: Skipping permission request (Android 12 or lower)');
      }
    } else if (Platform.isIOS) {
      final granted = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);
      debugPrint('NotificationService: iOS permission granted: $granted');
    }
  }

  Future<void> showTestNotification(BuildContext context) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Channel for test notifications',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      'Test Notification',
      'This is a test notification from SBMA',
      platformChannelSpecifics,
      payload: 'test',
    );
    debugPrint('NotificationService: Test notification shown');
  }

  Future<void> showBudgetTips(BuildContext context, List<String> tips) async {
    try {
      for (int i = 0; i < tips.length; i++) {
        final scheduledTime =
            tz.TZDateTime.now(tz.local).add(Duration(seconds: i * 5));
        final androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'budget_tips_channel_$i',
          'Budget Tips',
          channelDescription: 'Channel for budget tips notifications',
          importance: Importance.max,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(tips[i]),
        );
        final platformChannelSpecifics = NotificationDetails(
          android: androidPlatformChannelSpecifics,
        );
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          i + 1,
          'Budget Tip',
          tips[i],
          scheduledTime,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        debugPrint('NotificationService: Scheduled budget tip $i: ${tips[i]}');
      }
    } catch (e, stackTrace) {
      debugPrint(
          'NotificationService: Error scheduling budget tips: $e\n$stackTrace');
    }
  }
}
