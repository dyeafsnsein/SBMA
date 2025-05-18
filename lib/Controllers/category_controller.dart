import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Models/category_model.dart';

class CategoryController extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  StreamSubscription<QuerySnapshot>? _categorySubscription;  // Lists to manage category types
  static const List<String> _incomeCategoryLabels = ['Income', 'Salary'];
  static const List<String> _reservedCategoryLabels = ['More', 'Income', 'Salary'];
  static const List<String> _defaultExpenseCategories = [
    'Food', 'Transport', 'Rent', 'Entertainment', 'Medicine', 'Groceries'
  ];

  CategoryController() {
    debugPrint('CategoryController: Constructor called');
    _setupAuthListener();
  }
  List<CategoryModel> get categories => _categories;

  // Return only expense categories (exclude income and reserved categories)
  List<CategoryModel> get expenseCategories => _categories
      .where((category) => 
          !_incomeCategoryLabels.contains(category.label) && 
          !_reservedCategoryLabels.contains(category.label))
      .toList();

  // Return only income categories
  List<CategoryModel> get incomeCategories => _categories
      .where((category) => _incomeCategoryLabels.contains(category.label))
      .toList();

  void _setupAuthListener() {
    debugPrint('CategoryController: Setting up auth listener');
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        debugPrint('CategoryController: No user, clearing state');
        _clearState();
      } else {
        debugPrint('CategoryController: User logged in: ${user.uid}');
        initializeCategories(user.uid).then((_) {
          _setupListeners(user.uid);
        });
      }
    });
  }

  void _clearState() {
    debugPrint('CategoryController: Clearing state');
    _categorySubscription?.cancel();
    _categorySubscription = null;
    _categories = [];
    notifyListeners();
  }

  void _setupListeners(String userId) {
    debugPrint(
        'CategoryController: Setting up category listener for user: $userId');
    _categorySubscription?.cancel(); // Prevent duplicate listeners
    _categorySubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots()
        .listen((snapshot) {
      debugPrint(
          'CategoryController: Received category snapshot: ${snapshot.docs.length} docs');
      _categories =
          snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
      notifyListeners();
    }, onError: (e, stackTrace) {
      debugPrint(
          'CategoryController: Error listening to categories: $e\n$stackTrace');
    });
  }
  Future<void> initializeCategories(String userId) async {
    debugPrint('CategoryController: Initializing categories for user: $userId');
    try {
      final categoriesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('categories');

      // Check if categories already exist
      final snapshot = await categoriesRef.get();
      if (snapshot.docs.isNotEmpty) {
        debugPrint(
            'CategoryController: Categories already exist, skipping seeding');
        return;
      }

      // Initialize essential categories
      final batch = FirebaseFirestore.instance.batch();
      
      // Add expense categories
      for (var categoryLabel in _defaultExpenseCategories) {
        final docRef = categoriesRef.doc();
        batch.set(docRef, {
          'label': categoryLabel,
          'icon': 'lib/assets/$categoryLabel.png'
        });
      }
      
      // Add just one income category
      final incomeDocRef = categoriesRef.doc();
      batch.set(incomeDocRef, {
        'label': 'Income',
        'icon': 'lib/assets/Income.png'
      });
      
      await batch.commit();
      debugPrint('CategoryController: Default categories initialized');
    } catch (e, stackTrace) {
      debugPrint(
          'CategoryController: Error initializing categories: $e\n$stackTrace');
      throw Exception('Failed to initialize categories: $e');
    }
  }

  Future<String> getIconForCategory(String category) async {
    debugPrint('CategoryController: Querying icon for category: $category');
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('CategoryController: No user, returning fallback icon');
      return 'lib/assets/Transaction.png';
    }

    // Check cached categories first
    final cachedCategory = _categories.firstWhere(
      (cat) => cat.label == category,
      orElse: () =>
          CategoryModel(id: '', label: '', icon: 'lib/assets/Transaction.png'),
    );
    if (cachedCategory.label.isNotEmpty) {
      debugPrint(
          'CategoryController: Found cached icon for $category: ${cachedCategory.icon}');
      return cachedCategory.icon;
    }

    // Query Firestore as fallback
    try {
      final categoryDocs = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .where('label', isEqualTo: category)
          .limit(1)
          .get();

      if (categoryDocs.docs.isNotEmpty) {
        final data = categoryDocs.docs.first.data();
        final icon = data['icon'] as String? ?? 'lib/assets/Transaction.png';
        debugPrint('CategoryController: Found icon for $category: $icon');
        return icon;
      }
      debugPrint(
          'CategoryController: No icon found for $category, using fallback');
      return 'lib/assets/Transaction.png';
    } catch (e, stackTrace) {
      debugPrint(
          'CategoryController: Error fetching icon for $category: $e\n$stackTrace');
      return 'lib/assets/Transaction.png';
    }
  }

  Future<void> addCategory(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('CategoryController: No user, cannot add category');
      return;
    }

    // Prevent adding reserved categories
    if (_incomeCategoryLabels.contains(name) ||
        _reservedCategoryLabels.contains(name)) {
      debugPrint('CategoryController: Cannot add reserved category: $name');
      return;
    }

    debugPrint('CategoryController: Adding category: $name');
    try {
      final newCategory = CategoryModel(
        id: '', // ID will be auto-generated by Firestore
        label: name,
        icon: 'lib/assets/star.png', // Default icon for new categories
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .add(newCategory.toFirestore());
      debugPrint('CategoryController: Category $name added successfully');
    } catch (e, stackTrace) {
      debugPrint(
          'CategoryController: Error adding category $name: $e\n$stackTrace');
      throw Exception('Failed to add category: $e');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('CategoryController: No user, cannot delete category');
      return;
    }

    debugPrint('CategoryController: Deleting category: $categoryId');
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(categoryId)
          .delete();
      debugPrint(
          'CategoryController: Category $categoryId deleted successfully');
    } catch (e, stackTrace) {
      debugPrint(
          'CategoryController: Error deleting category $categoryId: $e\n$stackTrace');
      throw Exception('Failed to delete category: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('CategoryController: Disposing');
    _categorySubscription?.cancel();
    super.dispose();
  }
}
