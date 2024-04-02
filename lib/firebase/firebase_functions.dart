import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseFunctions {
  static saveUser(String managerName, email, uid) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set({'email': email, 'managerName': managerName});
  }

  static Future<String> getManagerName(String userId) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.get('managerName') ?? '';
      } else {
        return '';
      }
    } catch (error) {
      print('Error loading manager name: $error');
      return '';
    }
  }

  static Future<String> getClubName(String userId) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.get('clubName') ?? '';
      } else {
        return '';
      }
    } catch (error) {
      print('Error loading club name: $error');
      return '';
    }
  }

  static Future<String> getEmail(String userId) async {
    try {
      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc.get('email') ?? '';
      } else {
        return '';
      }
    } catch (error) {
      print('Error loading email: $error');
      return '';
    }
  }
}
