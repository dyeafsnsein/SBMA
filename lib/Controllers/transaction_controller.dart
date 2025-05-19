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
      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
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
          .doc();      // Use "Income" category for income transactions
      final income = TransactionModel(
        id: transactionRef.id,
        type: 'income',
        amount: transaction.amount,
        date: transaction.date,
        description: transaction.description,
        category: 'Income', // Always use 'Income' category for income transactions
        categoryId: 'income',
        icon: 'lib/assets/Income.png', // Always use Income icon
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
      final transactionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc(transaction.id);
      
      // Get the old transaction to calculate balance difference
      final oldTransactionIndex = _transactions.indexWhere((t) => t.id == transaction.id);
      
      // If we don't have the transaction locally, try to fetch it directly
      if (oldTransactionIndex == -1) {
        debugPrint('Transaction with ID: ${transaction.id} not found in local cache. Fetching from Firestore.');
        try {
          final docSnapshot = await transactionRef.get();
          
          if (!docSnapshot.exists) {
            _errorMessage = 'Cannot update: Transaction not found';
            debugPrint('Transaction with ID: ${transaction.id} not found in Firestore.');
            _isLoading = false;
            notifyListeners();
            return;
          }
        } catch (e) {
          _errorMessage = 'Error fetching transaction: $e';
          debugPrint('Error fetching transaction: $e');
          _isLoading = false;
          notifyListeners();
          return;
        }
      }
        // Document exists, proceed with normal update
      final batch = FirebaseFirestore.instance.batch();
      
      double balanceDifference = 0.0;
      if (oldTransactionIndex != -1) {
        final oldTransaction = _transactions[oldTransactionIndex];
        balanceDifference = transaction.amount - oldTransaction.amount;
      }

      // Update the transaction in Firestore
      batch.update(transactionRef, transaction.toFirestore());

      // Update balance via DataService if we have the old transaction
      if (oldTransactionIndex != -1) {
        await _dataService.updateBalance(
            user.uid, balanceDifference, transaction.type == 'expense');
      }

      await batch.commit();
      _isLoading = false;
      notifyListeners();    } catch (e) {
      _errorMessage = 'Failed to update transaction: $e';
      debugPrint('Error updating transaction: $e');
      _isLoading = false;
      notifyListeners();
      // Don't rethrow to prevent app crashes
    }
  }
  Future<void> deleteTransaction(TransactionModel transaction) async {
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
      final transactionRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .doc(transaction.id);
          
      // First check if the document exists
      final docSnapshot = await transactionRef.get();
      
      if (!docSnapshot.exists) {
        debugPrint('Transaction with ID: ${transaction.id} not found in Firestore when trying to delete.');
        // Document doesn't exist, so nothing to delete
        _isLoading = false;
        notifyListeners();
        return;
      }
        final batch = FirebaseFirestore.instance.batch();
      batch.delete(transactionRef);

      // When deleting a transaction, we need to do the reverse operation:
      // - For expense (negative amount): Add it back to balance
      // - For income (positive amount): Subtract it from balance
      if (transaction.type == 'expense') {
        // For expense transactions, add the amount back (use the absolute value)
        // Since expense amounts are stored as negative, we need the absolute value
        await _dataService.updateBalance(
            user.uid, transaction.amount.abs(), false);
      } else {
        // For income transactions, subtract the amount
        await _dataService.updateBalance(
            user.uid, transaction.amount, true);
      }

      await batch.commit();
      _isLoading = false;
      notifyListeners();    } catch (e) {
      _errorMessage = 'Failed to delete transaction: $e';
      debugPrint('Error deleting transaction: $e');
      _isLoading = false;
      notifyListeners();
      // Don't rethrow to prevent app crashes
    }
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
