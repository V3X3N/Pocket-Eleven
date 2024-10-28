import 'package:flutter/foundation.dart';

import 'firebase_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StadiumFunctions {
  static Future<int> getStadiumLevel(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFunctions.getUserDocument(userId);
      return userDoc.get('stadiumLevel') ?? 1;
    } catch (error) {
      debugPrint('Error loading stadium level: $error');
      return 1;
    }
  }

  static Future<void> updateStadiumLevel(String userId, int level) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFunctions.getUserDocument(userId);
      await userDoc.reference.update({'stadiumLevel': level});
    } catch (error) {
      debugPrint('Error updating stadium level: $error');
    }
  }
}
