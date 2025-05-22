import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/transaction_model.dart';
import '../Services/data_service.dart';

class TransactionController extends ChangeNotifier {
  final DataService _dataService;
  List<TransactionModel> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  DateTime? _selectedDate;
  String? _errorMessage;
  bool _isLoading = false;

  TransactionController(this._dataService) {
    _setupAuthListener();
  }

  // Getters
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
  
  String get formattedSelectedDate {
    if (_selectedDate == null) return '';
    return '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        _setupDataListener();
      }
    });
  }

  void _clearState() {
    _transactions = [];
    _totalIncome = 0.0;
    _totalExpenses = 0.0;
    _selectedDate = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
  
  void _setupDataListener() {
    _isLoading = true;
    notifyListeners();
    
    _dataService.addListener(_onDataServiceChanged);
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
  }
  
  Future<void> addExpense(TransactionModel transaction) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final expense = TransactionModel.expense(
        amount: transaction.amount.abs(),
        date: transaction.date,
        description: transaction.description,
        category: transaction.category,
        categoryId: transaction.categoryId,
        icon: transaction.icon,
      );

      final userId = FirebaseAuth.instance.currentUser!.uid;
      await _dataService.addTransaction(userId, expense);
      
      _selectedDate = null; 
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add expense: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> addIncome(TransactionModel transaction) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      final income = TransactionModel.income(
        amount: transaction.amount,
        date: transaction.date,
        description: transaction.description,
      );

      final userId = FirebaseAuth.instance.currentUser!.uid;
      await _dataService.addTransaction(userId, income);
      
      _selectedDate = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to add income: $e';
      _isLoading = false;
      notifyListeners();
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
  
  Future<void> updateTransaction(TransactionModel transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      final oldTransactionIndex = _transactions.indexWhere((t) => t.id == transaction.id);
      
      if (oldTransactionIndex == -1) {
        _errorMessage = 'Transaction not found in local cache';
        _isLoading = false;
        notifyListeners();
        return;
      }
      
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await _dataService.updateTransaction(userId, _transactions[oldTransactionIndex], transaction);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to update transaction: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
  
  Future<void> deleteTransaction(TransactionModel transaction) async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await _dataService.deleteTransaction(userId, transaction);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to delete transaction: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryLoading() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      await _dataService.refreshData(userId);
      _onDataServiceChanged();
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataServiceChanged);
    super.dispose();
  }
}
