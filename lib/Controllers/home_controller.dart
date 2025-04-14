import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Added import for StreamSubscription
import '../Models/home_model.dart';
import '../Models/transaction_model.dart';

class HomeController extends ChangeNotifier {
  final HomeModel model = HomeModel();

  double _totalBalance = 0.0;
  double _totalExpense = 0.0;
  double _revenueLastWeek = 0.0;
  double _foodLastWeek = 0.0;
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  int _selectedPeriodIndex = 2; // Default to Monthly

  // Streams for Firestore listeners
  StreamSubscription<DocumentSnapshot>? _balanceSubscription;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;

  HomeController() {
    _setupAuthListener();
  }

  double get totalBalance => _totalBalance;
  double get totalExpense => _totalExpense;
  double get revenueLastWeek => _revenueLastWeek;
  double get foodLastWeek => _foodLastWeek;
  int get selectedPeriodIndex => _selectedPeriodIndex;
  List<String> get periods => model.periods;
  List<TransactionModel> get transactions => _filteredTransactions;

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // User logged out
        _clearState();
      } else {
        // User logged in
        _setupListeners();
      }
    });
  }

  void _clearState() {
    // Cancel existing subscriptions
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();
    _balanceSubscription = null;
    _transactionSubscription = null;

    // Clear in-memory data
    _totalBalance = 0.0;
    _totalExpense = 0.0;
    _revenueLastWeek = 0.0;
    _foodLastWeek = 0.0;
    _allTransactions = [];
    _filteredTransactions = [];

    notifyListeners();
  }

  void _setupListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _clearState();
      return;
    }

    // Stream for user balance
    _balanceSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((userDoc) async {
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _totalBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;

        // Recalculate total expenses (since balance might change due to transactions)
        await _calculateTotalExpense();
        _filterTransactions();
        notifyListeners();
      }
    }, onError: (e) {
      debugPrint('Error listening to user balance: $e');
    });

    // Stream for transactions
    _transactionSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _allTransactions = snapshot.docs.map((doc) {
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

      _calculateLastWeekMetrics();
      _calculateTotalExpense();
      _filterTransactions();
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error listening to transactions: $e');
    });
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

    // Calculate revenue (income) for the last week
    _revenueLastWeek = lastWeekTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (total, t) => total + t.amount);

    // Calculate food expenses for the last week
    _foodLastWeek = lastWeekTransactions
        .where((t) =>
            t.type == 'expense' &&
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
      _totalBalance = balance;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting balance: $e');
    }
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();
    super.dispose();
  }
}