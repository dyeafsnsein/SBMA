import 'package:flutter/material.dart';

class TransactionModel {
  List<Map<String, String>> transactions = [];
  double totalBalance = 0.0;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  DateTimeRange? selectedDateRange;

  void calculateTotals() {
    totalIncome = transactions
        .where((transaction) => double.parse(transaction['amount']!) > 0)
        .fold(
          0.0,
          (sum, transaction) => sum + double.parse(transaction['amount']!),
        );

    totalExpense = transactions
        .where((transaction) => double.parse(transaction['amount']!) < 0)
        .fold(
          0.0,
          (sum, transaction) => sum + double.parse(transaction['amount']!),
        );

    totalBalance = totalIncome + totalExpense;
  }
}