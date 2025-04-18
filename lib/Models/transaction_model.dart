import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String type;
  final double amount;
  final DateTime date;
  final String description;
  final String category;
  final String categoryId;
  final String icon;

  TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.category,
    required this.categoryId,
    required this.icon,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final timestamp = data['timestamp'] as Timestamp?;
    return TransactionModel(
      id: doc.id,
      type: data['type'] ?? 'expense',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      date: timestamp != null ? timestamp.toDate().toLocal() : DateTime.now(),
      description: data['description'] ?? '',
      category: data['category'] ?? 'Unknown',
      categoryId: data['categoryId'] ?? 'unknown',
      icon: data['icon'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'amount': amount,
      'timestamp': Timestamp.fromDate(date),
      'description': description,
      'category': category,
      'categoryId': categoryId,
      'icon': icon,
    };
  }
}