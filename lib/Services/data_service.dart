import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';

class DataService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot>? _balanceSubscription;
  double _totalBalance = 0.0;
  final Map<String, String> _categoryIcons = {};

  double get totalBalance => _totalBalance;
  Map<String, String> get categoryIcons => Map.unmodifiable(_categoryIcons);
  DataService() {
    _setupAuthListener();
    
    // Immediately fetch data if user is already logged in
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
    _balanceSubscription = null;
    _totalBalance = 0.0;
    _categoryIcons.clear();
  }
  void _setupListeners(String userId) {
    _balanceSubscription?.cancel();
    _balanceSubscription = _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .listen((userDoc) {
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        _totalBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;
        notifyListeners(); // Add this to notify controllers when balance updates
      }
    }, onError: (e) {
      debugPrint('Error listening to user balance: $e');
    });
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
            'Invalid category data for doc ${doc.id}: label=$label, icon=$icon');
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
  void dispose() {
    _balanceSubscription?.cancel();
    super.dispose();
  }
}
