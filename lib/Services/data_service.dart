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

  // Track transactions that were recently modified through the app
  final Set<String> _recentlyAddedTransactions = {};
  final Set<String> _recentlyDeletedTransactions = {};
  final Set<String> _recentlyModifiedTransactions = {};

  // Track last document change timestamp to prevent multiple recalculations
  DateTime? _lastRecalculationTime;

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
      debugPrint('DataService: Error listening to user balance: $e');
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
      debugPrint('DataService: Error listening to transactions: $e');
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

    debugPrint('DataService: Processing ${snapshot.docs.length} transactions');

    for (var doc in snapshot.docs) {
      try {
        // Use the TransactionModel.fromFirestore method for consistency
        final transaction = TransactionModel.fromFirestore(doc);
        _transactions.add(transaction);

        if (transaction.type == 'expense') {
          _totalExpense += transaction.amount;
          _categoryBreakdown[transaction.category] =
              (_categoryBreakdown[transaction.category] ?? 0.0) + transaction.amount;
        } else if (transaction.type == 'income') {
          _totalIncome += transaction.amount;
        }
      } catch (e) {
        debugPrint('DataService: Error parsing transaction ${doc.id}: $e');
      }
    }

    debugPrint(
        'DataService: Loaded ${_transactions.length} transactions: totalIncome=$_totalIncome, totalExpense=$_totalExpense, categories=$_categoryBreakdown');
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
      } else {
        debugPrint(
            'DataService: Invalid category data for doc ${doc.id}: label=$label, icon=$icon');
      }
    }
    notifyListeners();
  }

  Future<void> reloadTransactions(String userId) async {
    try {
      debugPrint('DataService: Reloading transactions for user: $userId');
      var snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .get();
      debugPrint(
          'DataService: Query found ${snapshot.docs.length} transactions');
      _loadTransactionsFromSnapshot(snapshot);
    } catch (e) {
      debugPrint('DataService: Error reloading transactions: $e');
      _totalExpense = 0.0;
      _totalIncome = 0.0;
      _transactions = [];
      _categoryBreakdown.clear();
      notifyListeners();
    }
  }

  // Method to refresh data from Firestore
  Future<void> refreshData(String userId) async {
    try {
      debugPrint('DataService: Refreshing data for user: $userId');

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

      return;
    } catch (e) {
      debugPrint('DataService: Error refreshing data: $e');
      throw e;
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
      final transactionWithId = TransactionModel(
        id: transactionRef.id,
        type: transaction.type,
        amount: transaction.amount,
        date: transaction.date,
        description: transaction.description,
        category: transaction.category,
        categoryId: transaction.categoryId,
        icon: transaction.icon,
      );

      // Add to Firestore
      await transactionRef.set(transactionWithId.toFirestore());

      // Update balance
      await updateBalance(userId,
          transaction.amount.abs(),
          transaction.type == 'expense');

      // Refresh local data
      await refreshData(userId);

      // Track the added transaction
      _recentlyAddedTransactions.add(transactionRef.id);

      return transactionRef.id;
    } catch (e) {
      debugPrint('DataService: Error adding transaction: $e');
      throw e;
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

      // Update the transaction in Firestore first
      await transactionRef.update(newTransaction.toFirestore());

      if (oldTransaction.type != newTransaction.type) {
        // If the transaction type changed (income <-> expense)
        // First reverse the old transaction effect
        await updateBalance(userId,
            oldTransaction.amount.abs(),
            oldTransaction.type != 'expense');

        // Then apply the new transaction effect
        await updateBalance(userId,
            newTransaction.amount.abs(),
            newTransaction.type == 'expense');
      } else {
        // Same transaction type, calculate the balance impact
        double amountDifference = 0.0;
        bool addToBalance = false;
        
        if (oldTransaction.type == 'expense') {
          // For expenses, lower expense means add to balance, higher expense means subtract
          // If oldAmount=-100, newAmount=-90, diff=10, add to balance
          // If oldAmount=-90, newAmount=-100, diff=-10, subtract from balance
          amountDifference = oldTransaction.amount.abs() - newTransaction.amount.abs();
          addToBalance = amountDifference > 0; // If old expense was greater, add the difference to balance
        } else {
          // For income, higher income means add to balance, lower income means subtract
          // If oldAmount=100, newAmount=90, diff=-10, subtract from balance
          // If oldAmount=90, newAmount=100, diff=10, add to balance
          amountDifference = newTransaction.amount - oldTransaction.amount;
          addToBalance = amountDifference > 0; // If new income is greater, add the difference to balance
        }
        
        if (amountDifference != 0) {
          await updateBalance(userId, amountDifference.abs(), !addToBalance);
        }      }

      // Refresh local data
      await refreshData(userId);

      // Track the modified transaction
      _recentlyModifiedTransactions.add(newTransaction.id);
    } catch (e) {
      debugPrint('DataService: Error updating transaction: $e');
      throw e;
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
        debugPrint('DataService: Transaction with ID: ${transaction.id} not found when trying to delete');
        return;
      }

      // Delete the transaction
      await transactionRef.delete();

      // Adjust balance (reverse the transaction effect)
      if (transaction.type == 'expense') {
        // For expense transactions, add the amount back
        await updateBalance(userId, transaction.amount.abs(), false);
      } else {
        // For income transactions, subtract the amount
        await updateBalance(userId, transaction.amount, true);
      }

      // Refresh local data
      await refreshData(userId);

      // Track the deleted transaction
      _recentlyDeletedTransactions.add(transaction.id);
    } catch (e) {
      debugPrint('DataService: Error deleting transaction: $e');
      throw e;
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
    
      double calculatedBalance = 0.0;
    
      // Calculate balance from transactions
      for (var doc in snapshot.docs) {
        final transaction = TransactionModel.fromFirestore(doc);
        if (transaction.type == 'income') {
          calculatedBalance += transaction.amount;
        } else if (transaction.type == 'expense') {
          calculatedBalance -= transaction.amount;
        }
      }
    
      // Update the balance in Firestore
      await _firestore.collection('users').doc(userId).update({
        'balance': calculatedBalance
      });
    
      debugPrint('DataService: Recalculated balance: $calculatedBalance');
      
      // Refresh local data
      await refreshData(userId);
    } catch (e) {
      debugPrint('DataService: Error recalculating balance: $e');
      throw e;
    }
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
