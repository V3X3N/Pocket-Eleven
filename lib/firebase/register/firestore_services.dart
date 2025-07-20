import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/register/cache_manager.dart';
import 'package:pocket_eleven/firebase/register/register_data.dart';

class FirestoreService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save user data to Firestore with money field
  static Future<void> saveUserToFirestore(
      RegisterData data, String userId) async {
    await _firestore.collection('users').doc(userId).set({
      'username': data.username,
      'email': data.email,
      'clubName': data.clubName,
      'money': int.parse(data.money), // Save money as integer
      'uid': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastActive': FieldValue.serverTimestamp(),
    });
  }

  // Cached email existence check
  static Future<bool> isEmailRegistered(String email) async {
    final cachedResult = CacheManager.getCachedEmail(email);
    if (cachedResult != null) return cachedResult;

    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      final exists = snapshot.docs.isNotEmpty;
      CacheManager.cacheEmail(email, exists);
      return exists;
    } catch (e) {
      debugPrint('Email check error: $e');
      return false;
    }
  }

  // Check if user has a club
  static Future<bool> userHasClub(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return false;

      final data = snapshot.docs.first.data();
      return data['clubName']?.toString().isNotEmpty ?? false;
    } catch (e) {
      debugPrint('Club check error: $e');
      return false;
    }
  }

  // Get user data stream
  static Stream<DocumentSnapshot> getUserDataStream(String userId) =>
      _firestore.collection('users').doc(userId).snapshots();

  // Get user data
  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      debugPrint('Get user data error: $e');
      return null;
    }
  }

  // Update user data
  static Future<void> updateUserData(
      String userId, Map<String, dynamic> updates) async {
    try {
      updates['lastUpdated'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      debugPrint('Update user data error: $e');
    }
  }

  // Cleanup operations
  static Future<void> cleanupUserData(String userId) async {
    try {
      final batch = _firestore.batch();
      batch.delete(_firestore.collection('users').doc(userId));
      batch.delete(_firestore.collection('matches').doc(userId));
      await batch.commit();
    } catch (e) {
      debugPrint('Cleanup error: $e');
    }
  }
}
