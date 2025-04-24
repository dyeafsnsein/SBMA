import 'package:cloud_firestore/cloud_firestore.dart';
import '../Models/category_model.dart'; // Import CategoryModel

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

    // Default categories using CategoryModel
    final defaultCategories = [
      CategoryModel(id: '', label: 'Food', icon: 'lib/assets/Food.png'),
      CategoryModel(
          id: '', label: 'Transport', icon: 'lib/assets/Transport.png'),
      CategoryModel(id: '', label: 'Rent', icon: 'lib/assets/Rent.png'),
      CategoryModel(
          id: '', label: 'Entertainment', icon: 'lib/assets/Entertainment.png'),
      CategoryModel(id: '', label: 'Medicine', icon: 'lib/assets/Medicine.png'),
      CategoryModel(
          id: '', label: 'Groceries', icon: 'lib/assets/Groceries.png'),
    ];

    // Add default categories to Firestore with auto-generated IDs
    final batch = FirebaseFirestore.instance.batch();
    for (var category in defaultCategories) {
      final docRef = categoriesRef.doc(); // Auto-generate ID
      batch.set(docRef, category.toFirestore());
    }
    await batch.commit();
  }

  static Future<String> getIconForCategory(
      String userId, String category) async {
    final categoryDocs = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('categories')
        .where('label', isEqualTo: category)
        .limit(1)
        .get();

    if (categoryDocs.docs.isNotEmpty) {
      final data = categoryDocs.docs.first.data();
      return data['icon'] as String;
    }
    return 'lib/assets/Transaction.png'; // Fallback icon
  }
}
