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
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Firestore document data is null for ID: ${doc.id}');
    }

    final timestamp = data['timestamp'] as Timestamp?;
    final type = data['type'] as String? ?? 'expense';
    final amountRaw = data['amount'] as num?;
    final amount = amountRaw?.toDouble() ?? 0.0;

    // Validate data
    if (!['income', 'expense'].contains(type)) {
      print(
          'TransactionModel: Invalid type "$type" for doc ID: ${doc.id}, defaulting to expense');
    }
    if (amount.isNaN || amount.isInfinite) {
      print(
          'TransactionModel: Invalid amount "$amount" for doc ID: ${doc.id}, defaulting to 0.0');
    }
    if (timestamp == null) {
      print(
          'TransactionModel: Missing timestamp for doc ID: ${doc.id}, using current time');
    }

    return TransactionModel(
      id: doc.id,
      type: ['income', 'expense'].contains(type) ? type : 'expense',
      amount: amount.isNaN || amount.isInfinite ? 0.0 : amount,
      date: timestamp != null ? timestamp.toDate().toLocal() : DateTime.now(),
      description: data['description'] as String? ?? '',
      category: data['category'] as String? ?? 'Unknown',
      categoryId: data['categoryId'] as String? ?? 'unknown',
      icon: data['icon'] as String? ?? '',
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
