import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreHelper {
  static Future<void> initializeCategories(String userId) async {
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
      {'label': 'Food', 'icon': 'lib/assets/Food.png'},
      {'label': 'Transport', 'icon': 'lib/assets/Transport.png'},
      {'label': 'Rent', 'icon': 'lib/assets/Rent.png'},
      {'label': 'Entertainment', 'icon': 'lib/assets/Entertainment.png'},
      {'label': 'Medicine', 'icon': 'lib/assets/Medicine.png'},
      {'label': 'Groceries', 'icon': 'lib/assets/Groceries.png'},
      {'label': 'More', 'icon': 'lib/assets/More.png'},
    ];

    // Add default categories to Firestore
    final batch = FirebaseFirestore.instance.batch();
    for (var category in defaultCategories) {
      final docRef = categoriesRef.doc(category['label']);
      batch.set(docRef, category);
    }
    await batch.commit();
  }

  static Future<String> getIconForCategory(String userId, String category) async {
    final categoryDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories')
        .doc(category)
        .get();

    if (categoryDoc.exists) {
      final data = categoryDoc.data() as Map<String, dynamic>;
      return data['icon'] as String;
    }
    return 'lib/assets/Transaction.png'; // Fallback icon
  }
}