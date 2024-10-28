import 'package:flutter/foundation.dart';

import 'firebase_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalFunctions {
  static Future<int> getMedicalLevel(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFunctions.getUserDocument(userId);
      return userDoc.get('medicalLevel') ?? 1;
    } catch (error) {
      debugPrint('Error loading medical level: $error');
      return 1;
    }
  }

  static Future<void> updateMedicalLevel(String userId, int level) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFunctions.getUserDocument(userId);
      await userDoc.reference.update({'medicalLevel': level});
    } catch (error) {
      debugPrint('Error updating medical level: $error');
    }
  }
}
