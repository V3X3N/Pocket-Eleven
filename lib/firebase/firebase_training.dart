import 'package:flutter/foundation.dart';

import 'firebase_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TrainingFunctions {
  static Future<int> getTrainingLevel(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFunctions.getUserDocument(userId);
      return userDoc.get('trainingLevel') ?? 1;
    } catch (error) {
      debugPrint('Error loading training level: $error');
      return 1;
    }
  }

  static Future<void> updateTrainingLevel(String userId, int level) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFunctions.getUserDocument(userId);
      await userDoc.reference.update({'trainingLevel': level});
    } catch (error) {
      debugPrint('Error updating training level: $error');
    }
  }
}
