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
import 'package:intl/intl.dart';

class NotificationController extends ChangeNotifier {
  final NotificationModel model;

  NotificationController(this.model) {
    _loadNotifications();
    debugPrint('NotificationController: Constructor called');
  }

  List<Map<String, dynamic>> get notifications => model.notifications;

  void addNotification(String icon, String title, String message, String time) {
    // Check for duplicates
    final exists = model.notifications
        .any((n) => n['title'] == title && n['message'] == message);
    if (exists) {
      debugPrint(
          'NotificationController: Skipped duplicate notification: $title - $message');
      return;
    }
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

  void removeNotification(String id) async {
    model.deleteNotification(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('budget_tip_0');
    await prefs.remove('deleted_tip');
    _saveNotifications();
    debugPrint(
        'NotificationController: Removed notification with id: $id and cleared cached tip');
    notifyListeners();
  }

  static Future<void> scheduleWeeklyAnalysis() async {
    const int analysisId = 0;
    const String alarmScheduledKey = 'weekly_analysis_scheduled';
    final prefs = await SharedPreferences.getInstance();
    final isScheduled = prefs.getBool(alarmScheduledKey) ?? false;

    if (isScheduled) {
      debugPrint('NotificationController: Weekly analysis already scheduled');
      return;
    }

    await AndroidAlarmManager.initialize();
    // Cancel any existing alarm to prevent duplicates
    await AndroidAlarmManager.cancel(analysisId);
    debugPrint(
        'NotificationController: Canceled any existing alarm with ID $analysisId');

    final now = DateTime.now();
    final nextAnalysis =
        now.add(Duration(days: 7 - now.weekday)); // Next Monday
    final startAt =
        DateTime(nextAnalysis.year, nextAnalysis.month, nextAnalysis.day, 0, 0);

    final scheduled = await AndroidAlarmManager.periodic(
      const Duration(days: 7),
      analysisId,
      _runWeeklyAnalysis,
      startAt: startAt,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );

    if (scheduled) {
      await prefs.setBool(alarmScheduledKey, true);
      debugPrint(
          'NotificationController: Scheduled weekly analysis at $startAt');
    } else {
      debugPrint('NotificationController: Failed to schedule weekly analysis');
    }
  }

  static Future<void> _runWeeklyAnalysis() async {
    debugPrint(
        'NotificationController: Attempting weekly analysis at ${DateTime.now()}');
    final prefs = await SharedPreferences.getInstance();
    final lastRun = prefs.getString('last_analysis_run');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastRun == today) {
      debugPrint(
          'NotificationController: Weekly analysis already ran today, skipping');
      return;
    }

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
      await prefs.remove('budget_tip_0');
      await prefs.remove('budget_tip_1');
      await prefs.remove('budget_tip_2');
      // Clear existing notifications
      notificationController.clearNotifications();
      // Use simplified date format
      final timestamp = DateFormat('d MMMM').format(DateTime.now());
      final tips = await analysisController.generateBudgetTips(
        context: null,
        timestamp: timestamp,
      );
      debugPrint('NotificationController: Generated tip: $tips');
      if (tips.isNotEmpty && !tips.contains('No sufficient data')) {
        final title = 'AI Budget Tip';
        final message = tips[0].replaceAll('\n', ' ');
        notificationController.addNotification(
          'lib/assets/Notification.png',
          title,
          message,
          timestamp,
        );
        final tipData = 'lib/assets/Notification.png|$title|$message';
        await prefs.setString('budget_tip_0', tipData);
        debugPrint('NotificationController: Cached tip: $tipData');
      } else {
        final title = 'AI Budget Tip';
        final message =
            'No budget tip generated. Please add more transactions.';
        notificationController.addNotification(
          'lib/assets/Error.png',
          title,
          message,
          timestamp,
        );
        final tipData = 'lib/assets/Error.png|$title|$message';
        await prefs.setString('budget_tip_0', tipData);
        debugPrint('NotificationController: Cached empty tip error: $tipData');
      }
      // Update last run date
      await prefs.setString('last_analysis_run', today);
      debugPrint('NotificationController: Updated last analysis run to $today');
    } catch (e, stackTrace) {
      debugPrint(
          'NotificationController: Error running analysis: $e\n$stackTrace');
      final title = 'AI Budget Tip';
      final message = 'Failed to generate tip: $e';
      final timestamp = DateFormat('d MMMM').format(DateTime.now());
      final notificationModel = NotificationModel();
      final notificationController = NotificationController(notificationModel);
      notificationController.addNotification(
        'lib/assets/Error.png',
        title,
        message,
        timestamp,
      );
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'budget_tip_0', 'lib/assets/Error.png|$title|$message');
      debugPrint('NotificationController: Cached error: $e');
    }
  }

  void _loadNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList('notifications') ?? [];
    final deletedTip = prefs.getString('deleted_tip');
    model.notifications.clear();
    for (var s in saved) {
      final parts = s.split('|');
      if (parts.length == 5) {
        // Check for duplicates and deleted tips
        final tipData = '${parts[1]}|${parts[2]}|${parts[3]}';
        final exists = model.notifications
            .any((n) => n['title'] == parts[2] && n['message'] == parts[3]);
        if (!exists && (deletedTip == null || tipData != deletedTip)) {
          model.saveNotification(
            parts[0], // id
            parts[1], // icon
            parts[2], // title
            parts[3], // message
            parts[4], // time
          );
        }
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
