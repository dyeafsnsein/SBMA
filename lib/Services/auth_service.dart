import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<UserCredential> signUp({
    required String name,
    required String email,
    required String password,
    required String dateOfBirth,
    required String mobileNumber,
  }) async {
    try {
      // Step 1: Create the user authentication account
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Step 2: Store additional user data in Firestore if account creation is successful
      if (userCredential.user != null) {
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'name': name,          'email': email,
          'dateOfBirth': dateOfBirth,
          'mobileNumber': mobileNumber,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('users').doc(uid).get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      rethrow;
    }
  }
  Future<void> updateBalance(String uid, double balance) async {
    try {
      debugPrint("AuthService: Updating balance to $balance for user $uid");
      
      // First, check if the user document exists
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      
      if (userDoc.exists) {
        // Update existing user's balance
        await _firestore.collection('users').doc(uid).update({
          'balance': balance,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
        debugPrint("AuthService: Updated existing user's balance");
      } else {
        // Create new user document with balance if it doesn't exist
        // This should not normally happen but is a safety measure
        await _firestore.collection('users').doc(uid).set({
          'balance': balance,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'email': FirebaseAuth.instance.currentUser?.email ?? '',
          'name': FirebaseAuth.instance.currentUser?.displayName ?? 'User',
        }, SetOptions(merge: true));
        debugPrint("AuthService: Created new user document with balance");
      }
    } catch (e) {
      debugPrint("AuthService: Error updating balance: $e");
      rethrow;
    }
  }
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> signInAndGetUserData({
    required String email,
    required String password,
  }) async {
    try {
      // Step 1: Authenticate with Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Get user data from Firestore
      String uid = userCredential.user!.uid;
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
        Map<String, dynamic>? userData = doc.exists ? doc.data() as Map<String, dynamic>? : null;
      // Always direct new users to set balance page
      bool isFirstTimeUser = !doc.exists;

      // Return combined data (both auth result and user data)
      return {
        'userCredential': userCredential,
        'userData': userData,
        'isFirstTimeUser': isFirstTimeUser,
      };
    } catch (e) {
      rethrow;
    }
  }

  // Similarly for Google Sign-In
  Future<Map<String, dynamic>?> signInWithGoogleAndGetUserData() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 1: Authenticate with Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      // Step 2: Get user data or create new user document if it doesn't exist
      String uid = userCredential.user!.uid;
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();      Map<String, dynamic>? userData = doc.exists ? doc.data() as Map<String, dynamic>? : null;
      bool isFirstTimeUser = !doc.exists;      // Create new user document if first time
      if (!doc.exists && userCredential.user != null) {        userData = {
          'email': userCredential.user!.email,
          'name': userCredential.user!.displayName ?? 'User',
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(uid).set(userData);
      }

      return {
        'userCredential': userCredential,
        'userData': userData,
        'isFirstTimeUser': isFirstTimeUser,
      };
    } catch (e) {
      rethrow;
    }
  }
}
