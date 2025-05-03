import 'package:flutter/foundation.dart';
import 'package:test_app/Models/savings_goal.dart';
import '../Models/analysis_model.dart';
import '../Services/data_service.dart';
import '../Controllers/savings_controller.dart';
import '../Services/ai_service.dart';
import '../Services/notification_service.dart';

class AnalysisController extends ChangeNotifier {
  final AnalysisModel _model;
  final DataService _dataService;
  final SavingsController _savingsController;
  final AiService _aiService;
  final NotificationService _notificationService;
  bool _isLoading = false;
  String? _errorMessage;
  List<String> _periods = ['Daily', 'Weekly', 'Monthly'];
  int _selectedPeriodIndex = 2;
  Map<String, Map<String, List>> _periodData = {};
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  Map<String, double> _categoryBreakdown = {};
  List<SavingsGoal> _savingsGoals = [];
  bool _isDataLoaded = false; // Track data loading status

  AnalysisController(
    this._model,
    this._dataService,
    this._savingsController,
    this._aiService,
    this._notificationService,
  ) {
    debugPrint('AnalysisController: Constructor called');
    _initializePeriodData();
    _loadData();
  }

  void _initializePeriodData() {
    debugPrint('AnalysisController: Initializing period data');
    for (var period in _periods) {
      _periodData[period] = {
        'expenses': <double>[],
        'income': <double>[],
        'labels': <String>[],
      };
    }
  }

  Future<void> _loadData() async {
    debugPrint('AnalysisController: Starting _loadData');
    _isLoading = true;
    notifyListeners();
    try {
      debugPrint('AnalysisController: Simulating data loading');
      await Future.delayed(const Duration(seconds: 1));
      for (var period in _periods) {
        _periodData[period] = {
          'expenses': [100.0, 200.0, 150.0],
          'income': [300.0, 400.0, 350.0],
          'labels': ['Jan', 'Feb', 'Mar'],
        };
      }
      _totalIncome = 1050.0;
      _totalExpense = 450.0;
      _categoryBreakdown = {
        'Food': 150.0,
        'Transport': 100.0,
        'Entertainment': 200.0,
      };
      _savingsGoals = _savingsController.savingsGoals;
      _isDataLoaded = true;
      debugPrint(
          'AnalysisController: Data loaded successfully: income=$_totalIncome, expenses=$_totalExpense, categories=$_categoryBreakdown');
    } catch (e, stackTrace) {
      _errorMessage = 'Failed to load data: $e';
      debugPrint('AnalysisController: Error loading data: $e\n$stackTrace');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint(
          'AnalysisController: _loadData completed, isLoading=$_isLoading');
    }
  }

  double get totalBalance => _dataService.totalBalance;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<String> get periods => _periods;
  int get selectedPeriodIndex => _selectedPeriodIndex;
  Map<String, Map<String, List>> get periodData => _periodData;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  Map<String, double> get categoryBreakdown => _categoryBreakdown;
  List<SavingsGoal> get savingsGoals => _savingsGoals;

  void onPeriodChanged(int index) {
    debugPrint('AnalysisController: Period changed to index $index');
    _selectedPeriodIndex = index;
    notifyListeners();
  }

  void retryLoading() {
    debugPrint('AnalysisController: Retrying data load');
    _errorMessage = null;
    _loadData();
  }

  Future<List<String>> generateBudgetTips() async {
    debugPrint('AnalysisController: Starting generateBudgetTips');
    debugPrint(
        'AnalysisController: Input data: income=$_totalIncome, expenses=$_totalExpense, categories=$_categoryBreakdown');
    try {
      if (!_isDataLoaded) {
        debugPrint(
            'AnalysisController: Data not loaded yet, calling _loadData');
        await _loadData();
      }
      if (_totalIncome <= 0 ||
          _totalExpense <= 0 ||
          _categoryBreakdown.isEmpty) {
        debugPrint('AnalysisController: Invalid input data for AI');
        return ['No tips generated due to invalid data.'];
      }
      final tips = await _aiService.generateBudgetTips(
        income: _totalIncome,
        expenses: _totalExpense,
        categories: _categoryBreakdown,
      );
      debugPrint('AnalysisController: Generated tips: $tips');
      if (tips.isEmpty) {
        debugPrint('AnalysisController: AI returned empty tips');
      }
      return tips;
    } catch (e, stackTrace) {
      debugPrint(
          'AnalysisController: Error generating budget tips: $e\n$stackTrace');
      return ['Error generating tips: $e'];
    }
  }
}
