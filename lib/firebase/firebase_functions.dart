import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseFunctions {
  static Future<void> saveUser(
      String managerName, String email, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'email': email, 'managerName': managerName});
    } catch (error) {
      debugPrint('Error saving user data: $error');
    }
  }

  static Future<String> getManagerName(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      return userDoc.get('managerName') ?? '';
    } catch (error) {
      debugPrint('Error loading manager name: $error');
      return '';
    }
  }

  static Future<String> getClubName(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('club')) {
        DocumentReference clubRef = userData['club'];
        DocumentSnapshot clubDoc = await clubRef.get();
        return clubDoc.get('clubName') ?? '';
      }
      return '';
    } catch (error) {
      debugPrint('Error loading club name: $error');
      return '';
    }
  }

  static Future<String> getEmail(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      return userDoc.get('email') ?? '';
    } catch (error) {
      debugPrint('Error loading email: $error');
      return '';
    }
  }

  static Future<void> updateClubName(String email, String clubName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic>? userData =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('club')) {
          DocumentReference clubRef = userData['club'];
          await clubRef.update({'clubName': clubName});
        }
      } else {
        debugPrint('User not found');
      }
    } catch (e) {
      debugPrint('Error updating club name: $e');
    }
  }

  static Future<void> createClub(String clubName, String managerEmail) async {
    try {
      DocumentReference clubRef = await FirebaseFirestore.instance
          .collection('clubs')
          .add({'clubName': clubName});

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: managerEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        await userDoc.reference.update({'club': clubRef});
      } else {
        debugPrint('User not found');
      }
    } catch (e) {
      debugPrint('Error creating club: $e');
    }
  }

  static Future<DocumentSnapshot> _getUserDocument(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc;
  }
}
