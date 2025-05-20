import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/analysis_model.dart';
import '../Models/transaction_model.dart';
import '../Models/savings_goal.dart';
import '../Services/data_service.dart';
import '../Controllers/savings_controller.dart';

class AnalysisController extends ChangeNotifier {
  final AnalysisModel model;
  final DataService _dataService;
  final SavingsController _savingsController;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  List<TransactionModel> _transactions = [];
  StreamSubscription<QuerySnapshot>? _transactionSubscription;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, double> _categoryBreakdown = {};
  bool _isDataLoaded = false;
  AnalysisController(
    this.model,
    this._dataService,
    this._savingsController,
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
  bool get isDataLoaded => _isDataLoaded;
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

    // Cancel any existing subscriptions
    _transactionSubscription?.cancel();
    
    // Add listener to dataService
    _dataService.addListener(_onDataServiceChanged);
    
    // Initial data load
    _onDataServiceChanged();
    
    _savingsController.addListener(() {
      debugPrint('AnalysisController: SavingsController updated');
      notifyListeners();
    });
  }
  
  void _onDataServiceChanged() {
    debugPrint('AnalysisController: DataService changed, updating data');
    _transactions = List.from(_dataService.transactions);
    _categoryBreakdown = Map.from(_dataService.categoryBreakdown);
    totalExpense = _dataService.totalExpense;
    totalIncome = _dataService.totalIncome;
    
    _computePeriodData();
    _isLoading = false;
    _isDataLoaded = true;
    notifyListeners();
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
    debugPrint(
        'AnalysisController: Computed totalIncome=$totalIncome, totalExpense=$totalExpense');

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

  @override
  void dispose() {
    debugPrint('AnalysisController: Disposing');
    _dataService.removeListener(_onDataServiceChanged);
    _transactionSubscription?.cancel();
    _savingsController.removeListener(notifyListeners);
    super.dispose();
  }
}
