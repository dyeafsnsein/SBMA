import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../Models/analysis_model.dart';
import '../Models/transaction_model.dart';
import '../Models/savings_goal.dart';
import '../Services/data_service.dart';
import '../Services/ai_service.dart';
import '../Services/notification_service.dart';
import '../Controllers/savings_controller.dart';
import '../Controllers/category_controller.dart';
import 'package:intl/intl.dart';

class AnalysisController extends ChangeNotifier {
  final AnalysisModel model;
  final DataService _dataService;
  final SavingsController _savingsController;
  final AiService _aiService;
  final NotificationService _notificationService;
  final CategoryController _categoryController;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  List<TransactionModel> _transactions = [];
  StreamSubscription<QuerySnapshot>? _transactionSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, double> _categoryBreakdown = {};
  bool _isAnalyzingTips = false;
  String? _tipErrorMessage;
  bool _isDataLoaded = false;

  AnalysisController(
    this.model,
    this._dataService,
    this._savingsController,
    this._aiService,
    this._notificationService,
    this._categoryController,
  ) {
    debugPrint('AnalysisController: Constructor called');
    _setupAuthListener();
  }

  List<String> get periods => model.periods;
  int get selectedPeriodIndex => model.selectedPeriodIndex;
  Map<String, Map<String, dynamic>> get periodData => model.periodData;
  List<SavingsGoal> get savingsGoals => _savingsController.savingsGoals;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, double> get categoryBreakdown => _categoryBreakdown;
  bool get isAnalyzingTips => _isAnalyzingTips;
  String? get tipErrorMessage => _tipErrorMessage;
  double get totalBalance => _dataService.totalBalance;

  void _setupAuthListener() {
    debugPrint('AnalysisController: Setting up auth listener');
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('AnalysisController: No user, clearing state');
        _clearState();
      } else {
        debugPrint('AnalysisController: User logged in: ${user.uid}');
        _setupListeners(user.uid);
      }
    });
  }

  void _clearState() {
    debugPrint('AnalysisController: Clearing state');
    _transactionSubscription?.cancel();
    _transactionSubscription = null;
    _transactions = [];
    totalIncome = 0.0;
    totalExpense = 0.0;
    _categoryBreakdown = {};
    _isLoading = false;
    _errorMessage = null;
    _isAnalyzingTips = false;
    _tipErrorMessage = null;
    _isDataLoaded = false;
    _computePeriodData();
    notifyListeners();
  }

  void _setupListeners(String userId) {
    debugPrint('AnalysisController: Setting up listeners for user: $userId');
    _isLoading = true;
    _errorMessage = null;
    _isDataLoaded = false;
    notifyListeners();

    _transactionSubscription?.cancel();
    _transactionSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      debugPrint(
          'AnalysisController: Received transaction snapshot: ${snapshot.docs.length} docs');
      _transactions = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final categoryRaw = data['category'];
        final category = categoryRaw is String ? categoryRaw : 'Unknown';
        final categoryId = data['categoryId'] as String? ?? 'unknown';
        final icon = data['icon'] is String
            ? data['icon'] as String
            : await _categoryController.getIconForCategory(category);
        _transactions.add(TransactionModel(
          id: doc.id,
          type: data['type'] ?? 'expense',
          amount: double.parse(data['amount'].toString()),
          date: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          description: data['description'] ?? '',
          category: category,
          categoryId: categoryId,
          icon: icon,
        ));
      }

      _computePeriodData();
      _computeCategoryBreakdown();
      _isLoading = false;
      _isDataLoaded = true;
      debugPrint(
          'AnalysisController: Data loaded, transactions: ${_transactions.length}');
      notifyListeners();
    }, onError: (e, stackTrace) {
      _errorMessage = 'Failed to load transactions: $e';
      _isLoading = false;
      _isDataLoaded = false;
      debugPrint(
          'AnalysisController: Error listening to transactions: $e\n$stackTrace');
      notifyListeners();
    });

    _savingsController.addListener(() {
      debugPrint('AnalysisController: SavingsController updated');
      notifyListeners();
    });
  }

  void _computeCategoryBreakdown() {
    debugPrint('AnalysisController: Computing category breakdown');
    _categoryBreakdown.clear();
    for (var transaction in _transactions) {
      if (transaction.type == 'expense') {
        final category = transaction.category;
        _categoryBreakdown[category] =
            (_categoryBreakdown[category] ?? 0.0) + transaction.amount.abs();
      }
    }
    debugPrint('AnalysisController: Category breakdown: $_categoryBreakdown');
  }

  void onPeriodChanged(int index) {
    if (model.selectedPeriodIndex == index) return;
    debugPrint('AnalysisController: Period changed to index: $index');
    model.selectedPeriodIndex = index;
    _computePeriodData();
    notifyListeners();
  }

  void _computePeriodData() {
    debugPrint('AnalysisController: Computing period data');
    final now = DateTime.now();

    model.periodData = {
      'Daily': {
        'expenses': <double>[],
        'income': <double>[],
        'labels': <String>[]
      },
      'Weekly': {
        'expenses': <double>[],
        'income': <double>[],
        'labels': <String>[]
      },
      'Monthly': {
        'expenses': <double>[],
        'income': <double>[],
        'labels': <String>[]
      },
      'Year': {
        'expenses': <double>[],
        'income': <double>[],
        'labels': <String>[]
      },
    };

    totalIncome = _transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (total, t) => total + t.amount);
    totalExpense = _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (total, t) => total + t.amount.abs());

    // Daily: Last 7 days (oldest to newest)
    if (selectedPeriodIndex == 0) {
      List<double> expenses = List.filled(7, 0.0);
      List<double> income = List.filled(7, 0.0);
      List<String> labels = [];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        labels.add(_getDayLabel(date));
        for (final transaction in _transactions) {
          if (_isSameDay(transaction.date, date)) {
            if (transaction.type == 'expense') {
              expenses[6 - i] += transaction.amount.abs();
            } else if (transaction.type == 'income') {
              income[6 - i] += transaction.amount;
            }
          }
        }
      }
      model.periodData['Daily']!['expenses'] = expenses.reversed.toList();
      model.periodData['Daily']!['income'] = income.reversed.toList();
      model.periodData['Daily']!['labels'] = labels.reversed.toList();
    }

    // Weekly: Last 4 weeks (oldest to newest)
    else if (selectedPeriodIndex == 1) {
      List<double> expenses = List.filled(4, 0.0);
      List<double> income = List.filled(4, 0.0);
      List<String> labels = [];
      final today = now;
      final daysSinceMonday = today.weekday - 1;
      final startOfCurrentWeek =
          today.subtract(Duration(days: daysSinceMonday));
      for (int i = 3; i >= 0; i--) {
        final startOfWeek = startOfCurrentWeek.subtract(Duration(days: i * 7));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        final label = "${_getMonthLabel(startOfWeek.month)} ${startOfWeek.day}";
        labels.add(label);
        for (final transaction in _transactions) {
          if (transaction.date.isAfter(startOfWeek) &&
              (transaction.date.isBefore(endOfWeek) ||
                  transaction.date.isAtSameMomentAs(endOfWeek))) {
            if (transaction.type == 'expense') {
              expenses[3 - i] += transaction.amount.abs();
            } else if (transaction.type == 'income') {
              income[3 - i] += transaction.amount;
            }
          }
        }
      }
      model.periodData['Weekly']!['expenses'] = expenses;
      model.periodData['Weekly']!['income'] = income;
      model.periodData['Weekly']!['labels'] = labels;
    }

    // Monthly: Last 12 months (oldest to newest)
    else if (selectedPeriodIndex == 2) {
      List<double> expenses = List.filled(12, 0.0);
      List<double> income = List.filled(12, 0.0);
      List<String> labels = [];
      for (int i = 11; i >= 0; i--) {
        final monthsAgo = now.month - i;
        final year = now.year + (monthsAgo ~/ 12);
        final month = monthsAgo % 12 == 0 ? 12 : monthsAgo % 12;
        final adjustedYear = monthsAgo < 0 ? year - 1 : year;
        final monthStart = DateTime(adjustedYear, month, 1);
        final monthEnd = DateTime(adjustedYear, month + 1, 1)
            .subtract(const Duration(days: 1));
        final label = _getMonthLabel(month);
        labels.add(label);
        for (final transaction in _transactions) {
          if (transaction.date.isAfter(monthStart) &&
              (transaction.date.isBefore(monthEnd) ||
                  transaction.date.isAtSameMomentAs(monthEnd))) {
            if (transaction.type == 'expense') {
              expenses[11 - i] += transaction.amount.abs();
            } else if (transaction.type == 'income') {
              income[11 - i] += transaction.amount;
            }
          }
        }
      }
      model.periodData['Monthly']!['expenses'] = expenses;
      model.periodData['Monthly']!['income'] = income;
      model.periodData['Monthly']!['labels'] = labels;
    }

    // Yearly: Last 4 years (oldest to newest)
    else if (selectedPeriodIndex == 3) {
      List<double> expenses = List.filled(4, 0.0);
      List<double> income = List.filled(4, 0.0);
      List<String> labels = [];
      for (int i = 3; i >= 0; i--) {
        final year = now.year - i;
        labels.add(year.toString());
        final yearStart = DateTime(year, 1, 1);
        final yearEnd = DateTime(year, 12, 31);
        for (final transaction in _transactions) {
          if (transaction.date.isAfter(yearStart) &&
              (transaction.date.isBefore(yearEnd) ||
                  transaction.date.isAtSameMomentAs(yearEnd))) {
            if (transaction.type == 'expense') {
              expenses[3 - i] += transaction.amount.abs();
            } else if (transaction.type == 'income') {
              income[3 - i] += transaction.amount;
            }
          }
        }
      }
      model.periodData['Year']!['expenses'] = expenses;
      model.periodData['Year']!['income'] = income;
      model.periodData['Year']!['labels'] = labels;
    }
    debugPrint('AnalysisController: Period data computed: ${model.periodData}');
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _getMonthLabel(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  Future<void> retryLoading() async {
    debugPrint('AnalysisController: Retrying data load');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('AnalysisController: No user for retry');
      return;
    }
    _clearState();
    _setupListeners(user.uid);
  }

  Future<List<String>> generateBudgetTips({
    BuildContext? context,
    String? timestamp,
  }) async {
    debugPrint('AnalysisController: Starting generateBudgetTips');
    debugPrint(
        'AnalysisController: Input data: income=$totalIncome, expenses=$totalExpense, categories=$_categoryBreakdown, timestamp=$timestamp');
    if (_isAnalyzingTips) {
      debugPrint(
          'AnalysisController: Budget tip generation already in progress');
      return [];
    }
    _isAnalyzingTips = true;
    _tipErrorMessage = null;
    notifyListeners();

    try {
      if (!_isDataLoaded) {
        debugPrint('AnalysisController: Data not loaded, waiting for load');
        await Future.delayed(const Duration(seconds: 1));
        if (!_isDataLoaded) {
          throw Exception('Data not loaded');
        }
      }
      if (totalIncome <= 0 || totalExpense <= 0 || _categoryBreakdown.isEmpty) {
        debugPrint('AnalysisController: Invalid input data for AI');
        final tips = [
          'No sufficient data to generate tip.',
          'Add more transactions to get personalized advice.',
        ];
        if (context != null) {
          await _notificationService.showBudgetTips(context, tips);
        }
        return tips;
      }
      final tips = await _aiService.generateBudgetTips(
        income: totalIncome,
        expenses: totalExpense,
        categories: _categoryBreakdown,
        timestamp: timestamp ?? DateFormat('d MMMM').format(DateTime.now()),
      );
      debugPrint('AnalysisController: Generated tip: $tips');
      if (tips.isEmpty) {
        debugPrint('AnalysisController: AI returned empty tip');
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
          'AnalysisController: Error generating budget tip: $e\n$stackTrace');
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
      debugPrint('AnalysisController: Budget tip generation completed');
    }
  }

  @override
  void dispose() {
    debugPrint('AnalysisController: Disposing');
    _transactionSubscription?.cancel();
    _savingsController.removeListener(notifyListeners);
    super.dispose();
  }
}
