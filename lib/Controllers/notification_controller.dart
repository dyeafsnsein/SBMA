import 'package:flutter/foundation.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import '../Models/notification_model.dart';
import '../Controllers/analysis_controller.dart';
import '../Controllers/category_controller.dart';
import '../Controllers/savings_controller.dart';
import '../Services/data_service.dart';
import '../Services/ai_service.dart';
import '../Services/notification_service.dart';
import '../Models/analysis_model.dart';

class NotificationController extends ChangeNotifier {
  final NotificationModel model;

  NotificationController(this.model) {
    _loadNotifications();
    debugPrint('NotificationController: Constructor called');
  }

  List<Map<String, dynamic>> get notifications => model.notifications;

  void addNotification(String icon, String title, String message, String time) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    model.saveNotification(id, icon, title, message, time);
    _saveNotifications();
    debugPrint('NotificationController: Added notification: $title - $message');
    notifyListeners();
  }

  void clearNotifications() {
    model.notifications.clear();
    _saveNotifications();
    debugPrint('NotificationController: Cleared notifications');
    notifyListeners();
  }

  void removeNotification(String id) {
    model.deleteNotification(id);
    _saveNotifications();
    debugPrint('NotificationController: Removed notification with id: $id');
    notifyListeners();
  }

  static Future<void> scheduleWeeklyAnalysis() async {
    await AndroidAlarmManager.initialize();
    const int analysisId = 0;
    final now = DateTime.now();
    final nextAnalysis =
        now.add(Duration(days: 7 - now.weekday)); // Next Monday
    await AndroidAlarmManager.periodic(
      const Duration(days: 7),
      analysisId,
      _runWeeklyAnalysis,
      startAt: nextAnalysis,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    debugPrint(
        'NotificationController: Scheduled weekly analysis at $nextAnalysis');
  }

  static Future<void> _runWeeklyAnalysis() async {
    debugPrint('NotificationController: Running weekly analysis');
    try {
      await Firebase.initializeApp();
      final notificationService = NotificationService();
      await notificationService.init();
      final dataService = DataService();
      final savingsController = SavingsController();
      final aiService = AiService();
      final categoryController = CategoryController();
      final notificationModel = NotificationModel();
      final notificationController = NotificationController(notificationModel);
      final analysisController = AnalysisController(
        AnalysisModel(),
        dataService,
        savingsController,
        aiService,
        notificationService,
        categoryController,
      );
      // Clear previous tips in SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('budget_tip_0');
      await prefs.remove('budget_tip_1');
      await prefs.remove('budget_tip_2');
      // Use timestamp to vary AI output
      final timestamp = DateTime.now().toIso8601String();
      final tips = await analysisController.generateBudgetTips(
        context: null,
        timestamp: timestamp,
      );
      debugPrint('NotificationController: Generated tips: $tips');
      if (tips.isNotEmpty && !tips.contains('No sufficient data')) {
        for (int i = 0; i < tips.length && i < 3; i++) {
          final title = 'AI Budget Tip ${i + 1}';
          final message = tips[i].replaceAll('\n', ' ');
          final time = DateTime.now().toIso8601String();
          notificationController.addNotification(
            'lib/assets/Notification.png',
            title,
            message,
            time,
          );
          final tipData = 'notifications|$title|$message';
          await prefs.setString('budget_tip_$i', tipData);
          debugPrint('NotificationController: Cached tip $i: $tipData');
        }
      } else {
        final title = 'AI Budget Tip Error';
        final message =
            'No budget tips generated. Please add more transactions.';
        final time = DateTime.now().toIso8601String();
        notificationController.addNotification(
          'lib/assets/Error.png',
          title,
          message,
          time,
        );
        final tipData = 'error|$title|$message';
        await prefs.setString('budget_tip_0', tipData);
        debugPrint('NotificationController: Cached empty tips error: $tipData');
      }
    } catch (e, stackTrace) {
      debugPrint(
          'NotificationController: Error running analysis: $e\n$stackTrace');
      final title = 'AI Budget Tip Error';
      final message = 'Failed to generate tips: $e';
      final time = DateTime.now().toIso8601String();
      final notificationModel = NotificationModel();
      final notificationController = NotificationController(notificationModel);
      notificationController.addNotification(
        'lib/assets/Error.png',
        title,
        message,
        time,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('budget_tip_0', 'error|$title|$message');
      debugPrint('NotificationController: Cached error: $e');
    }
  }

  void _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('notifications') ?? [];
    model.notifications.clear();
    for (var s in saved) {
      final parts = s.split('|');
      if (parts.length == 5) {
        model.saveNotification(
          parts[0], // id
          parts[1], // icon
          parts[2], // title
          parts[3], // message
          parts[4], // time
        );
      }
    }
    debugPrint('NotificationController: Loaded ${saved.length} notifications');
    notifyListeners();
  }

  void _saveNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final notificationList = model.notifications
        .map((n) =>
            '${n['id']}|${n['icon']}|${n['title']}|${n['message']}|${n['time']}')
        .toList();
    await prefs.setStringList('notifications', notificationList);
    debugPrint(
        'NotificationController: Saved ${notificationList.length} notifications');
  }
}
