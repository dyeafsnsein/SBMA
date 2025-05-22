import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Models/category_model.dart';

class CategoryController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CategoryModel> _categories = [];
  StreamSubscription<QuerySnapshot>? _categorySubscription;
  
  static const List<String> _reservedCategoryLabels = ['Income', 'income','Salary','salary', ];
  static const List<String> _defaultExpenseCategories = ['Food', 'Transport', 'Rent','Entertainment', 'Medicine','Groceries'];

  CategoryController() {
    _setupAuthListener();
  }

  
  List<CategoryModel> get expenseCategories => _categories
      .where((category) => category.isExpense && !_reservedCategoryLabels.contains(category.label))
      .toList();

  List<CategoryModel> get incomeCategories => _categories
      .where((category) => category.isIncome)
      .toList();

  CategoryModel? findCategoryByLabel(String label) {
    final matchingCategories = _categories
        .where((category) => category.label == label)
        .toList();
    
    return matchingCategories.isNotEmpty ? matchingCategories.first : null;
  }

  CategoryModel findCategoryByLabelOrDefault(String label) {
    final category = findCategoryByLabel(label);
    return category ?? CategoryModel.expense(
      id: 'unknown',
      label: 'Unknown',
      icon: 'lib/assets/Transaction.png',
    );
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        initializeCategories(user.uid)
          .then((_) => _setupCategoryListener(user.uid))
          .catchError((_) {});
      }
    });
  }

  void _clearState() {
    _categorySubscription?.cancel();
    _categorySubscription = null;
    _categories = [];
    notifyListeners();
  }

  void _setupCategoryListener(String userId) {
    _categorySubscription?.cancel();
    
    _categorySubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots()
        .listen(
          (snapshot) {
            _categories = snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
            notifyListeners();
          },
          onError: (_, __) {}
        );
  }

  Future<void> initializeCategories(String userId) async {
    try {
      final categoriesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('categories');

      final snapshot = await categoriesRef.get();
      if (snapshot.docs.isNotEmpty) return;
      
      final batch = _firestore.batch();
      
      for (var categoryLabel in _defaultExpenseCategories) {
        final docRef = categoriesRef.doc();
        batch.set(docRef, {
          'label': categoryLabel,
          'icon': 'lib/assets/$categoryLabel.png',
          'type': CategoryModel.TYPE_EXPENSE
        });
      }
      
      final incomeDocRef = categoriesRef.doc();
      batch.set(incomeDocRef, {
        'label': 'Income',
        'icon': 'lib/assets/Income.png',
        'type': CategoryModel.TYPE_INCOME
      });
      
      final salaryDocRef = categoriesRef.doc();
      batch.set(salaryDocRef, {
        'label': 'Salary',
        'icon': 'lib/assets/Salary.png',
        'type': CategoryModel.TYPE_INCOME
      });
      
      await batch.commit();
      
      final newSnapshot = await categoriesRef.get();
      _categories = newSnapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> addCategory(String name, {String type = CategoryModel.TYPE_EXPENSE}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    if (_reservedCategoryLabels.contains(name)) return;
    if (_categories.any((cat) => cat.label == name)) return;

    try {
      CategoryModel newCategory = type == CategoryModel.TYPE_INCOME
          ? CategoryModel.income(
              id: '',
              label: name,
              icon: 'lib/assets/Income.png',
            )
          : CategoryModel.expense(
              id: '',
              label: name,
              icon: 'lib/assets/Transaction.png',
            );

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .add(newCategory.toFirestore());
    } catch (_) {}
  }

  Future<void> deleteCategory(String categoryId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    
    final categoryToDelete = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryModel(id: '', label: '', icon: ''),
    );
    
    if (categoryToDelete.id.isEmpty) return;
    if (_reservedCategoryLabels.contains(categoryToDelete.label)) return;

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(categoryId)
          .delete();
    } catch (_) {}
  }
  
  @override
  void dispose() {
    _categorySubscription?.cancel();
    super.dispose();
  }
}