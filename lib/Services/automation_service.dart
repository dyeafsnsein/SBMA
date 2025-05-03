import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import '../Controllers/analysis_controller.dart';
import '../Models/analysis_model.dart';
import '../Services/data_service.dart';
import '../Services/ai_service.dart';
import '../Services/notification_service.dart';
import '../Controllers/savings_controller.dart';

class AutomationService {
  static Future<void> init() async {
    await AndroidAlarmManager.initialize();
    debugPrint('AutomationService: Initialized');
  }

  static Future<void> scheduleWeeklyAnalysis() async {
    const int analysisId = 0;
    final now = DateTime.now();
    final nextAnalysis =
        now.add(Duration(days: 7 - now.weekday)); // Next Monday
    await AndroidAlarmManager.periodic(
      const Duration(days: 7),
      analysisId,
      _runAnalysis,
      startAt: nextAnalysis,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: true,
    );
    debugPrint('AutomationService: Scheduled weekly analysis at $nextAnalysis');
  }

  static Future<void> _runAnalysis() async {
    debugPrint('AutomationService: Running weekly analysis');
    try {
      await Firebase.initializeApp();
      final notificationService = NotificationService();
      await notificationService.init();
      final analysisController = AnalysisController(
        AnalysisModel(),
        DataService(),
        SavingsController(),
        AiService(),
        notificationService,
      );
      final tips = await analysisController.generateBudgetTips();
      debugPrint('AutomationService: Generated tips: $tips');
    } catch (e, stackTrace) {
      debugPrint('AutomationService: Error running analysis: $e\n$stackTrace');
    }
  }
}
