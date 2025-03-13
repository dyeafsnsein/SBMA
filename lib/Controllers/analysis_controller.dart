import 'package:flutter/material.dart';
import '../Models/analysis_model.dart';

class AnalysisController extends ChangeNotifier {
  final AnalysisModel model;

  AnalysisController(this.model);

  List<String> get periods => model.periods;
  int get selectedPeriodIndex => model.selectedPeriodIndex;
  Map<String, Map<String, dynamic>> get periodData => model.periodData;
  List<Map<String, dynamic>> get targets => model.targets;

  void onPeriodChanged(int index) {
    if (model.selectedPeriodIndex == index) return;
    model.selectedPeriodIndex = index;
    notifyListeners();
  }
}