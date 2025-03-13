import 'package:flutter/material.dart';
import '../Models/home_model.dart';

class HomeController extends ChangeNotifier {
  final HomeModel model;

  HomeController(this.model);

  int get selectedPeriodIndex => model.selectedPeriodIndex;
  List<String> get periods => model.periods;
  List<Map<String, String>> get transactions => model.transactions;

  void onPeriodTapped(int index) {
    model.selectedPeriodIndex = index;
    notifyListeners();
  }
}