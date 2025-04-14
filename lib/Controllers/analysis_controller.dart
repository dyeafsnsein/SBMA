import 'package:flutter/material.dart';
import '../Models/analysis_model.dart';
import '../Models/transaction_model.dart';
import 'home_controller.dart';

class AnalysisController extends ChangeNotifier {
  final AnalysisModel model;
  final HomeController homeController;
  double totalIncome = 0.0;
  double totalExpense = 0.0;

  AnalysisController(this.model, this.homeController) {
    _computePeriodData();
  }

  List<String> get periods => model.periods;
  int get selectedPeriodIndex => model.selectedPeriodIndex;
  Map<String, Map<String, dynamic>> get periodData => model.periodData;
  List<Map<String, dynamic>> get targets => model.targets;

  void onPeriodChanged(int index) {
    if (model.selectedPeriodIndex == index) return;
    model.selectedPeriodIndex = index;
    _computePeriodData();
    notifyListeners();
  }

  void _computePeriodData() {
    final now = DateTime.now();
    final transactions = homeController.transactions;

    model.periodData = {
      'Daily': {'expenses': <double>[], 'income': <double>[], 'labels': <String>[]},
      'Weekly': {'expenses': <double>[], 'income': <double>[], 'labels': <String>[]},
      'Monthly': {'expenses': <double>[], 'income': <double>[], 'labels': <String>[]},
      'Year': {'expenses': <double>[], 'income': <double>[], 'labels': <String>[]},
    };

    totalIncome = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (sum, t) => sum + t.amount);
    totalExpense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (sum, t) => sum + t.amount.abs());

    // Daily: Last 7 days
    if (selectedPeriodIndex == 0) {
      List<double> expenses = List.filled(7, 0.0);
      List<double> income = List.filled(7, 0.0);
      List<String> labels = [];
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        labels.add(_getDayLabel(date));
        for (final transaction in transactions) {
          if (_isSameDay(transaction.date, date)) {
            if (transaction.type == 'expense') {
              expenses[6 - i] += transaction.amount.abs();
            } else if (transaction.type == 'income') {
              income[6 - i] += transaction.amount;
            }
          }
        }
      }
      model.periodData['Daily']!['expenses'] = expenses;
      model.periodData['Daily']!['income'] = income;
      model.periodData['Daily']!['labels'] = labels;
    }

    // Weekly: Last 4 weeks (Monday to Sunday), newest to oldest
    else if (selectedPeriodIndex == 1) {
      List<double> expenses = List.filled(4, 0.0);
      List<double> income = List.filled(4, 0.0);
      List<String> labels = [];

      final today = now;
      final daysSinceMonday = today.weekday - 1;
      final startOfCurrentWeek = today.subtract(Duration(days: daysSinceMonday));

      for (int i = 0; i <= 3; i++) {
        final startOfWeek = startOfCurrentWeek.subtract(Duration(days: i * 7));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));

        final label = "${_getMonthLabel(startOfWeek.month)} ${startOfWeek.day}";
        labels.add(label);

        for (final transaction in transactions) {
          if (transaction.date.isAfter(startOfWeek) &&
              (transaction.date.isBefore(endOfWeek) || transaction.date.isAtSameMomentAs(endOfWeek))) {
            if (transaction.type == 'expense') {
              expenses[i] += transaction.amount.abs();
            } else if (transaction.type == 'income') {
              income[i] += transaction.amount;
            }
          }
        }
      }

      model.periodData['Weekly']!['expenses'] = expenses;
      model.periodData['Weekly']!['income'] = income;
      model.periodData['Weekly']!['labels'] = labels;
    }

    // Monthly: Last 12 months, newest to oldest
    else if (selectedPeriodIndex == 2) {
      List<double> expenses = List.filled(12, 0.0);
      List<double> income = List.filled(12, 0.0);
      List<String> labels = [];

      for (int i = 0; i <= 11; i++) {
        final monthsAgo = now.month - i;
        final year = now.year + (monthsAgo ~/ 12);
        final month = monthsAgo % 12 == 0 ? 12 : monthsAgo % 12;
        final adjustedYear = monthsAgo < 0 ? year - 1 : year;

        final monthStart = DateTime(adjustedYear, month, 1);
        final monthEnd = DateTime(adjustedYear, month + 1, 1).subtract(const Duration(days: 1));

        final label = _getMonthLabel(month); // Only the month name, e.g., "Apr"
        labels.add(label);

        for (final transaction in transactions) {
          if (transaction.date.isAfter(monthStart) &&
              (transaction.date.isBefore(monthEnd) || transaction.date.isAtSameMomentAs(monthEnd))) {
            if (transaction.type == 'expense') {
              expenses[i] += transaction.amount.abs();
            } else if (transaction.type == 'income') {
              income[i] += transaction.amount;
            }
          }
        }
      }

      model.periodData['Monthly']!['expenses'] = expenses;
      model.periodData['Monthly']!['income'] = income;
      model.periodData['Monthly']!['labels'] = labels;
    }

    // Yearly: Last 4 years, newest to oldest
    else if (selectedPeriodIndex == 3) {
      List<double> expenses = List.filled(4, 0.0);
      List<double> income = List.filled(4, 0.0);
      List<String> labels = [];
      for (int i = 0; i <= 3; i++) {
        final year = now.year - i;
        labels.add(year.toString());
        final yearStart = DateTime(year, 1, 1);
        final yearEnd = DateTime(year, 12, 31);
        for (final transaction in transactions) {
          if (transaction.date.isAfter(yearStart) &&
              (transaction.date.isBefore(yearEnd) || transaction.date.isAtSameMomentAs(yearEnd))) {
            if (transaction.type == 'expense') {
              expenses[i] += transaction.amount.abs();
            } else if (transaction.type == 'income') {
              income[i] += transaction.amount;
            }
          }
        }
      }
      model.periodData['Year']!['expenses'] = expenses;
      model.periodData['Year']!['income'] = income;
      model.periodData['Year']!['labels'] = labels;
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  String _getDayLabel(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }

  String _getMonthLabel(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}