import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class DataService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _balanceSubscription;
  StreamSubscription<QuerySnapshot>? _transactionSubscription;
  double _totalBalance = 0.0;
  double _totalExpense = 0.0;
  Map<String, double> _categoryBreakdown = {};
  final Map<String, String> _categoryIcons = {};
  bool _isDataLoaded = false;

  double get totalBalance => _totalBalance;
  double get totalExpense => _totalExpense;
  Map<String, double> get categoryBreakdown =>
      Map.unmodifiable(_categoryBreakdown);
  Map<String, String> get categoryIcons => Map.unmodifiable(_categoryIcons);
  bool get isDataLoaded => _isDataLoaded;

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
        .snapshots()
        .listen((snapshot) {
      _loadTransactionsFromSnapshot(snapshot);
    }, onError: (e) {
      debugPrint('DataService: Error listening to transactions: $e');
      _totalExpense = 0.0;
      _categoryBreakdown.clear();
      notifyListeners();
    });
  }

  void _loadTransactionsFromSnapshot(QuerySnapshot snapshot) {
    _totalExpense = 0.0;
    _categoryBreakdown.clear();
    debugPrint('DataService: Processing ${snapshot.docs.length} transactions');
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      debugPrint('DataService: Transaction doc: $data');
      final amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
      final category = data['category'] as String? ?? 'Uncategorized';
      final isExpense = data['isExpense'] as bool? ?? false;
      final type = data['type'] as String?;
      if (isExpense || type == 'expense') {
        _totalExpense += amount;
        _categoryBreakdown[category] =
            (_categoryBreakdown[category] ?? 0.0) + amount;
      }
    }
    debugPrint(
        'DataService: Loaded ${snapshot.docs.length} transactions: totalExpense=$_totalExpense, categories=$_categoryBreakdown');
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
          .where('isExpense', isEqualTo: true)
          .get();
      debugPrint(
          'DataService: Filtered query found ${snapshot.docs.length} transactions');
      if (snapshot.docs.isEmpty) {
        debugPrint(
            'DataService: No transactions with isExpense=true, trying all transactions');
        snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .get();
      }
      _loadTransactionsFromSnapshot(snapshot);
    } catch (e) {
      debugPrint('DataService: Error reloading transactions: $e');
      _totalExpense = 0.0;
      _categoryBreakdown.clear();
      notifyListeners();
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

  @override
  void dispose() {
    _balanceSubscription?.cancel();
    _transactionSubscription?.cancel();
    super.dispose();
  }
}
