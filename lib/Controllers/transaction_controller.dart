import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Models/transaction_model.dart';

class TransactionController extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;
  DateTime? _selectedDate;
  final Map<String, String> _categoryIcons = {};

  StreamSubscription<DocumentSnapshot>? _balanceSubscription;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;

  List<TransactionModel> get transactions {
    if (_selectedDate == null) return _transactions;
    return _transactions.where((transaction) {
      return transaction.date.year == _selectedDate!.year &&
          transaction.date.month == _selectedDate!.month &&
          transaction.date.day == _selectedDate!.day;
    }).toList();
  }

  double get totalBalance => _totalBalance;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;

  TransactionController() {
    _setupAuthListener();
  }

  Future<void> _initializeCategories(String userId) async {
    final categoriesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories');

    final snapshot = await categoriesRef.get();
    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final defaultCategories = [
      {'label': 'Food', 'icon': 'lib/assets/Food.png'},
      {'label': 'Transport', 'icon': 'lib/assets/Transport.png'},
      {'label': 'Rent', 'icon': 'lib/assets/Rent.png'},
      {'label': 'Entertainment', 'icon': 'lib/assets/Entertainment.png'},
      {'label': 'Medicine', 'icon': 'lib/assets/Medicine.png'},
      {'label': 'Groceries', 'icon': 'lib/assets/Groceries.png'},
      {'label': 'More', 'icon': 'lib/assets/More.png'},
      {'label': 'Income', 'icon': 'lib/assets/Salary.png'},
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (var category in defaultCategories) {
      final docRef = categoriesRef.doc(category['label']);
      batch.set(docRef, category);
    }
    await batch.commit();
  }

  Future<void> _loadCategories(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories')
        .get();
    _categoryIcons.clear();
    for (var doc in snapshot.docs) {
      _categoryIcons[doc['label'] as String] = doc['icon'] as String;
    }
  }

  Future<String> _getIconForCategory(String userId, String category) async {
    if (_categoryIcons.isEmpty) {
      await _loadCategories(userId);
    }
    return _categoryIcons[category] ?? 'lib/assets/Transaction.png';
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        _initializeCategories(user.uid).then((_) {
          _loadCategories(user.uid).then((_) {
            _setupListeners();
          });
        });
      }
    });
  }

  void _clearState() {
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();
    _balanceSubscription = null;
    _transactionSubscription = null;

    _transactions = [];
    _totalBalance = 0.0;
    _totalIncome = 0.0;
    _totalExpenses = 0.0;
    _selectedDate = null;
    _categoryIcons.clear();

    notifyListeners();
  }

  void _setupListeners() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _clearState();
      return;
    }

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
        final icon = data['icon'] ?? await _getIconForCategory(user.uid, category);
        _transactions.add(TransactionModel(
          type: data['type'] ?? 'expense',
          amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
          date: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
      final amount = double.parse(expenseData['amount'].toString());
      final category = expenseData['category'] ?? 'Unknown';
      final icon = expenseData['icon'] ?? await _getIconForCategory(user.uid, category);
      final date = expenseData['date'] as DateTime? ?? DateTime.now();
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

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      final currentBalance = (userDoc.data()?['balance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance - amount;
      batch.update(userRef, {'balance': newBalance});

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
      final amount = double.parse(incomeData['amount'].toString());
      final category = 'Income';
      final icon = await _getIconForCategory(user.uid, category);
      final date = incomeData['date'] as DateTime? ?? DateTime.now();
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

      final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      final currentBalance = (userDoc.data()?['balance'] as num?)?.toDouble() ?? 0.0;
      final newBalance = currentBalance + amount;
      batch.update(userRef, {'balance': newBalance});

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
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();
    super.dispose();
  }
}