import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Models/home_model.dart';
import '../Models/transaction_model.dart';

class HomeController extends ChangeNotifier {
  final HomeModel model = HomeModel();

  double _totalBalance = 0.0;
  double _totalExpense = 0.0;
  double _revenueLastWeek = 0.0;
  double _foodLastWeek = 0.0; // We'll replace this with dynamic category spending
  String _topCategoryLastWeek = ''; // New: Store the top category
  double _topCategoryAmountLastWeek = 0.0; // New: Store the amount for the top category
  String _topCategoryIconLastWeek = ''; // New: Store the icon for the top category
  List<TransactionModel> _allTransactions = [];
  List<TransactionModel> _filteredTransactions = [];
  int _selectedPeriodIndex = 2;
  final Map<String, String> _categoryIcons = {};

  StreamSubscription<DocumentSnapshot>? _balanceSubscription;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;

  HomeController() {
    _setupAuthListener();
  }

  // Updated getters
  double get totalBalance => _totalBalance;
  double get totalExpense => _totalExpense;
  double get revenueLastWeek => _revenueLastWeek;
  String get topCategoryLastWeek => _topCategoryLastWeek; // New getter
  double get topCategoryAmountLastWeek => _topCategoryAmountLastWeek; // New getter
  String get topCategoryIconLastWeek => _topCategoryIconLastWeek; // New getter
  int get selectedPeriodIndex => _selectedPeriodIndex;
  List<String> get periods => model.periods;
  List<TransactionModel> get transactions => _filteredTransactions;

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

    _totalBalance = 0.0;
    _totalExpense = 0.0;
    _revenueLastWeek = 0.0;
    _topCategoryLastWeek = '';
    _topCategoryAmountLastWeek = 0.0;
    _topCategoryIconLastWeek = '';
    _allTransactions = [];
    _filteredTransactions = [];
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
        .listen((userDoc) async {
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _totalBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;

        await _calculateTotalExpense();
        _filterTransactions();
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
      _allTransactions = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final category = data['category'] ?? 'Unknown';
        final icon = data['icon'] ??
            await _getIconForCategory(user.uid, category);
        _allTransactions.add(TransactionModel(
          type: data['type'] ?? 'expense',
          amount: double.parse(data['amount'].toString()),
          date: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          description: data['description'] ?? '',
          category: category,
          icon: icon,
        ));
      }

      _calculateLastWeekMetrics();
      _calculateTotalExpense();
      _filterTransactions();
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error listening to transactions: $e');
    });
  }

  Future<void> _calculateTotalExpense() async {
    _totalExpense = _allTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (total, t) => total + t.amount.abs());
  }

  void _calculateLastWeekMetrics() {
    final now = DateTime.now();
    final lastWeekStart = now.subtract(const Duration(days: 7));
    final lastWeekTransactions = _allTransactions.where((transaction) {
      return transaction.date.isAfter(lastWeekStart) ||
          transaction.date.isAtSameMomentAs(lastWeekStart);
    }).toList();

    // Calculate revenue last week
    _revenueLastWeek = lastWeekTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (total, t) => total + t.amount);

    // Calculate the top spending category last week
    final categorySpending = <String, double>{};
    final categoryIcons = <String, String>{};

    for (var transaction in lastWeekTransactions) {
      if (transaction.type == 'expense') {
        final category = transaction.category;
        categorySpending[category] =
            (categorySpending[category] ?? 0) + transaction.amount.abs();
        categoryIcons[category] = transaction.icon;
      }
    }

    if (categorySpending.isNotEmpty) {
      final topEntry = categorySpending.entries.reduce((a, b) =>
          a.value > b.value ? a : b);
      _topCategoryLastWeek = topEntry.key;
      _topCategoryAmountLastWeek = topEntry.value;
      _topCategoryIconLastWeek = categoryIcons[topEntry.key] ?? 'lib/assets/Transaction.png';
    } else {
      _topCategoryLastWeek = 'None';
      _topCategoryAmountLastWeek = 0.0;
      _topCategoryIconLastWeek = 'lib/assets/Transaction.png';
    }
  }

  void _filterTransactions() {
    final now = DateTime.now();
    DateTime startDate;
    switch (_selectedPeriodIndex) {
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

    _filteredTransactions = _allTransactions.where((transaction) {
      return transaction.date.isAfter(startDate) ||
          transaction.date.isAtSameMomentAs(startDate);
    }).toList();
  }

  void onPeriodTapped(int index) {
    _selectedPeriodIndex = index;
    _filterTransactions();
    notifyListeners();
  }

  Future<void> setBalance(double balance) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'balance': balance}, SetOptions(merge: true));
      _totalBalance = balance;
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting balance: $e');
    }
  }

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();
    super.dispose();
  }
}