import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Models/transaction_model.dart';
import '../Services/data_service.dart';

class HomeController extends ChangeNotifier {
  final DataService _dataService;
  double _totalExpense = 0.0;
  double _revenueLastWeek = 0.0;
  String _topCategoryLastWeek = '';
  double _topCategoryAmountLastWeek = 0.0;
  String _topCategoryIconLastWeek = '';
  List<TransactionModel> _filteredTransactions = [];
  int _selectedPeriodIndex = 2;
  String? _errorMessage;

  HomeController(this._dataService) {
    _setupAuthListener();
  }
  // Getters
  double get totalBalance => _dataService.totalBalance;
  double get totalExpense => _totalExpense;
  double get revenueLastWeek => _revenueLastWeek;
  String get topCategoryLastWeek => _topCategoryLastWeek;
  double get topCategoryAmountLastWeek => _topCategoryAmountLastWeek;
  String get topCategoryIconLastWeek => _topCategoryIconLastWeek;
  int get selectedPeriodIndex => _selectedPeriodIndex;
  List<TransactionModel> get transactions => _filteredTransactions;
  String? get errorMessage => _errorMessage;

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        _setupDataListener();
      }
    });
  }
  
  void _clearState() {
    _totalExpense = 0.0;
    _revenueLastWeek = 0.0;
    _topCategoryLastWeek = '';
    _topCategoryAmountLastWeek = 0.0;
    _topCategoryIconLastWeek = '';
    _filteredTransactions = [];
    _errorMessage = null;
    notifyListeners();
  }
  
  void _setupDataListener() {
    _dataService.addListener(_onDataServiceChanged);
    _onDataServiceChanged();
  }
  
  void _onDataServiceChanged() {
    final metrics = _dataService.calculateLastWeekMetrics();
    _revenueLastWeek = metrics['revenueLastWeek'];
    _topCategoryLastWeek = metrics['topCategory'];
    _topCategoryAmountLastWeek = metrics['topAmount'];
    _topCategoryIconLastWeek = metrics['topIcon'];
    
    _totalExpense = _dataService.totalExpense;
    _filteredTransactions = _dataService.getFilteredTransactions(_selectedPeriodIndex);
    
    _errorMessage = null;
    notifyListeners();
  }
  
  Future<void> refreshData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;
    
    try {
      await _dataService.refreshData(userId);
      _onDataServiceChanged();
    } catch (e) {
      _errorMessage = 'Error refreshing data: $e';
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _dataService.removeListener(_onDataServiceChanged);
    super.dispose();
  }
}
