import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../Models/notification_model.dart';
import '../Models/transaction_model.dart';
import '../Services/data_service.dart';
import '../Services/ai_service.dart';
import '../Services/notification_service.dart';

/// A controller that handles notifications in the SBMA app.
/// This controller is focused on managing notifications for the user and
/// generating budget tips based on transaction data.
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
    _initialize();
  }

  /// Initialize controller by loading notifications and setting up listeners
  void _initialize() async {
    await _notificationService.loadNotifications(model);
    _setupAuthListener();
    _setupTransactionReminders();
  }

  // Public getters
  List<Map<String, dynamic>> get notifications => model.notifications;
  bool get isAnalyzingTips => _isAnalyzingTips;
  String? get tipErrorMessage => _tipErrorMessage;
  List<TransactionModel> get transactions => _transactions;

  /// Setup transaction reminders that will always be enabled
  Future<void> _setupTransactionReminders() async {
    try {
      // Schedule reminders every 8 hours
      await _notificationService.scheduleRepeatingReminder(
        hours: 8,
        title: 'Transaction Reminder',
        body: 'Remember to record your recent transactions',
      );
    } catch (e) {
      debugPrint('Error setting up transaction reminders: $e');
    }
  }

  /// Method to test notifications on the physical device
  Future<void> showDebugNotification() async {
    try {
      await _notificationService.showImmediateDebugNotification();
    } catch (e) {
      debugPrint('Error showing debug notification: $e');
      rethrow;
    }
  }

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

    _transactionSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error listening to transactions: $e');
    });
  }

  /// Add a new notification
  Future<void> addNotification(
      String icon, String title, String message, String time) async {
    try {
      // Check for duplicates in local list first
      final exists = model.notifications
          .any((n) => n['title'] == title && n['message'] == message);

      if (exists) return;

      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final notification =
          model.createNotificationObject(id, icon, title, message, time);

      // Add to local model
      model.addNotification(notification);

      // Save to service (handles persistence)
      await _notificationService.saveNotification(notification);

      notifyListeners();
    } catch (e) {
      debugPrint('Error adding notification: $e');
    }
  }

  /// Remove a notification by ID
  Future<void> removeNotification(String id) async {
    try {
      // Remove from local model
      model.removeNotification(id);

      // Remove via service
      await _notificationService.removeNotification(id);

      notifyListeners();
    } catch (e) {
      debugPrint('Error removing notification: $e');
    }
  }

  /// Clear all notifications
  Future<void> clearNotifications() async {
    try {
      // Clear local model
      model.clearNotifications();

      // Clear via service
      await _notificationService.clearAllNotifications();

      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  /// Mark a notification as deleted
  Future<void> markTipAsDeleted(Map<String, dynamic> notification) async {
    try {
      await _notificationService.markTipAsDeleted(notification);
      removeNotification(notification['id']);
    } catch (e) {
      debugPrint('Error marking tip as deleted: $e');
    }
  }

  /// Generate AI budget tips and return them
  Future<List<String>> generateBudgetTips({
    BuildContext? context,
    String? timestamp,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      const errorTips = ['You need to be logged in to generate budget tips.'];
      if (context != null) {
        await _notificationService.showBudgetTips(context, errorTips);
      }
      return errorTips;
    }

    // Ensure we have the latest data from our real-time listeners
    if (_transactions.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500));
    }

    final balance = _dataService.totalBalance;
    final expenses = _calculateTotalExpenses();
    final categories = _calculateCategoryBreakdown();
    final BuildContext? safeContext = context;
    if (_isAnalyzingTips) return [];
    _isAnalyzingTips = true;
    _tipErrorMessage = null;
    notifyListeners();
    try {
      if (_transactions.isEmpty || (expenses <= 0 && categories.isEmpty)) {
        const tips = [
          'No spending data to generate a tip.',
          'Add expense transactions to get personalized advice.',
        ];
        if (safeContext != null) {
          await _notificationService.showBudgetTips(safeContext, tips);
        }
        return tips;
      }
      final tips = await _aiService.generateBudgetTips(
        income: balance,
        expenses: expenses,
        categories: categories,
        timestamp: timestamp ?? DateFormat('d MMMM').format(DateTime.now()),
      );
      if (tips.isEmpty) {
        const fallbackTips = [
          'No specific tip generated.',
          'Review your spending patterns for savings opportunities.',
        ];
        if (safeContext != null) {
          await _notificationService.showBudgetTips(safeContext, fallbackTips);
        }
        return fallbackTips;
      }
      if (safeContext != null) {
        await _notificationService.showBudgetTips(safeContext, tips);
      }
      return tips;
    } catch (e) {
      String errorMessage = 'Failed to generate tip: $e';
      if (e.toString().contains('NotInitializedError')) {
        errorMessage = 'AI service not initialized. Please try again later.';
      }
      final errorTips = [errorMessage];
      if (safeContext != null) {
        await _notificationService.showBudgetTips(safeContext, errorTips);
      }
      _tipErrorMessage = errorMessage;
      return errorTips;
    } finally {
      _isAnalyzingTips = false;
      notifyListeners();
    }
  }

  /// Generate and add a budget tip to the notifications list
  /// Returns true if successful, false otherwise
  Future<bool> generateAndAddBudgetTip(BuildContext? context) async {
    final timestamp = DateFormat('d MMMM').format(DateTime.now());

    try {
      // Clear cached tips
      await _notificationService.clearCachedTips();
      clearNotifications();

      // Generate tips
      final generatedTips = await generateBudgetTips(
        context: context,
        timestamp: timestamp,
      );

      if (generatedTips.isNotEmpty &&
          !generatedTips.contains('No spending data')) {
        final title = 'AI Budget Tip';
        final message = generatedTips[0].replaceAll('\n', ' ');

        // Check if this tip already exists in the notifications
        final exists = notifications
            .any((n) => n['title'] == title && n['message'] == message);

        if (!exists) {
          // Add to notifications list in the model/database
          addNotification(
            'lib/assets/Notification.png',
            title,
            message,
            timestamp,
          );

          // Cache the tip
          await _notificationService.cacheTip(title, message);

          return true;
        } else {
          return false;
        }
      } else {
        addNotification(
          'lib/assets/Error.png',
          'AI Budget Tip',
          'No budget tip generated. Please add more transactions.',
          timestamp,
        );
        return false;
      }
    } catch (e) {
      String errorMessage = 'Failed to generate tip: $e';
      if (e.toString().contains('NotInitializedError')) {
        errorMessage = 'AI service not initialized. Please try again later.';
      }
      addNotification(
        'lib/assets/Error.png',
        'AI Budget Tip',
        errorMessage,
        timestamp,
      );
      return false;
    }
  }

  // Helper methods for budget tips
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
        breakdown[category] =
            (breakdown[category] ?? 0.0) + transaction.amount.abs();
      }
    }
    return breakdown;
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
