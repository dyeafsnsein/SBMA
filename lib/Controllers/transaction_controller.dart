import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Added import for StreamSubscription

class TransactionController extends ChangeNotifier {
  List<Map<String, dynamic>> _transactions = [];
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  DateTime? _selectedDate;

  // Streams for Firestore listeners
  StreamSubscription<DocumentSnapshot>? _balanceSubscription;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;

  List<Map<String, dynamic>> get transactions {
    if (_selectedDate == null) return _transactions;
    return _transactions.where((transaction) {
      final transactionDate = transaction['timestamp'] as DateTime?;
      if (transactionDate == null) return false;
      return transactionDate.year == _selectedDate!.year &&
          transactionDate.month == _selectedDate!.month &&
          transactionDate.day == _selectedDate!.day;
    }).toList();
  }

  double get totalBalance => _totalBalance;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;

  TransactionController() {
    _setupAuthListener();
  }

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
    _transactions = [];
    _totalBalance = 0.0;
    _totalIncome = 0.0;
    _totalExpenses = 0.0;
    _selectedDate = null;

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
        .listen((userDoc) {
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _totalBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;
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
      _transactions = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'category': data['category'] ?? 'Unknown',
          'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
          'description': data['description'] ?? '',
          'type': data['type'] ?? 'expense',
          'icon': data['icon'] ?? 'lib/assets/Transaction.png',
        };
      }).toList();

      _calculateTotals();
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error listening to transactions: $e');
    });
  }

  void _calculateTotals() {
    _totalIncome = _transactions
        .where((t) => t['type'] == 'income')
        .fold(0.0, (total, t) => total + (t['amount'] as double));

    _totalExpenses = _transactions
        .where((t) => t['type'] == 'expense')
        .fold(0.0, (total, t) => total + (t['amount'] as double).abs());
  }

  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final amount = double.parse(expenseData['amount'].toString());
      final transaction = {
        'type': 'expense',
        'amount': -amount, // Store as negative for expenses
        'timestamp': Timestamp.now(),
        'description': expenseData['description'] ?? '',
        'category': expenseData['category'] ?? '',
        'icon': expenseData['icon'] ?? 'lib/assets/Transaction.png',
      };

      // Use a batch to ensure atomic updates
      final batch = FirebaseFirestore.instance.batch();
      final transactionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc();
      batch.set(transactionRef, transaction);

      // Update the user's balance
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      final currentBalance = (userDoc.data()?['balance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance - amount;
      batch.update(userRef, {'balance': newBalance});

      await batch.commit();
    } catch (e) {
      debugPrint('Error adding expense: $e');
    }
  }

  Future<void> addIncome(Map<String, dynamic> incomeData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final amount = double.parse(incomeData['amount'].toString());
      final transaction = {
        'type': 'income',
        'amount': amount,
        'timestamp': Timestamp.now(),
        'description': incomeData['description'] ?? '',
        'category': 'Income',
        'icon': 'lib/assets/Salary.png',
      };

      // Use a batch to ensure atomic updates
      final batch = FirebaseFirestore.instance.batch();
      final transactionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc();
      batch.set(transactionRef, transaction);

      // Update the user's balance
      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      final currentBalance = (userDoc.data()?['balance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance + amount;
      batch.update(userRef, {'balance': newBalance});

      await batch.commit();
    } catch (e) {
      debugPrint('Error adding income: $e');
    }
  }

  void setFilterDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  void clearFilter() {
    _selectedDate = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();
    super.dispose();
  }
}