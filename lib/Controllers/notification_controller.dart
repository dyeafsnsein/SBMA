import 'package:flutter/foundation.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Models/notification_model.dart';
import '../Models/transaction_model.dart';
import '../Services/data_service.dart';
import '../Services/ai_service.dart';
import '../Services/notification_service.dart';
import 'package:intl/intl.dart';

class NotificationController extends ChangeNotifier {
  final NotificationModel model;
  final DataService _dataService;
  final NotificationService _notificationService;
  final AiService _aiService;
  bool _isAnalyzingTips = false;
  String? _tipErrorMessage;
  List<TransactionModel> _transactions = [];
  StreamSubscription<QuerySnapshot>? _transactionSubscription;

  NotificationController(
    this.model,
    this._dataService,
    this._notificationService,
    this._aiService,
  ) {
    _loadNotifications();
    _setupAuthListener();
    debugPrint('NotificationController: Constructor called');
  }

  List<Map<String, dynamic>> get notifications => model.notifications;
  bool get isAnalyzingTips => _isAnalyzingTips;
  String? get tipErrorMessage => _tipErrorMessage;
  List<TransactionModel> get transactions => _transactions;

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        _setupListeners(user.uid);
      }
    });
  }

  void _clearState() {
    _transactionSubscription?.cancel();
    _transactionSubscription = null;
    _transactions = [];
    notifyListeners();
  }

  void _setupListeners(String userId) {
    _transactionSubscription?.cancel(); // Prevent duplicate listeners
    
    debugPrint('NotificationController: Setting up transaction listener for user: $userId');
    
    _transactionSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
          debugPrint('NotificationController: Received ${snapshot.docs.length} transactions from Firestore');
          _transactions = snapshot.docs
              .map((doc) => TransactionModel.fromFirestore(doc))
              .toList();
          notifyListeners();
        }, onError: (e) {
          debugPrint('NotificationController: Error listening to transactions: $e');
        });
  }

  void addNotification(String icon, String title, String message, String time) {
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
  double _calculateTotalExpenses() {
    return _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (total, t) => total + t.amount.abs());
  }

  Map<String, double> _calculateCategoryBreakdown() {
    Map<String, double> breakdown = {};
    for (var transaction in _transactions) {
      if (transaction.type == 'expense') {
        final category = transaction.category;
        breakdown[category] = (breakdown[category] ?? 0.0) + transaction.amount.abs();
      }
    }
    return breakdown;
  }
  
  Future<List<String>> generateBudgetTips({
    BuildContext? context,
    String? timestamp,
  }) async {
    debugPrint('NotificationController: Starting generateBudgetTips');
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      debugPrint('NotificationController: No user logged in');
      final errorTips = ['You need to be logged in to generate budget tips.'];
      if (context != null) {
        await _notificationService.showBudgetTips(context, errorTips);
      }
      return errorTips;
    }

    // Ensure we have the latest data from our real-time listeners
    if (_transactions.isEmpty) {
      debugPrint('NotificationController: No transactions available, waiting briefly');
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final balance = _dataService.totalBalance;
    final expenses = _calculateTotalExpenses();
    final categories = _calculateCategoryBreakdown();
    
    debugPrint(
        'NotificationController: Input data: balance=$balance, expenses=$expenses, categories=$categories, transactions=${_transactions.length}, timestamp=$timestamp');
    
    if (_isAnalyzingTips) {
      debugPrint('NotificationController: Budget tip generation already in progress');
      return [];
    }
    
    _isAnalyzingTips = true;
    _tipErrorMessage = null;
    notifyListeners();

    try {
      if (_transactions.isEmpty) {
        debugPrint('NotificationController: No transactions available for AI analysis');
        final tips = [
          'No spending data to generate a tip.',
          'Add expense transactions to get personalized advice.',
        ];
        if (context != null) {
          await _notificationService.showBudgetTips(context, tips);
        }
        return tips;
      }
      
      if (expenses <= 0 && categories.isEmpty) {
        debugPrint('NotificationController: No spending data for AI');
        final tips = [
          'No spending data to generate a tip.',
          'Add expense transactions to get personalized advice.',
        ];
        if (context != null) {
          await _notificationService.showBudgetTips(context, tips);
        }
        return tips;
      }
      final tips = await _aiService.generateBudgetTips(
        income: balance,
        expenses: expenses,
        categories: categories,
        timestamp: timestamp ?? DateFormat('d MMMM').format(DateTime.now()),
      );
      debugPrint('NotificationController: Generated tips: $tips');
      if (tips.isEmpty) {
        debugPrint('NotificationController: AI returned empty tip');
        final fallbackTips = [
          'No specific tip generated.',
          'Review your spending patterns for savings opportunities.',
        ];
        if (context != null) {
          await _notificationService.showBudgetTips(context, fallbackTips);
        }
        return fallbackTips;
      }
      if (context != null) {
        await _notificationService.showBudgetTips(context, tips);
      }
      return tips;
    } catch (e, stackTrace) {
      debugPrint(
          'NotificationController: Error generating budget tip: $e\n$stackTrace');
      String errorMessage = 'Failed to generate tip: $e';
      if (e.toString().contains('NotInitializedError')) {
        errorMessage = 'AI service not initialized. Please try again later.';
      }
      final errorTips = [errorMessage];
      if (context != null) {
        await _notificationService.showBudgetTips(context, errorTips);
      }
      _tipErrorMessage = errorMessage;
      return errorTips;
    } finally {
      _isAnalyzingTips = false;
      notifyListeners();
      debugPrint('NotificationController: Budget tip generation completed');
    }
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
    debugPrint('NotificationController: Attempting weekly analysis at ${DateTime.now()}');
    final prefs = await SharedPreferences.getInstance();
    final lastRun = prefs.getString('last_analysis_run');
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

    if (lastRun == today) {
      debugPrint('NotificationController: Weekly analysis already ran today, skipping');
      return;
    }

    try {
      await Firebase.initializeApp();
      final notificationService = NotificationService();
      await notificationService.init();
      final dataService = DataService();
      final aiService = AiService();
      final notificationModel = NotificationModel();
      
      // Create controller
      final notificationController = NotificationController(
        notificationModel,
        dataService,
        notificationService,
        aiService,
      );
      
      // Clear old cached tips
      await prefs.remove('budget_tip_0');
      await prefs.remove('budget_tip_1');
      await prefs.remove('budget_tip_2');
      notificationController.clearNotifications();
      
      // Wait a moment for the real-time listeners to fetch data
      await Future.delayed(const Duration(seconds: 2));
      
      final timestamp = DateFormat('d MMMM').format(DateTime.now());
      final tips = await notificationController.generateBudgetTips(
        context: null,
        timestamp: timestamp,
      );
      
      debugPrint('NotificationController: Generated tip: $tips');
      if (tips.isNotEmpty && !tips.contains('No spending data')) {
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
        final message = 'No budget tip generated. Please add more transactions.';
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
      
      // Clean up resources
      notificationController.dispose();
      
      await prefs.setString('last_analysis_run', today);
      debugPrint('NotificationController: Updated last analysis run to $today');
    } catch (e, stackTrace) {
      debugPrint('NotificationController: Error running analysis: $e\n$stackTrace');
      final title = 'AI Budget Tip';
      final message = 'Failed to generate tip: $e';
      final timestamp = DateFormat('d MMMM').format(DateTime.now());
      final notificationModel = NotificationModel();
      final notificationController = NotificationController(
        notificationModel,
        DataService(),
        NotificationService(),
        AiService(),
      );
      notificationController.addNotification(
        'lib/assets/Error.png',
        title,
        message,
        timestamp,
      );
      await prefs.setString('budget_tip_0', 'lib/assets/Error.png|$title|$message');
      debugPrint('NotificationController: Cached error: $e');
      
      // Clean up resources
      notificationController.dispose();
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
  
  @override
  void dispose() {
    _transactionSubscription?.cancel();
    debugPrint('NotificationController: Disposed and canceled subscription');
    super.dispose();
  }
}
