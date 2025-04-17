import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Models/transaction_model.dart';
import '../services/data_service.dart';

class TransactionController extends ChangeNotifier {
  final DataService _dataService;
  List<TransactionModel> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  DateTime? _selectedDate;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;

  List<TransactionModel> get transactions {
    if (_selectedDate == null) return _transactions;
    return _transactions.where((transaction) {
      return transaction.date.year == _selectedDate!.year &&
          transaction.date.month == _selectedDate!.month &&
          transaction.date.day == _selectedDate!.day;
    }).toList();
  }

  double get totalBalance => _dataService.totalBalance;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;

  TransactionController(this._dataService) {
    _setupAuthListener();
  }

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

    _transactions = [];
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

    _transactionSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      _transactions = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] ?? 'Unknown';
        final icon = data['icon'] ?? await _dataService.getIconForCategory(category);
        final timestamp = data['timestamp'] as Timestamp?;
        final transactionDate = timestamp != null ? timestamp.toDate().toLocal() : DateTime.now();
        debugPrint('Retrieved Transaction Date: $transactionDate');
        _transactions.add(TransactionModel(
          type: data['type'] ?? 'expense',
          amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
          date: transactionDate,
          description: data['description'] ?? '',
          category: category,
          icon: icon,
        ));
      }

      _calculateTotals();
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error listening to transactions: $e');
    });
  }

  void _calculateTotals() {
    _totalIncome = _transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (total, t) => total + t.amount);

    _totalExpenses = _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (total, t) => total + t.amount.abs());
  }

  Future<void> addExpense(Map<String, dynamic> expenseData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      debugPrint('Received expenseData: $expenseData');
      debugPrint('Raw date value: ${expenseData['date']}');
      debugPrint('Raw date type: ${expenseData['date'].runtimeType}');
      final amount = double.parse(expenseData['amount'].toString());
      final category = expenseData['category'] ?? 'Unknown';
      final icon = expenseData['icon'] ?? await _dataService.getIconForCategory(category);
      final date = expenseData['date'] as DateTime? ?? DateTime.now();
      debugPrint('Processed Date: $date');
      final transaction = {
        'type': 'expense',
        'amount': -amount,
        'timestamp': Timestamp.fromDate(date),
        'description': expenseData['description'] ?? '',
        'category': category,
        'icon': icon,
      };

      final batch = FirebaseFirestore.instance.batch();
      final transactionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc();
      batch.set(transactionRef, transaction);

      // Update balance via DataService
      await _dataService.updateBalance(user.uid, amount, true);

      await batch.commit();
      _selectedDate = null; // Reset the date filter after adding a transaction
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding expense: $e');
      throw Exception('Failed to add expense: $e');
    }
  }

  Future<void> addIncome(Map<String, dynamic> incomeData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      debugPrint('Received incomeData: $incomeData');
      debugPrint('Raw date value: ${incomeData['date']}');
      debugPrint('Raw date type: ${incomeData['date'].runtimeType}');
      final amount = double.parse(incomeData['amount'].toString());
      final category = 'Income';
      final icon = await _dataService.getIconForCategory(category);
      final date = incomeData['date'] as DateTime? ?? DateTime.now();
      debugPrint('Processed Date: $date');
      final transaction = {
        'type': 'income',
        'amount': amount,
        'timestamp': Timestamp.fromDate(date),
        'description': incomeData['description'] ?? '',
        'category': category,
        'icon': icon,
      };

      final batch = FirebaseFirestore.instance.batch();
      final transactionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc();
      batch.set(transactionRef, transaction);

      // Update balance via DataService
      await _dataService.updateBalance(user.uid, amount, false);

      await batch.commit();
      _selectedDate = null; // Reset the date filter after adding a transaction
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding income: $e');
      throw Exception('Failed to add income: $e');
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
    _transactionSubscription?.cancel();
    super.dispose();
  }
}