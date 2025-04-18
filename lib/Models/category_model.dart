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
      label: data['label'] as String,
      icon: data['icon'] as String,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'label': label,
      'icon': icon,
    };
  }
}