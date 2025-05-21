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
        .where((category) => category.label == 'Income')
        .toList();
    
    if (incomeCategories.isNotEmpty) {
      return incomeCategories.first;
    } else {
      // Fallback if no Income category is found
      return CategoryModel(
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
      return CategoryModel(
        id: 'unknown',
        label: 'Unknown',
        icon: 'lib/assets/Transaction.png',
      );
    }
  }
  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        initializeCategories(user.uid).then((_) {
          _setupListeners(user.uid);
        });
      }
    });
  }

  void _clearState() {
    _categorySubscription?.cancel();
    _categorySubscription = null;
    _categories = [];
    notifyListeners();
  }  void _setupListeners(String userId) {
    _categorySubscription?.cancel(); // Prevent duplicate listeners
    _categorySubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots()
        .listen((snapshot) {
      _categories =
          snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
          
      // Check for and clean up duplicate categories
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cleanupDuplicateCategories(userId);
      });
      
      notifyListeners();
    }, onError: (e, stackTrace) {
      // Handle error silently
    });
  }
    // Helper method to clean up duplicate categories
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
      final batch = FirebaseFirestore.instance.batch();
      bool hasDuplicates = false;
      
      // For each label that has multiple categories, keep only the first one
      for (var entry in categoriesByLabel.entries) {
        if (entry.value.length > 1) {
          hasDuplicates = true;
          
          // Keep the first one, delete the rest
          for (int i = 1; i < entry.value.length; i++) {
            // Delete duplicate from Firestore
            batch.delete(
              FirebaseFirestore.instance
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
      // Handle error silently
    }  }Future<void> initializeCategories(String userId) async {
    try {
      final categoriesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('categories');

      // Check if categories already exist
      final snapshot = await categoriesRef.get();
      if (snapshot.docs.isNotEmpty) {
        return;
      }

      // First get existing categories to check for duplicates
      final existingCategories = snapshot.docs
          .map((doc) => doc.data()['label'] as String?)
          .whereType<String>()
          .toSet();
        // Initialize essential categories
      final batch = FirebaseFirestore.instance.batch();
      
      // Add expense categories (only if they don't already exist)
      for (var categoryLabel in _defaultExpenseCategories) {
        // Skip if this category already exists
        if (existingCategories.contains(categoryLabel)) {
          continue;
        }
        
        final docRef = categoriesRef.doc();
        batch.set(docRef, {
          'label': categoryLabel,
          'icon': 'lib/assets/$categoryLabel.png'
        });
        
        // Add to our set of existing categories to prevent duplicates in this batch
        existingCategories.add(categoryLabel);
      }
        // Add just one income category (if it doesn't already exist)
      if (!existingCategories.contains('Income')) {
        final incomeDocRef = categoriesRef.doc();
        batch.set(incomeDocRef, {
          'label': 'Income',
          'icon': 'lib/assets/Income.png'
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to initialize categories: $e');
    }
  }
  Future<String> getIconForCategory(String category) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return 'lib/assets/Transaction.png';
    }

    // Check cached categories first
    final cachedCategory = _categories.firstWhere(
      (cat) => cat.label == category,
      orElse: () =>
          CategoryModel(id: '', label: '', icon: 'lib/assets/Transaction.png'),
    );
    if (cachedCategory.label.isNotEmpty) {
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
        return data['icon'] as String? ?? 'lib/assets/Transaction.png';
      }
      return 'lib/assets/Transaction.png';
    } catch (e) {
      return 'lib/assets/Transaction.png';
    }
  }
  Future<void> addCategory(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    // Prevent adding reserved categories
    if (_incomeCategoryLabels.contains(name) ||
        _reservedCategoryLabels.contains(name)) {
      return;
    }

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
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }
  Future<void> deleteCategory(String categoryId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('categories')
          .doc(categoryId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
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
    return uniqueMap.values.toList();
  }
  /// Recalculate balance from all transactions
  Future<void> recalculateBalance(String userId) async {
    try {
      // Fetch all transactions for the user
      final transactionsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .get();

      // Calculate the new balance
      double totalIncome = 0;
      double totalExpense = 0;
      for (var doc in transactionsSnapshot.docs) {
        final data = doc.data();
        final amount = data['amount'] as double? ?? 0;
        final isExpense = data['isExpense'] as bool? ?? false;
        
        if (isExpense) {
          totalExpense += amount;
        } else {
          totalIncome += amount;
        }
      }
      
      final newBalance = totalIncome - totalExpense;
      
      // Update the user's balance in Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .update({'balance': newBalance});
    } catch (e) {
      throw Exception('Failed to recalculate balance: $e');
    }
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    super.dispose();
  }
}
