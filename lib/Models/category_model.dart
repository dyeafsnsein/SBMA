import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String label;
  final String icon;
  final String type;

  static const String TYPE_INCOME = 'income';
  static const String TYPE_EXPENSE = 'expense';
  static const List<String> VALID_TYPES = [TYPE_INCOME, TYPE_EXPENSE];

  CategoryModel({
    required this.id,
    required this.label,
    required this.icon,
    this.type = TYPE_EXPENSE,
  });

  bool get isIncome => type == TYPE_INCOME;
  bool get isExpense => type == TYPE_EXPENSE;

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      label: data['label'] as String? ?? 'Unknown',
      icon: data['icon'] as String? ?? 'lib/assets/Transaction.png',
      type: data['type'] as String? ?? TYPE_EXPENSE,
    );
  }

  factory CategoryModel.expense({
    required String id,
    required String label,
    required String icon,
  }) {
    return CategoryModel(
      id: id,
      label: label,
      icon: icon,
      type: TYPE_EXPENSE,
    );
  }
  
  factory CategoryModel.income({
    required String id,
    required String label,
    required String icon,
  }) {
    return CategoryModel(
      id: id,
      label: label,
      icon: icon,
      type: TYPE_INCOME,
    );
  }

  CategoryModel copyWith({
    String? id,
    String? label,
    String? icon,
    String? type,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'icon': icon,
      'type': type,
    };
  }
}
