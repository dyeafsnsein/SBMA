import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async'; // Added import for StreamSubscription
import '../Models/category_model.dart'; // Updated to use CategoryModel

class CategoryController extends ChangeNotifier {
  List<CategoryModel> _categories = [];
  StreamSubscription<QuerySnapshot>? _categorySubscription;

  CategoryController() {
    _setupAuthListener();
  }

  List<CategoryModel> get categories => _categories;

  Future<void> _initializeCategories(String userId) async {
    final categoriesRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories');

    // Check if categories already exist
    final snapshot = await categoriesRef.get();
    if (snapshot.docs.isNotEmpty) {
      return; // Categories already exist, no need to seed
    }

    // Default categories
    final defaultCategories = [
      CategoryModel(id: 'food', label: 'Food', icon: 'lib/assets/Food.png'),
      CategoryModel(id: 'transport', label: 'Transport', icon: 'lib/assets/Transport.png'),
      CategoryModel(id: 'rent', label: 'Rent', icon: 'lib/assets/Rent.png'),
      CategoryModel(id: 'entertainment', label: 'Entertainment', icon: 'lib/assets/Entertainment.png'),
      CategoryModel(id: 'medicine', label: 'Medicine', icon: 'lib/assets/Medicine.png'),
      CategoryModel(id: 'groceries', label: 'Groceries', icon: 'lib/assets/Groceries.png'),
      CategoryModel(id: 'more', label: 'More', icon: 'lib/assets/More.png'),
      CategoryModel(id: 'income', label: 'Income', icon: 'lib/assets/Salary.png'),
    ];

    // Add default categories to Firestore
    final batch = FirebaseFirestore.instance.batch();
    for (var category in defaultCategories) {
      final docRef = categoriesRef.doc(category.id);
      batch.set(docRef, category.toFirestore());
    }
    await batch.commit();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        _initializeCategories(user.uid).then((_) {
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
  }

  void _setupListeners(String userId) {
    _categorySubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories')
        .snapshots()
        .listen((snapshot) {
      _categories = snapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error listening to categories: $e');
    });
  }

  Future<void> addCategory(String name) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final newCategory = CategoryModel(
      id: name.toLowerCase(), // Use label as ID (lowercase for consistency)
      label: name,
      icon: 'lib/assets/star.png', // Default icon for new categories
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('categories')
        .doc(newCategory.id)
        .set(newCategory.toFirestore());
  }

  @override
  void dispose() {
    _categorySubscription?.cancel();
    super.dispose();
  }
}