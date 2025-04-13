import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/home_model.dart';
import '../services/auth_service.dart';
import '../Models/transaction_model.dart';

class HomeController extends ChangeNotifier {
  final HomeModel model = HomeModel();
  final AuthService _authService = AuthService();

  double _totalBalance = 0.0;
  double _totalExpense = 0.0;
  double _revenueLastWeek = 0.0;
  double _foodLastWeek = 0.0;
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  int _selectedPeriodIndex = 0;

  HomeController() {
    _fetchUserData();
  }

  double get totalBalance => _totalBalance;
  double get totalExpense => _totalExpense;
  double get revenueLastWeek => _revenueLastWeek;
  double get foodLastWeek => _foodLastWeek;
  int get selectedPeriodIndex => _selectedPeriodIndex;
  List<String> get periods => model.periods;
  List<TransactionModel> get transactions => _filteredTransactions;

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
          return TransactionModel(
            type: data['type'] ?? 'expense',
            amount: double.parse(data['amount'].toString()),
            date: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            description: data['description'] ?? '',
            category: data['category'] ?? '',
            icon: data['icon'] ?? 'lib/assets/Transaction.png',
          );
        }).toList();

        // Calculate revenue and food expenses for the last week
        _calculateLastWeekMetrics();

        // Initial filter based on the default period (Monthly)
        _filterTransactions();
        notifyListeners();
      } catch (e) {
        // Error handling
      }
    }
  }

  void _calculateLastWeekMetrics() {
    final now = DateTime.now();
    final lastWeekStart = now.subtract(const Duration(days: 7));
    final lastWeekTransactions = _allTransactions.where((transaction) {
      return transaction.date.isAfter(lastWeekStart) || transaction.date.isAtSameMomentAs(lastWeekStart);
    }).toList();

    // Calculate revenue (income) for the last week
    _revenueLastWeek = lastWeekTransactions
        .where((t) => t.amount > 0)
        .fold(0.0, (total, t) => total + t.amount);

    // Calculate food expenses for the last week
    _foodLastWeek = lastWeekTransactions
        .where((t) =>
            t.amount < 0 &&
            (t.category.toLowerCase() == 'food' ||
                t.category.toLowerCase() == 'pantry'))
        .fold(0.0, (total, t) => total + t.amount.abs());
  }

  void _filterTransactions() {
    final now = DateTime.now();
    DateTime startDate;
    switch (_selectedPeriodIndex) {
      case 0: // Daily
        startDate = now.subtract(const Duration(days: 1));
        break;
      case 1: // Weekly
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 2: // Monthly
        startDate = DateTime(now.year, now.month, 1);
        break;
      default:
        startDate = now.subtract(const Duration(days: 1));
    }

    _filteredTransactions = _allTransactions.where((transaction) {
      return transaction.date.isAfter(startDate) || transaction.date.isAtSameMomentAs(startDate);
    }).toList();
  }

  void onPeriodTapped(int index) {
    _selectedPeriodIndex = index;
    _filterTransactions();
    notifyListeners();
  }
}