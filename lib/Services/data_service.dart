import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../Models/transaction_model.dart';

class DataService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _balanceSubscription;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;
  double _totalBalance = 0.0;
  double _totalExpense = 0.0;
  double _totalIncome = 0.0;
  List<TransactionModel> _transactions = [];
  final Map<String, double> _categoryBreakdown = {};
  final Map<String, String> _categoryIcons = {};
  bool _isDataLoaded = false;
  DateTime? _lastTransactionUpdate;

  double get totalBalance => _totalBalance;
  double get totalExpense => _totalExpense;
  double get totalIncome => _totalIncome;
  List<TransactionModel> get transactions => List.unmodifiable(_transactions);
  Map<String, double> get categoryBreakdown =>
      Map.unmodifiable(_categoryBreakdown);
  Map<String, String> get categoryIcons => Map.unmodifiable(_categoryIcons);
  bool get isDataLoaded => _isDataLoaded;
  DateTime? get lastTransactionUpdate => _lastTransactionUpdate;

  DataService() {
    _setupAuthListener();
    final currentUser = _auth.currentUser;
    if (currentUser != null) {
      _setUserData(currentUser.uid);
      _setupListeners(currentUser.uid);
    }
  }

  // Helper to set all user data from Firestore
  Future<void> _setUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _totalBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;
        _isDataLoaded = true;
      }
      final txSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .get();
      _loadTransactionsFromSnapshot(txSnapshot);
      await _loadCategories(userId);
      notifyListeners();
    } catch (e) {
      _clearState();
      throw Exception('Error setting user data: $e');
    }
  }

  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        _setUserData(user.uid);
        _setupListeners(user.uid);
      }
    });
  }

  void _clearState() {
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();
    _balanceSubscription = null;
    _transactionSubscription = null;
    _totalBalance = 0.0;
    _totalExpense = 0.0;
    _totalIncome = 0.0;
    _transactions.clear();
    _categoryBreakdown.clear();
    _categoryIcons.clear();
    _isDataLoaded = false;
    notifyListeners();
  }

  void _setupListeners(String userId) {
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();

    _balanceSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((userDoc) async {
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _totalBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;
        _isDataLoaded = true;
        notifyListeners();
      }
    }, onError: (e) {
      _clearState();
    });

    _transactionSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _loadTransactionsFromSnapshot(snapshot);
      notifyListeners();
    }, onError: (e) {
      _clearState();
    });
  }

  // Only call _setUserData for refresh
  Future<void> refreshData(String userId) async {
    await _setUserData(userId);
  }

  // Remove redundant notifyListeners in _loadTransactionsFromSnapshot and _loadCategories
  void _loadTransactionsFromSnapshot(QuerySnapshot snapshot) {
    _totalExpense = 0.0;
    _totalIncome = 0.0;
    _categoryBreakdown.clear();
    _transactions = [];
    _lastTransactionUpdate = DateTime.now();
    for (var doc in snapshot.docs) {
      try {
        final transaction = TransactionModel.fromFirestore(doc);
        _transactions.add(transaction);
        if (transaction.isExpense) {
          _totalExpense += transaction.absoluteAmount;
          final category = transaction.category;
          _categoryBreakdown[category] = (_categoryBreakdown[category] ?? 0.0) +
              transaction.absoluteAmount;
        } else if (transaction.isIncome) {
          _totalIncome += transaction.amount;
        }
      } catch (e) {}
    }
  }

  Future<void> _loadCategories(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .get();
    _categoryIcons.clear();
    for (var doc in snapshot.docs) {
      final label = doc['label'];
      final icon = doc['icon'];
      if (label is String && icon is String) {
        _categoryIcons[label] = icon;
      }
    }
  }

  String getIconForCategory(String category) {
    return _categoryIcons[category] ?? 'lib/assets/Transaction.png';
  }

  Future<void> updateBalance(
      String userId, double amount, bool isExpense) async {
    final userRef = _firestore.collection('users').doc(userId);
    final userDoc = await userRef.get();
    final currentBalance =
        (userDoc.data()?['balance'] as num?)?.toDouble() ?? 0.0;
    final newBalance =
        isExpense ? currentBalance - amount : currentBalance + amount;
    await userRef.update({'balance': newBalance});
  }

  // Add a transaction
  Future<String> addTransaction(
      String userId, TransactionModel transaction) async {
    try {
      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc();
      final transactionWithId = transaction.copyWith(id: transactionRef.id);
      await transactionRef.set(transactionWithId.toFirestore());
      await updateBalance(
          userId, transaction.absoluteAmount, transaction.isExpense);
      await _setUserData(userId);
      return transactionRef.id;
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }

  // Update a transaction
  Future<void> updateTransaction(String userId, TransactionModel oldTransaction,
      TransactionModel newTransaction) async {
    try {
      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(newTransaction.id);
      await transactionRef.update(newTransaction.toFirestore());
      if (oldTransaction.type != newTransaction.type) {
        await updateBalance(
            userId, oldTransaction.absoluteAmount, !oldTransaction.isExpense);
        await updateBalance(
            userId, newTransaction.absoluteAmount, newTransaction.isExpense);
      } else {
        final amountDifference = oldTransaction.isExpense
            ? oldTransaction.absoluteAmount - newTransaction.absoluteAmount
            : newTransaction.amount - oldTransaction.amount;
        final addToBalance = amountDifference > 0;
        if (amountDifference != 0) {
          await updateBalance(userId, amountDifference.abs(), !addToBalance);
        }
      }
      await _setUserData(userId);
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(
      String userId, TransactionModel transaction) async {
    try {
      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id);
      final docSnapshot = await transactionRef.get();
      if (!docSnapshot.exists) {
        return;
      }
      await transactionRef.delete();
      if (transaction.isExpense) {
        await updateBalance(userId, transaction.absoluteAmount, false);
      } else {
        await updateBalance(userId, transaction.amount, true);
      }
      await _setUserData(userId);
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }

  // Recalculate balance from all transactions
  Future<void> recalculateBalance(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();
      double totalIncome = 0.0;
      double totalExpense = 0.0;
      for (var doc in snapshot.docs) {
        final transaction = TransactionModel.fromFirestore(doc);
        if (transaction.isIncome) {
          totalIncome += transaction.amount;
        } else if (transaction.isExpense) {
          totalExpense += transaction.absoluteAmount;
        }
      }
      final calculatedBalance = totalIncome - totalExpense;
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'balance': calculatedBalance});
      await _setUserData(userId);
    } catch (e) {
      throw Exception('Error recalculating balance: $e');
    }
  }

  // A method to calculate last week metrics that could be used by multiple controllers
  Map<String, dynamic> calculateLastWeekMetrics() {
    final now = DateTime.now();
    final lastWeekStart = now.subtract(const Duration(days: 7));
    final lastWeekTransactions = _transactions.where((transaction) {
      return transaction.date.isAfter(lastWeekStart) ||
          transaction.date.isAtSameMomentAs(lastWeekStart);
    }).toList();

    final revenueLastWeek = lastWeekTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (total, t) => total + t.amount);

    final categorySpending = <String, double>{};
    final categoryIcons = <String, String>{};

    for (var transaction in lastWeekTransactions) {
      if (transaction.isExpense) {
        final category = transaction.category;
        categorySpending[category] =
            (categorySpending[category] ?? 0) + transaction.absoluteAmount;
        categoryIcons[category] = transaction.icon;
      }
    }

    String topCategory = 'None';
    double topAmount = 0.0;
    String topIcon = 'lib/assets/Salary.png';

    if (categorySpending.isNotEmpty) {
      final topEntry =
          categorySpending.entries.reduce((a, b) => a.value > b.value ? a : b);
      topCategory = topEntry.key;
      topAmount = topEntry.value;
      topIcon = categoryIcons[topEntry.key] ?? 'lib/assets/Salary.png';
    }

    return {
      'revenueLastWeek': revenueLastWeek,
      'topCategory': topCategory,
      'topAmount': topAmount,
      'topIcon': topIcon,
    };
  }

  // Filter transactions for a given period
  List<TransactionModel> getFilteredTransactions(int periodIndex) {
    final now = DateTime.now();
    DateTime startDate;
    switch (periodIndex) {
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

    return _transactions.where((transaction) {
      return transaction.date.isAfter(startDate) ||
          transaction.date.isAtSameMomentAs(startDate);
    }).toList();
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
