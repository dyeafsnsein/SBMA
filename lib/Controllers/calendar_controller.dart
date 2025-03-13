import 'package:flutter/material.dart';
import '../Models/calendar_model.dart';

class CalendarController extends ChangeNotifier {
  final CalendarModel model;

  CalendarController(this.model);

  List<String> get months => model.months;
  List<String> get years => model.years;
  String get selectedMonth => model.selectedMonth;
  String get selectedYear => model.selectedYear;
  int get selectedDay => model.selectedDay;
  bool get showSpends => model.showSpends;
  List<Map<String, String>> get transactions => model.transactions;
  List<Map<String, dynamic>> get categories => model.categories;

  void setSelectedMonth(String month) {
    model.selectedMonth = month;
    notifyListeners();
  }

  void setSelectedYear(String year) {
    model.selectedYear = year;
    notifyListeners();
  }

  void setSelectedDay(int day) {
    model.selectedDay = day;
    notifyListeners();
  }

  void toggleShowSpends(bool showSpends) {
    model.showSpends = showSpends;
    notifyListeners();
  }
}