import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Models/category_model.dart';

class CategoryController extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<CategoryModel> _categories = [];
  StreamSubscription<QuerySnapshot>? _categorySubscription;
  
  // Constants for category management
  static const List<String> _reservedCategoryLabels = ['More', 'Income', 'Salary', 'Unknown'];
  static const List<String> _defaultExpenseCategories = [
    'Food', 'Transport', 'Rent', 'Entertainment', 'Medicine', 'Groceries'
  ];
  CategoryController() {
    _setupAuthListener();
  }
  List<CategoryModel> get categories => List.unmodifiable(_categories);
  // Return only expense categories (exclude income and reserved categories)
  List<CategoryModel> get expenseCategories => _categories
      .where((category) => category.isExpense && 
          !_reservedCategoryLabels.contains(category.label))
      .toList();

  // Return only income categories
  List<CategoryModel> get incomeCategories => _categories
      .where((category) => category.isIncome)
      .toList();

  /// Finds a category by its label
  CategoryModel? findCategoryByLabel(String label) {
    final matchingCategories = _categories
        .where((category) => category.label == label)
        .toList();
    
    return matchingCategories.isNotEmpty ? matchingCategories.first : null;
  }
  /// Gets the default income category or creates a fallback if none exists
  CategoryModel getIncomeCategoryOrDefault() {
    final incomeCategories = _categories
        .where((category) => category.isIncome && category.label == 'Income')
        .toList();
    
    if (incomeCategories.isNotEmpty) {
      return incomeCategories.first;
    } else {
      // Fallback if no Income category is found
      return CategoryModel.income(
        id: 'income',
        label: 'Income',
        icon: 'lib/assets/Income.png',
      );
    }
  }

  /// Gets a category by label or returns a default one if not found
  CategoryModel findCategoryByLabelOrDefault(String label) {
    final category = findCategoryByLabel(label);
    
    if (category != null) {
      return category;
    } else {
      // Fallback if no matching category is found
      return CategoryModel.expense(
        id: 'unknown',
        label: 'Unknown',
        icon: 'lib/assets/Transaction.png',
      );
    }
  }  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        debugPrint('User signed in, initializing categories...');
        // Force initialization of categories for the user
        initializeCategories(user.uid).then((_) {
          debugPrint('Categories initialized successfully');
          _setupCategoryListener(user.uid);
        }).catchError((e) {
          debugPrint('Error initializing categories: $e');
        });
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
    _categorySubscription?.cancel(); // Prevent duplicate listeners
    
    _categorySubscription = _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots()
        .listen((snapshot) {
      _categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
      
      // Check for and clean up duplicate categories
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cleanupDuplicateCategories(userId);
      });
      
      notifyListeners();
    }, onError: (e, stackTrace) {
      debugPrint('Error in category listener: $e');
      debugPrint('Stack trace: $stackTrace');
      // We don't notify here as we don't want to propagate errors to UI
    });
  }  // Helper method to clean up duplicate categories
  Future<void> _cleanupDuplicateCategories(String userId) async {
    try {
      // Create a map to track categories by label
      final Map<String, List<CategoryModel>> categoriesByLabel = {};
      
      // Group categories by label
      for (var category in _categories) {
        if (!categoriesByLabel.containsKey(category.label)) {
          categoriesByLabel[category.label] = [];
        }
        categoriesByLabel[category.label]!.add(category);
      }
      
      // Check for duplicates and remove them
      final batch = _firestore.batch();
      bool hasDuplicates = false;
      
      // For each label that has multiple categories, keep only the first one
      for (var entry in categoriesByLabel.entries) {
        if (entry.value.length > 1) {
          hasDuplicates = true;
          
          // Keep the first one, delete the rest
          for (int i = 1; i < entry.value.length; i++) {
            // Delete duplicate from Firestore
            batch.delete(
              _firestore
                  .collection('users')
                  .doc(userId)
                  .collection('categories')
                  .doc(entry.value[i].id)
            );
          }
        }
      }
      
      // If we have duplicates, commit the batch to delete them
      if (hasDuplicates) {
        await batch.commit();
      }
    } catch (e) {
      debugPrint('Error cleaning up duplicate categories: $e');
    }
  }  Future<void> initializeCategories(String userId) async {
    debugPrint('Starting category initialization for user: $userId');
    try {
      final categoriesRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('categories');

      // Check if categories already exist
      final snapshot = await categoriesRef.get();
      debugPrint('Found ${snapshot.docs.length} existing categories');
      
      if (snapshot.docs.isNotEmpty) {
        debugPrint('Categories already exist, skipping initialization');
        return;
      }

      debugPrint('Creating default categories for new user');
      
      // Initialize with a batch for better performance
      final batch = _firestore.batch();
      
      // Add expense categories
      for (var categoryLabel in _defaultExpenseCategories) {
        debugPrint('Adding expense category: $categoryLabel');
        final docRef = categoriesRef.doc();
        batch.set(docRef, {
          'label': categoryLabel,
          'icon': 'lib/assets/$categoryLabel.png',
          'type': CategoryModel.TYPE_EXPENSE
        });
      }
      
      // Add income category
      debugPrint('Adding income category: Income');
      final incomeDocRef = categoriesRef.doc();
      batch.set(incomeDocRef, {
        'label': 'Income',
        'icon': 'lib/assets/Income.png',
        'type': CategoryModel.TYPE_INCOME
      });
      
      // Add salary category
      debugPrint('Adding income category: Salary');
      final salaryDocRef = categoriesRef.doc();
      batch.set(salaryDocRef, {
        'label': 'Salary',
        'icon': 'lib/assets/Salary.png',
        'type': CategoryModel.TYPE_INCOME
      });
      
      debugPrint('Committing batch with new categories');
      await batch.commit();
      debugPrint('Category initialization completed successfully');
      
      // Trigger refresh of categories right away
      final newSnapshot = await categoriesRef.get();
      _categories = newSnapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to initialize categories: $e');
      throw Exception('Failed to initialize categories: $e');
    }
  }/// Returns a validated icon path for the given category
  String getIconForCategory(String category) {
    // Check cached categories first for efficiency
    final cachedCategory = _categories.firstWhere(
      (cat) => cat.label == category,
      orElse: () => CategoryModel(
        id: '', 
        label: '', 
        icon: 'lib/assets/Transaction.png'
      ),
    );
    
    if (cachedCategory.label.isNotEmpty) {
      return cachedCategory.icon;
    }
    
    return 'lib/assets/Transaction.png';
  }  Future<void> addCategory(String name, {String type = CategoryModel.TYPE_EXPENSE}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Cannot add category: User not authenticated');
      return;
    }

    // Prevent adding reserved categories
    if (_reservedCategoryLabels.contains(name)) {
      debugPrint('Cannot add reserved category: $name');
      return;
    }
    
    // Prevent duplicates
    if (_categories.any((cat) => cat.label == name)) {
      debugPrint('Cannot add duplicate category: $name');
      return;
    }

    try {
      // Use the proper factory method based on type
      CategoryModel newCategory;
      
      if (type == CategoryModel.TYPE_INCOME) {
        newCategory = CategoryModel.income(
          id: '', // ID will be auto-generated by Firestore
          label: name,
          icon: 'lib/assets/Income.png',
        );
      } else {
        newCategory = CategoryModel.expense(
          id: '', // ID will be auto-generated by Firestore
          label: name,
          icon: 'lib/assets/Transaction.png', // Default icon for new categories
        );
      }

      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .add(newCategory.toFirestore());
    } catch (e) {
      debugPrint('Failed to add category: $e');
      throw Exception('Failed to add category: $e');
    }
  }  Future<void> deleteCategory(String categoryId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Cannot delete category: User not authenticated');
      return;
    }
    
    // Don't allow deleting reserved categories
    final categoryToDelete = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryModel(id: '', label: '', icon: ''),
    );
    
    if (categoryToDelete.id.isEmpty) {
      debugPrint('Category not found: $categoryId');
      return;
    }
    
    if (_reservedCategoryLabels.contains(categoryToDelete.label)) {
      debugPrint('Cannot delete reserved category: ${categoryToDelete.label}');
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(categoryId)
          .delete();
    } catch (e) {
      debugPrint('Failed to delete category: $e');
      throw Exception('Failed to delete category: $e');
    }
  }
  Future<void> updateCategory(String categoryId, {String? label, String? icon, String? type}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      debugPrint('Cannot update category: User not authenticated');
      return;
    }
    
    // Find the category to ensure it exists
    final categoryToUpdate = _categories.firstWhere(
      (cat) => cat.id == categoryId,
      orElse: () => CategoryModel(id: '', label: '', icon: ''),
    );
    
    if (categoryToUpdate.id.isEmpty) {
      debugPrint('Category not found: $categoryId');
      return;
    }
    
    // Don't allow updating reserved categories
    if (_reservedCategoryLabels.contains(categoryToUpdate.label)) {
      debugPrint('Cannot update reserved category: ${categoryToUpdate.label}');
      return;
    }
    
    // Don't allow duplicates if label is being changed
    if (label != null && 
        label != categoryToUpdate.label && 
        _categories.any((cat) => cat.label == label)) {
      debugPrint('Cannot update to duplicate name: $label');
      return;
    }

    try {
      final updates = <String, dynamic>{};
      if (label != null) updates['label'] = label;
      if (icon != null) updates['icon'] = icon;
      if (type != null && CategoryModel.VALID_TYPES.contains(type)) {
        updates['type'] = type;
      }
      
      if (updates.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('categories')
            .doc(categoryId)
            .update(updates);
      }
    } catch (e) {
      debugPrint('Failed to update category: $e');
      throw Exception('Failed to update category: $e');
    }
  }

  /// Returns a deduplicated list of categories based on their labels
  List<CategoryModel> getUniqueCategories(List<CategoryModel> categories) {
    final Map<String, CategoryModel> uniqueMap = {};
    for (var cat in categories) {
      if (!uniqueMap.containsKey(cat.label)) {
        uniqueMap[cat.label] = cat;
      }
    }
    return uniqueMap.values.toList();  }
  
  @override
  void dispose() {
    _categorySubscription?.cancel();
    super.dispose();
  }
}
