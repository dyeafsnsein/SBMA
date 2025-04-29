import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:collection/collection.dart';
import '../Models/savings_goal.dart';

class SavingsController extends ChangeNotifier {
  List<SavingsGoal> _savingsGoals = [];
  SavingsGoal? _activeGoal;
  StreamSubscription<QuerySnapshot>? _savingsGoalsSubscription;
  bool _isLoading = false;
  String? _errorMessage;

  SavingsController() {
    _setupAuthListener();
  }

  List<SavingsGoal> get savingsGoals => _savingsGoals;
  SavingsGoal? get activeGoal => _activeGoal;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        _initializeSavingsGoals(user.uid);
      }
    });
  }

  void _clearState() {
    _savingsGoalsSubscription?.cancel();
    _savingsGoalsSubscription = null;
    _savingsGoals = [];
    _activeGoal = null;
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _initializeSavingsGoals(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check if user has any savings goals
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('savings_goals')
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        // No goals exist, initialize with an empty state
        _savingsGoals = [];
        _activeGoal = null;
      } else {
        // Setup listener for real-time updates
        _setupListeners(userId);
      }
    } catch (e) {
      _errorMessage = 'Failed to initialize savings goals: $e';
      debugPrint('SavingsController: Error initializing savings goals: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _setupListeners(String userId) {
    _savingsGoalsSubscription?.cancel(); // Ensure no duplicate listeners
    _savingsGoalsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savings_goals')
        .snapshots()
        .listen((snapshot) {
      _savingsGoals =
          snapshot.docs.map((doc) => SavingsGoal.fromFirestore(doc)).toList();
      _activeGoal = _savingsGoals.firstWhereOrNull((goal) => goal.isActive);
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      _errorMessage = 'Failed to load savings goals: $e';
      _isLoading = false;
      debugPrint('SavingsController: Error listening to savings goals: $e');
      notifyListeners();
    });
  }

  Future<void> retryLoading() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _clearState();
    await _initializeSavingsGoals(user.uid);
  }

  Future<void> createSavingsGoal({
    required String name,
    required String icon,
    required double targetAmount,
    DateTime? deadline,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final goalId = name.toLowerCase().replaceAll(' ', '_');
      final goal = SavingsGoal(
        id: goalId,
        name: name,
        icon: icon,
        targetAmount: targetAmount,
        currentAmount: 0.0,
        deadline: deadline,
        isActive: _savingsGoals.isEmpty, // Set as active if first goal
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savings_goals')
          .doc(goal.id)
          .set(goal.toFirestore());

      // Ensure listener is set up after creating the first goal
      if (_savingsGoals.isEmpty) {
        _setupListeners(user.uid);
      }
    } catch (e) {
      _errorMessage = 'Failed to create savings goal: $e';
      debugPrint('SavingsController: Error creating savings goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSavingsGoal({
    required String goalId,
    String? name,
    String? icon,
    double? targetAmount,
    DateTime? deadline,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final goalRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savings_goals')
          .doc(goalId);

      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (icon != null) updates['icon'] = icon;
      if (targetAmount != null) updates['targetAmount'] = targetAmount;
      if (deadline != null) updates['deadline'] = Timestamp.fromDate(deadline);

      await goalRef.update(updates);
    } catch (e) {
      _errorMessage = 'Failed to update savings goal: $e';
      debugPrint('SavingsController: Error updating savings goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteSavingsGoal(String goalId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savings_goals')
          .doc(goalId)
          .delete();
    } catch (e) {
      _errorMessage = 'Failed to delete savings goal: $e';
      debugPrint('SavingsController: Error deleting savings goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setActiveGoal(String goalId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var goal in _savingsGoals) {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('savings_goals')
            .doc(goal.id);
        batch.update(docRef, {'isActive': false});
      }
      await batch.commit();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('savings_goals')
          .doc(goalId)
          .update({'isActive': true});
    } catch (e) {
      _errorMessage = 'Failed to set active goal: $e';
      debugPrint('SavingsController: Error setting active goal: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addDeposit(String goalId, double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _errorMessage = 'User not authenticated';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final deposit = Deposit(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        amount: amount,
        timestamp: DateTime.now(),
      );

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final goalRef = FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('savings_goals')
            .doc(goalId);

        final depositRef = goalRef.collection('deposits').doc(deposit.id);

        final goalDoc = await transaction.get(goalRef);
        if (!goalDoc.exists) {
          throw Exception('Savings goal does not exist');
        }

        final goal = SavingsGoal.fromFirestore(goalDoc);
        final newAmount = goal.currentAmount + amount;

        transaction.update(goalRef, {'currentAmount': newAmount});
        transaction.set(depositRef, deposit.toFirestore());
      });
    } catch (e) {
      _errorMessage = 'Failed to add deposit: $e';
      debugPrint('SavingsController: Error adding deposit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _savingsGoalsSubscription?.cancel();
    super.dispose();
  }
}
