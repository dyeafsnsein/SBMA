import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/home_model.dart';
import '../services/auth_service.dart';

class HomeController extends ChangeNotifier {
  final HomeModel model;
  final AuthService _authService = AuthService();

  double _totalBalance = 0.0;
  double _totalExpense = 0.0;
  double _revenueLastWeek = 0.0;
  double _foodLastWeek = 0.0;
  List<Map<String, dynamic>> _allTransactions = [];
  List<Map<String, dynamic>> _filteredTransactions = [];

  HomeController(this.model) {
    _fetchUserData();
  }

  double get totalBalance => _totalBalance;
  double get totalExpense => _totalExpense;
  double get revenueLastWeek => _revenueLastWeek;
  double get foodLastWeek => _foodLastWeek;
  int get selectedPeriodIndex => model.selectedPeriodIndex;
  List<String> get periods => model.periods;
  List<Map<String, dynamic>> get transactions => _filteredTransactions;

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        // Fetch user data (balance)
        final userData = await _authService.getUserData(user.uid);
        if (userData != null) {
          _totalBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;
        }

        // Fetch transactions from Firestore
        final transactionsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .orderBy('timestamp', descending: true)
            .get();

        _allTransactions = transactionsSnapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'icon': data['icon'] ?? 'lib/assets/Transaction.png',
            'time': data['time'] ?? '',
            'category': data['category'] ?? '',
            'amount': data['amount'].toString(),
            'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
          };
        }).toList();

        // Calculate revenue and food expenses for the last week
        _calculateLastWeekMetrics();

        // Initial filter based on the default period (Monthly)
        _filterTransactions();
        notifyListeners();
      } catch (e) {
        // Error handling (previously commented out print statement)
      }
    }
  }

  void _calculateLastWeekMetrics() {
    final now = DateTime.now();
    final lastWeekStart = now.subtract(const Duration(days: 7));
    final lastWeekTransactions = _allTransactions.where((transaction) {
      final transactionDate = transaction['timestamp'] as DateTime?;
      if (transactionDate == null) return false;
      return transactionDate.isAfter(lastWeekStart) || transactionDate.isAtSameMomentAs(lastWeekStart);
    }).toList();

    // Calculate revenue (income) for the last week
    _revenueLastWeek = lastWeekTransactions
        .where((t) => double.parse(t['amount']) > 0)
        .fold(0.0, (total, t) => total + double.parse(t['amount']));

    // Calculate food expenses for the last week
    _foodLastWeek = lastWeekTransactions
        .where((t) =>
            double.parse(t['amount']) < 0 &&
            (t['category'].toString().toLowerCase() == 'food' ||
                t['category'].toString().toLowerCase() == 'pantry'))
        .fold(0.0, (total, t) => total + double.parse(t['amount']).abs());
  }

  void _filterTransactions() {
    final now = DateTime.now();
    DateTime startDate;

    switch (model.selectedPeriodIndex) {
      case 0: // Daily
        startDate = DateTime(now.year, now.month, now.day);
        break;
      case 1: // Weekly
        startDate = now.subtract(Duration(days: now.weekday - 1));
        startDate = DateTime(startDate.year, startDate.month, startDate.day);
        break;
      case 2: // Monthly
      default:
        startDate = DateTime(now.year, now.month, 1);
        break;
    }

    _filteredTransactions = _allTransactions.where((transaction) {
      final transactionDate = transaction['timestamp'] as DateTime?;
      if (transactionDate == null) return false;
      return transactionDate.isAfter(startDate) || transactionDate.isAtSameMomentAs(startDate);
    }).toList();

    // Recalculate total expenses for the filtered period
    _totalExpense = _filteredTransactions
        .where((t) => double.parse(t['amount']) < 0)
        .fold(0.0, (total, t) => total + double.parse(t['amount']).abs());
  }

  void onPeriodTapped(int index) {
    model.selectedPeriodIndex = index;
    _filterTransactions();
    notifyListeners();
  }
}