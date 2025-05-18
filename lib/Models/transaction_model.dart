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
    }    // Get the category for use in the model
    final category = data['category'] as String? ?? 'Unknown';
    
    // Get icon directly from Firestore if available
    final icon = data['icon'] is String && (data['icon'] as String).isNotEmpty
        ? data['icon'] as String
        : ''; // Empty string will trigger getIconForCategory in UI if needed
    
    return TransactionModel(
      id: doc.id,
      type: ['income', 'expense'].contains(type) ? type : 'expense',
      amount: amount.isNaN || amount.isInfinite ? 0.0 : amount,
      date: timestamp != null ? timestamp.toDate().toLocal() : DateTime.now(),
      description: data['description'] as String? ?? '',
      category: category,
      categoryId: data['categoryId'] as String? ?? 'unknown',
      icon: icon,
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
