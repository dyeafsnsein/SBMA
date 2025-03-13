import 'package:flutter/material.dart';
import '../Models/quick_analysis_model.dart';

class QuickAnalysisController extends ChangeNotifier {
  final QuickAnalysisModel model;

  QuickAnalysisController(this.model);

  List<Map<String, String>> get transactions => model.transactions;
  List<double> get expenses => model.expenses;
  List<double> get income => model.income;
  List<String> get chartLabels => model.chartLabels;
}