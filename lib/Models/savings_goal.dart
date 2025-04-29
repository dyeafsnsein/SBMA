import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoal {
  final String id;
  final String name;
  final String icon;
  final double targetAmount;
  final double currentAmount;
  final DateTime? deadline;
  final bool isActive;

  SavingsGoal({
    required this.id,
    required this.name,
    required this.icon,
    required this.targetAmount,
    required this.currentAmount,
    this.deadline,
    this.isActive = false,
  });

  factory SavingsGoal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingsGoal(
      id: doc.id,
      name: data['name'] as String,
      icon: data['icon'] as String,
      targetAmount: (data['targetAmount'] as num).toDouble(),
      currentAmount: (data['currentAmount'] as num).toDouble(),
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'icon': icon,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline,
      'isActive': isActive,
    };
  }
}

class Deposit {
  final String id;
  final double amount;
  final DateTime timestamp;

  Deposit({
    required this.id,
    required this.amount,
    required this.timestamp,
  });

  factory Deposit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Deposit(
      id: doc.id,
      amount: (data['amount'] as num).toDouble(),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'timestamp': timestamp,
    };
  }
}
