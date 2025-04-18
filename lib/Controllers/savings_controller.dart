import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../Models/savings_goal.dart';

class SavingsController extends ChangeNotifier {
  List<SavingsGoal> _savingsGoals = [];
  SavingsGoal? _activeGoal;
  StreamSubscription<QuerySnapshot>? _savingsGoalsSubscription;

  SavingsController() {
    _setupAuthListener();
  }

  List<SavingsGoal> get savingsGoals => _savingsGoals;
  SavingsGoal? get activeGoal => _activeGoal;

  Future<void> _initializeSavingsGoals(String userId) async {
    final savingsGoalsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savings_goals');

    final snapshot = await savingsGoalsRef.get();
    if (snapshot.docs.isNotEmpty) {
      return;
    }

    final defaultSavingsGoals = [
      SavingsGoal(
        id: 'travel',
        name: 'Travel',
        icon: 'lib/assets/Travel.png',
        targetAmount: 2000.0,
        currentAmount: 0.0,
        isActive: false,
      ),
      SavingsGoal(
        id: 'new_house',
        name: 'New House',
        icon: 'lib/assets/New House.png',
        targetAmount: 50000.0,
        currentAmount: 0.0,
        isActive: false,
      ),
      SavingsGoal(
        id: 'car',
        name: 'Car',
        icon: 'lib/assets/Car.png',
        targetAmount: 10000.0,
        currentAmount: 0.0,
        isActive: true,
      ),
      SavingsGoal(
        id: 'wedding',
        name: 'Wedding',
        icon: 'lib/assets/Wedding.png',
        targetAmount: 15000.0,
        currentAmount: 0.0,
        isActive: false,
      ),
    ];

    final batch = FirebaseFirestore.instance.batch();
    for (var goal in defaultSavingsGoals) {
      final docRef = savingsGoalsRef.doc(goal.id);
      batch.set(docRef, goal.toFirestore());
    }
    await batch.commit();
  }

  void _setupAuthListener() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        _clearState();
      } else {
        _initializeSavingsGoals(user.uid).then((_) {
          _setupListeners(user.uid);
        });
      }
    });
  }

  void _clearState() {
    _savingsGoalsSubscription?.cancel();
    _savingsGoalsSubscription = null;
    _savingsGoals = [];
    _activeGoal = null;
    notifyListeners();
  }

  void _setupListeners(String userId) {
    _savingsGoalsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('savings_goals')
        .snapshots()
        .listen((snapshot) {
      _savingsGoals = snapshot.docs.map((doc) => SavingsGoal.fromFirestore(doc)).toList();
      _activeGoal = _savingsGoals.firstWhere((goal) => goal.isActive, orElse: () => SavingsGoal(
        id: 'none',
        name: 'No Active Goal',
        icon: 'lib/assets/Goal.png',
        targetAmount: 0.0,
        currentAmount: 0.0,
        isActive: false,
      ));
      notifyListeners();
    }, onError: (e) {
      debugPrint('Error listening to savings goals: $e');
    });
  }

  Future<void> createSavingsGoal({
    required String name,
    required String icon,
    required double targetAmount,
    DateTime? deadline,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final goal = SavingsGoal(
      id: name.toLowerCase().replaceAll(' ', '_'),
      name: name,
      icon: icon,
      targetAmount: targetAmount,
      currentAmount: 0.0,
      deadline: deadline,
      isActive: false,
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('savings_goals')
        .doc(goal.id)
        .set(goal.toFirestore());
  }

  Future<void> setActiveGoal(String goalId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

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
  }

  Future<void> addDeposit(String goalId, double amount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final deposit = Deposit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      timestamp: DateTime.now(),
    );

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('savings_goals')
        .doc(goalId)
        .collection('deposits')
        .doc(deposit.id)
        .set(deposit.toFirestore());

    final goalRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('savings_goals')
        .doc(goalId);
    final goalDoc = await goalRef.get();
    if (goalDoc.exists) {
      final goal = SavingsGoal.fromFirestore(goalDoc);
      final newAmount = goal.currentAmount + amount;
      await goalRef.update({'currentAmount': newAmount});
    }
  }

  @override
  void dispose() {
    _savingsGoalsSubscription?.cancel();
    super.dispose();
  }
}