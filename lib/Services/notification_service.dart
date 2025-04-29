import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showBudgetTips(List<String> tips) async {
    const androidDetails = AndroidNotificationDetails(
      'budget_tips_channel',
      'Budget Tips',
      channelDescription: 'Notifications for weekly budgeting tips',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    for (int i = 0; i < tips.length; i++) {
      await _notificationsPlugin.show(
        i,
        'Smart Budget Tip #${i + 1}',
        tips[i],
        notificationDetails,
      );
    }
  }
}
