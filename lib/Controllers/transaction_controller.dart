import 'package:flutter/material.dart';
import '../Models/transaction_model.dart';

class TransactionController extends ChangeNotifier {
  final TransactionModel model;

  TransactionController(this.model) {
    fetchDataFromBackend();
  }

  List<Map<String, String>> get transactions => model.transactions;
  double get totalBalance => model.totalBalance;
  double get totalIncome => model.totalIncome;
  double get totalExpense => model.totalExpense;
  DateTimeRange? get selectedDateRange => model.selectedDateRange;

  void fetchDataFromBackend() {
    model.transactions = [
      {
        'icon': 'lib/assets/Salary.png',
        'time': '18:27 - April 30',
        'category': 'Monthly',
        'amount': '4000.00',
        'title': 'Salary',
        'date': '2023-04-30',
      },
      {
        'icon': 'lib/assets/Pantry.png',
        'time': '17:00 - April 24',
        'category': 'Pantry',
        'amount': '-100.00',
        'title': 'Groceries',
        'date': '2023-04-24',
      },
      {
        'icon': 'lib/assets/Rent.png',
        'time': '8:30 - April 15',
        'category': 'Rent',
        'amount': '-674.40',
        'title': 'Rent',
        'date': '2023-04-15',
      },
      {
        'icon': 'lib/assets/Transport.png',
        'time': '7:30 - April 08',
        'category': 'Fuel',
        'amount': '-4.13',
        'title': 'Transport',
        'date': '2023-04-08',
      },
      {
        'icon': 'lib/assets/Food.png',
        'time': '19:30 - March 31',
        'category': 'Dinner',
        'amount': '-70.40',
        'title': 'Food',
        'date': '2023-03-31',
      },
    ];

    model.calculateTotals();
    notifyListeners();
  }

  void pickDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: const Color(0xFF202422),
            colorScheme: ColorScheme.light(
              primary: const Color(0xFF202422),
              secondary: const Color(0xFF0D4015),
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      model.selectedDateRange = picked;
      filterTransactionsByDate();
    }
  }

  void filterTransactionsByDate() {
    if (model.selectedDateRange != null) {
      DateTime start = model.selectedDateRange!.start;
      DateTime end = model.selectedDateRange!.end;

      model.transactions = model.transactions.where((transaction) {
        DateTime transactionDate = DateTime.parse(transaction['date']!);
        return transactionDate.isAfter(start) && transactionDate.isBefore(end);
      }).toList();

      model.calculateTotals();
      notifyListeners();
    }
  }
}