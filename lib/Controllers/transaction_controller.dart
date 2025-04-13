import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/transaction_model.dart';

class TransactionController extends ChangeNotifier {
  TransactionModel _model;

  TransactionController(this._model);

  double get totalBalance => _model.totalBalance;
  double get totalIncome => _model.totalIncome;
  double get totalExpense => _model.totalExpense;
  List<Map<String, dynamic>> get transactions => _model.transactions;

  // Fetch data from Firestore
  Future<void> fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Fetch user balance
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      
      if (!userDoc.exists) {
        _model.totalBalance = 0.0;
        notifyListeners();
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      _model.totalBalance = (userData['balance'] as num?)?.toDouble() ?? 0.0;

      // Fetch transactions
      final transactionSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('transactions')
          .orderBy('timestamp', descending: true)
          .get();

      _model.transactions = transactionSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'category': data['category'] ?? 'Unknown',
          'amount': (data['amount'] as num?)?.toDouble() ?? 0.0,
          'timestamp': (data['timestamp'] as Timestamp?)?.toDate(),
        };
      }).toList();

      // For now, set income and expense to 0 (we'll calculate them later)
      _model.totalIncome = 0.0;
      _model.totalExpense = 0.0;

      notifyListeners();
    } catch (e) {
      // Handle errors silently for now, but you can add logging if needed
      print('Error fetching data: $e');
    }
  }

  // Placeholder for date range picker (to be implemented later if needed)
  Future<void> pickDateRange(BuildContext context) async {
    // For now, this is a placeholder
    print('Date range picker tapped');
  }
}