import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import '../Models/transaction_model.dart';
import '../Services/data_service.dart';
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
  
  /// Returns the formatted selected date 
  String get formattedSelectedDate {
    if (_selectedDate == null) return '';
    
    // Use the DateFormat directly to be consistent with TransactionModel
    return '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
  }

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

    // Cancel any existing subscriptions
    _transactionSubscription?.cancel(); 
    
    // Add listener to dataService
    _dataService.addListener(_onDataServiceChanged);
    
    // Initial data load
    _onDataServiceChanged();
  }
    void _onDataServiceChanged() {
    _transactions = List.from(_dataService.transactions);
    _calculateTotals();
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }
  void _calculateTotals() {
    _totalIncome = _transactions
        .where((t) => t.isIncome)
        .fold(0.0, (total, t) => total + t.amount);

    _totalExpenses = _transactions
        .where((t) => t.isExpense)
        .fold(0.0, (total, t) => total + t.absoluteAmount);
  }  Future<void> addExpense(TransactionModel transaction) async {
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
      // Use the factory method to create a standardized expense
      final expense = TransactionModel.expense(
        amount: transaction.amount.abs(),
        date: transaction.date,
        description: transaction.description,
        category: transaction.category,
        categoryId: transaction.categoryId,
        icon: transaction.icon,
      );

      // Use DataService to add the transaction
      await _dataService.addTransaction(user.uid, expense);
      
      _selectedDate = null; // Reset the date filter after adding a transaction
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add expense: $e';
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to add expense: $e');
    }
  }  Future<void> addIncome(TransactionModel transaction) async {
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
      // Use the factory method to create a standardized income transaction
      final income = TransactionModel.income(
        amount: transaction.amount,
        date: transaction.date,
        description: transaction.description,
      );

      // Use DataService to add the transaction
      await _dataService.addTransaction(user.uid, income);
      
      _selectedDate = null; // Reset the date filter after adding a transaction
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add income: $e';
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
  }  Future<void> updateTransaction(TransactionModel transaction) async {
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
      // Get the old transaction to pass to DataService
      final oldTransactionIndex = _transactions.indexWhere((t) => t.id == transaction.id);
      
      // If we don't have the transaction locally, we can't update it properly
      if (oldTransactionIndex == -1) {
        _errorMessage = 'Cannot update: Transaction not found in local cache';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final oldTransaction = _transactions[oldTransactionIndex];
      
      // Use DataService to update the transaction
      await _dataService.updateTransaction(user.uid, oldTransaction, transaction);
      
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update transaction: $e';
      _isLoading = false;
      notifyListeners();
      // Don't rethrow to prevent app crashes
    }
  }  Future<void> deleteTransaction(TransactionModel transaction) async {
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
      // Use DataService to delete the transaction
      await _dataService.deleteTransaction(user.uid, transaction);
      
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete transaction: $e';
      _isLoading = false;
      notifyListeners();
      // Don't rethrow to prevent app crashes
    }
  }
  @override
  void dispose() {
    _transactionSubscription?.cancel();
    _dataService.removeListener(_onDataServiceChanged);
    super.dispose();
  }
}
