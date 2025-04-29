import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../Controllers/analysis_controller.dart';
import '../Controllers/savings_controller.dart';
import 'ai_service.dart';
import 'data_service.dart';
import 'notification_service.dart';
import '../Models/analysis_model.dart';

class AutomationService {
  static const int _weeklyAnalysisId = 0;

  static Future<void> init() async {
    try {
      debugPrint('AutomationService: Initializing AndroidAlarmManager');
      await AndroidAlarmManager.initialize();
      debugPrint(
          'AutomationService: AndroidAlarmManager initialized successfully');
    } catch (e, stackTrace) {
      debugPrint(
          'AutomationService: Error initializing AndroidAlarmManager: $e\n$stackTrace');
      rethrow;
    }
  }

  static Future<void> scheduleWeeklyAnalysis() async {
    try {
      debugPrint('AutomationService: Scheduling weekly analysis');
      await AndroidAlarmManager.periodic(
        const Duration(days: 7),
        _weeklyAnalysisId,
        _runAnalysis,
        startAt: DateTime.now().add(const Duration(minutes: 1)), // For testing
        exact: true,
        wakeup: true,
        rescheduleOnReboot: true,
      );
      debugPrint('AutomationService: Weekly analysis scheduled successfully');
    } catch (e, stackTrace) {
      debugPrint(
          'AutomationService: Error scheduling weekly analysis: $e\n$stackTrace');
      rethrow;
    }
  }

  static Future<void> _runAnalysis() async {
    try {
      debugPrint('AutomationService: Running analysis');
      await Firebase.initializeApp();
      debugPrint('AutomationService: Firebase initialized');
      await dotenv.load(fileName: '.env');
      debugPrint('AutomationService: .env loaded');
      final dataService = DataService();
      debugPrint('AutomationService: DataService created');
      SavingsController? savingsController;
      try {
        savingsController = SavingsController();
        debugPrint('AutomationService: SavingsController created');
      } catch (e, stackTrace) {
        debugPrint(
            'AutomationService: Error creating SavingsController: $e\n$stackTrace');
        savingsController = null;
      }
      final aiService = AiService();
      debugPrint('AutomationService: AiService created');
      final notificationService = NotificationService();
      await notificationService.init();
      debugPrint('AutomationService: NotificationService initialized');
      final analysisController = AnalysisController(
        AnalysisModel(),
        dataService,
        savingsController ?? SavingsController(), // Fallback
        aiService,
        notificationService,
      );
      debugPrint('AutomationService: AnalysisController created');
      await analysisController.generateBudgetTips();
      debugPrint('AutomationService: Analysis completed successfully');
    } catch (e, stackTrace) {
      debugPrint('AutomationService: Error in _runAnalysis: $e\n$stackTrace');
    }
  }
}
