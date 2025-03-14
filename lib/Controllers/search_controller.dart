import 'package:flutter/material.dart';
import '../Models/search_model.dart';

class SearchController extends ChangeNotifier {
  final SearchModel model;

  SearchController(this.model);

  DateTime get selectedDate => model.selectedDate;
  String? get selectedCategory => model.selectedCategory;
  bool get isIncome => model.isIncome;
  bool get isExpense => model.isExpense;
  List<String> get categories => model.categories;

  void setSelectedDate(DateTime date) {
    model.selectedDate = date;
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    model.selectedCategory = category;
    notifyListeners();
  }

  void toggleIncome(bool value) {
    model.isIncome = value;
    model.isExpense = !value;
    notifyListeners();
  }

  void toggleExpense(bool value) {
    model.isExpense = value;
    model.isIncome = !value;
    notifyListeners();
  }
}