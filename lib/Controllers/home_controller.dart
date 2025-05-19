import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Models/transaction_model.dart';
import '../Services/data_service.dart';

class HomeController extends ChangeNotifier {
  final DataService _dataService;
  double _totalExpense = 0.0;
  double _revenueLastWeek = 0.0;
  String _topCategoryLastWeek = '';
  double _topCategoryAmountLastWeek = 0.0;
  String _topCategoryIconLastWeek = '';
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  int _selectedPeriodIndex = 2;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;
  String? _errorMessage;
  DateTime? _lastUpdate;

  HomeController(this._dataService) {
    _setupAuthListener();
  }

  double get totalBalance => _dataService.totalBalance;
  double get totalExpense => _totalExpense;
  double get revenueLastWeek => _revenueLastWeek;
  String get topCategoryLastWeek => _topCategoryLastWeek;
  double get topCategoryAmountLastWeek => _topCategoryAmountLastWeek;
  String get topCategoryIconLastWeek => _topCategoryIconLastWeek;
  int get selectedPeriodIndex => _selectedPeriodIndex;
  List<TransactionModel> get transactions => _filteredTransactions;
  String? get errorMessage => _errorMessage;

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        _setupListeners();
      }
    });
  }

  void _clearState() {
    _transactionSubscription?.cancel();
    _transactionSubscription = null;
    _totalExpense = 0.0;
    _revenueLastWeek = 0.0;
    _topCategoryLastWeek = '';
    _topCategoryAmountLastWeek = 0.0;
    _topCategoryIconLastWeek = '';
    _allTransactions = [];
    _filteredTransactions = [];
    _errorMessage = null;
    _lastUpdate = null;
    notifyListeners();
  }

  void _setupListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _clearState();
      return;
    }

    _transactionSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .listen((snapshot) {
      _errorMessage = null;      final newTransactions = <TransactionModel>[];
      for (var doc in snapshot.docs) {
        try {
          // Use the same fromFirestore method as TransactionController to ensure consistency
          final transaction = TransactionModel.fromFirestore(doc);
          newTransactions.add(transaction);
        } catch (e) {
          debugPrint('Error parsing transaction: $e');
        }
      }

      if (!_areTransactionsEqual(newTransactions, _allTransactions)) {
        _allTransactions = newTransactions;
        _calculateLastWeekMetrics();
        _calculateTotalExpense();
        _filterTransactions();
        _lastUpdate = DateTime.now();
        notifyListeners();
      }
    }, onError: (e) {
      _errorMessage = 'Failed to load transactions: $e';
      debugPrint('Error listening to transactions: $e');
      notifyListeners();
    });
  }

  bool _areTransactionsEqual(
      List<TransactionModel> a, List<TransactionModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].amount != b[i].amount) return false;
    }
    return true;
  }

  Future<void> _calculateTotalExpense() async {
    _totalExpense = _allTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (total, t) => total + t.amount.abs());
  }

  void _calculateLastWeekMetrics() {
    final now = DateTime.now();
    final lastWeekStart = now.subtract(const Duration(days: 7));
    final lastWeekTransactions = _allTransactions.where((transaction) {
      return transaction.date.isAfter(lastWeekStart) ||
          transaction.date.isAtSameMomentAs(lastWeekStart);
    }).toList();

    _revenueLastWeek = lastWeekTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (total, t) => total + t.amount);

    final categorySpending = <String, double>{};
    final categoryIcons = <String, String>{};

    for (var transaction in lastWeekTransactions) {
      if (transaction.type == 'expense') {
        final category = transaction.category;
        categorySpending[category] =
            (categorySpending[category] ?? 0) + transaction.amount.abs();
        categoryIcons[category] = transaction.icon;
      }
    }

    if (categorySpending.isNotEmpty) {
      final topEntry =
          categorySpending.entries.reduce((a, b) => a.value > b.value ? a : b);
      _topCategoryLastWeek = topEntry.key;
      _topCategoryAmountLastWeek = topEntry.value;
      _topCategoryIconLastWeek =
          categoryIcons[topEntry.key] ?? 'lib/assets/Salary.png';
    } else {
      _topCategoryLastWeek = 'None';
      _topCategoryAmountLastWeek = 0.0;
      _topCategoryIconLastWeek = 'lib/assets/Salary.png';
    }
  }

  void _filterTransactions() {
    final now = DateTime.now();
    DateTime startDate;
    switch (_selectedPeriodIndex) {
      case 0:
        startDate = now.subtract(const Duration(days: 1));
        break;
      case 1:
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 2:
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = now.subtract(const Duration(days: 1));
    }

    _filteredTransactions = _allTransactions.where((transaction) {
      return transaction.date.isAfter(startDate) ||
          transaction.date.isAtSameMomentAs(startDate);
    }).toList();
  }

  void onPeriodTapped(int index) {
    _selectedPeriodIndex = index;
    _filterTransactions();
    notifyListeners();
  }
  Future<void> setBalance(double balance) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'balance': balance}, SetOptions(merge: true));
    } catch (e) {
      _errorMessage = 'Error setting balance: $e';
      debugPrint('Error setting balance: $e');
      notifyListeners();
    }
  }
  
  // Method to force refresh data
  Future<void> refreshData() async {
    debugPrint('HomeController: Refreshing data...');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('HomeController: No user found for refresh');
      return;
    }

    try {
      // Fetch the latest user data
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (userDoc.exists) {
        // Force a notification to listeners
        notifyListeners();
      }
    } catch (e) {
      debugPrint('HomeController: Error refreshing data: $e');
    }
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
