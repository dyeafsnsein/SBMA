import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/transaction_model.dart';

class TransactionController extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpenses = 0.0;

  List<TransactionModel> get transactions => _transactions;
  double get totalBalance => _totalBalance;
  double get totalIncome => _totalIncome;
  double get totalExpenses => _totalExpenses;

  TransactionController() {
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final transactionsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .orderBy('timestamp', descending: true)
            .get();

        _transactions = transactionsSnapshot.docs.map((doc) {
          final data = doc.data();
          return TransactionModel(
            type: data['type'] ?? 'expense',
            amount: double.parse(data['amount'].toString()),
            date: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
            description: data['description'] ?? '',
            category: data['category'] ?? '',
            icon: data['icon'] ?? 'lib/assets/Transaction.png',
          );
        }).toList();

        _calculateTotals();
        notifyListeners();
      } catch (e) {
        // Error handling
      }
    }
  }

  void _calculateTotals() {
    _totalIncome = _transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (total, t) => total + t.amount);
    
    _totalExpenses = _transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (total, t) => total + t.amount.abs());
    
    _totalBalance = _totalIncome - _totalExpenses;
  }

  Future<void> addExpense(Map<String, String> expenseData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final amount = double.parse(expenseData['amount'] ?? '0');
        final transaction = {
          'type': 'expense',
          'amount': -amount, // Store as negative for expenses
          'timestamp': Timestamp.now(),
          'description': expenseData['description'] ?? '',
          'category': expenseData['category'] ?? '',
          'icon': expenseData['icon'] ?? 'lib/assets/Transaction.png',
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .add(transaction);

        await _fetchTransactions();
      } catch (e) {
        // Error handling
      }
    }
  }

  Future<void> addIncome(Map<String, String> incomeData) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final amount = double.parse(incomeData['amount'] ?? '0');
        final transaction = {
          'type': 'income',
          'amount': amount,
          'timestamp': Timestamp.now(),
          'description': incomeData['description'] ?? '',
          'category': 'Income',
          'icon': 'lib/assets/Salary.png',
        };

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('transactions')
            .add(transaction);

        await _fetchTransactions();
      } catch (e) {
        // Error handling
      }
    }
  }
}