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
  Map<String, double> _categoryBreakdown = {};
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
      _loadCategories(currentUser.uid).then((_) {
        _setupListeners(currentUser.uid);
      });
    }
  }

  void _setupAuthListener() {
    _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        _loadCategories(user.uid).then((_) {
          _setupListeners(user.uid);
        });
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
      _isDataLoaded = false;
      notifyListeners();
    });

    _transactionSubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _loadTransactionsFromSnapshot(snapshot);
    }, onError: (e) {
      _totalExpense = 0.0;
      _totalIncome = 0.0;
      _transactions = [];
      _categoryBreakdown.clear();
      notifyListeners();
    });
  }
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

        // Update totals and category breakdown
        if (transaction.isExpense) {
          _totalExpense += transaction.absoluteAmount;
          
          // Update category breakdown
          final category = transaction.category;
          _categoryBreakdown[category] = (_categoryBreakdown[category] ?? 0.0) + transaction.absoluteAmount;
        } else if (transaction.isIncome) {
          _totalIncome += transaction.amount;
        }
      } catch (e) {
        // Skip invalid transactions
      }
    }

    notifyListeners();
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
    notifyListeners();
  }
  
  // Method to refresh data from Firestore
  Future<void> refreshData(String userId) async {
    try {
      // Refresh user data (balance)
      final userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _totalBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;
        _isDataLoaded = true;
      }

      // Refresh transactions
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .get();
          
      _loadTransactionsFromSnapshot(snapshot);
    } catch (e) {
      throw Exception('Error refreshing data: $e');
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
  Future<String> addTransaction(String userId, TransactionModel transaction) async {
    try {
      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc();
          
      // Create a copy with the generated ID
      final transactionWithId = transaction.copyWith(id: transactionRef.id);

      // Add to Firestore
      await transactionRef.set(transactionWithId.toFirestore());

      // Update balance
      await updateBalance(userId,
          transaction.absoluteAmount,
          transaction.isExpense);

      // Refresh local data
      await refreshData(userId);

      return transactionRef.id;
    } catch (e) {
      throw Exception('Error adding transaction: $e');
    }
  }
    // Update a transaction
  Future<void> updateTransaction(String userId, TransactionModel oldTransaction, TransactionModel newTransaction) async {
    try {
      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(newTransaction.id);

      // Update the transaction in Firestore
      await transactionRef.update(newTransaction.toFirestore());
      
      // Handle balance adjustment
      if (oldTransaction.type != newTransaction.type) {
        // Transaction type changed (expense to income or vice versa)
        
        // Reverse old transaction effect
        await updateBalance(userId,
            oldTransaction.absoluteAmount,
            !oldTransaction.isExpense);

        // Apply new transaction effect
        await updateBalance(userId,
            newTransaction.absoluteAmount,
            newTransaction.isExpense);
      } else {
        // Same transaction type, calculate the amount difference
        final amountDifference = oldTransaction.isExpense
            ? oldTransaction.absoluteAmount - newTransaction.absoluteAmount
            : newTransaction.amount - oldTransaction.amount;
        
        final addToBalance = amountDifference > 0;
        
        if (amountDifference != 0) {
          await updateBalance(userId, amountDifference.abs(), !addToBalance);
        }
      }

      // Refresh local data
      await refreshData(userId);
    } catch (e) {
      throw Exception('Error updating transaction: $e');
    }
  }

  // Delete a transaction
  Future<void> deleteTransaction(String userId, TransactionModel transaction) async {
    try {
      final transactionRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .doc(transaction.id);
          
      // First check if the document exists
      final docSnapshot = await transactionRef.get();

      if (!docSnapshot.exists) {
        return; // Transaction not found, nothing to delete
      }
      
      // Delete the transaction
      await transactionRef.delete();
      
      // Adjust balance by reversing the transaction effect
      if (transaction.isExpense) {
        await updateBalance(userId, transaction.absoluteAmount, false); // Add the amount back
      } else {
        await updateBalance(userId, transaction.amount, true); // Subtract the amount
      }

      // Refresh local data
      await refreshData(userId);
    } catch (e) {
      throw Exception('Error deleting transaction: $e');
    }
  }
    // Recalculate balance from all transactions
  Future<void> recalculateBalance(String userId) async {
    try {
      // Get all transactions
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();
    
      // Calculate balance from transactions
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
    
      // Update the balance in Firestore
      await _firestore.collection('users').doc(userId).update({
        'balance': calculatedBalance
      });
      
      // Refresh local data
      await refreshData(userId);
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
