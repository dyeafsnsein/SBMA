import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String id;
  final String label;
  final String icon;

  CategoryModel({
    required this.id,
    required this.label,
    required this.icon,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CategoryModel(
      id: doc.id,
      label: data['label'] as String? ?? 'Unknown',
      icon: data['icon'] as String? ?? 'lib/assets/Transaction.png',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'icon': icon,
    };
  }
}
