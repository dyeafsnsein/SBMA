import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../Models/transaction_model.dart';
import '../services/data_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionController extends ChangeNotifier {
  final DataService _dataService;
  List<TransactionModel> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  DateTime? _selectedDate;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;
  String? _errorMessage;
  bool _isLoading = false;

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
  DateTime? get selectedDate => _selectedDate;
  bool get isDateFiltered => _selectedDate != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
    _errorMessage = null;
    _isLoading = false;

    notifyListeners();
  }

  void _setupListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _clearState();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _transactionSubscription?.cancel(); // Prevent duplicate listeners
    _transactionSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) async {
      _transactions = snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
      _calculateTotals();
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = 'Failed to load transactions: $e';
      _isLoading = false;
      debugPrint('Error listening to transactions: $e');
      notifyListeners();
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

  Future<void> addExpense(TransactionModel transaction) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final batch = FirebaseFirestore.instance.batch();
      final transactionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc();
      
      // Adjust amount for expense (negative)
      final expense = TransactionModel(
        id: transactionRef.id,
        type: 'expense',
        amount: -transaction.amount.abs(),
        date: transaction.date,
        description: transaction.description,
        category: transaction.category,
        categoryId: transaction.categoryId,
        icon: transaction.icon,
      );

      batch.set(transactionRef, expense.toFirestore());

      // Update balance via DataService
      await _dataService.updateBalance(user.uid, transaction.amount, true);

      await batch.commit();
      _selectedDate = null; // Reset the date filter after adding a transaction
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add expense: $e';
      debugPrint('Error adding expense: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to add expense: $e');
    }
  }

  Future<void> addIncome(TransactionModel transaction) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final batch = FirebaseFirestore.instance.batch();
      final transactionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc();

      // Use "Income" category for income transactions
      final income = TransactionModel(
        id: transactionRef.id,
        type: 'income',
        amount: transaction.amount,
        date: transaction.date,
        description: transaction.description,
        category: 'Income',
        categoryId: 'income',
        icon: transaction.icon,
      );

      batch.set(transactionRef, income.toFirestore());

      // Update balance via DataService
      await _dataService.updateBalance(user.uid, transaction.amount, false);

      await batch.commit();
      _selectedDate = null; // Reset the date filter after adding a transaction
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add income: $e';
      debugPrint('Error adding income: $e');
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to add income: $e');
    }
  }

  Future<void> retryLoading() async {
    _clearState();
    _setupListeners();
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