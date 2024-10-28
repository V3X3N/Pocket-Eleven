import 'package:flutter/foundation.dart';
import 'firebase_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class YouthFunctions {
  static Future<int> getYouthLevel(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFunctions.getUserDocument(userId);
      return userDoc.get('youthLevel') ?? 1;
    } catch (error) {
      debugPrint('Error loading youth level: $error');
      return 1;
    }
  }

  static Future<void> updateYouthLevel(String userId, int level) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFunctions.getUserDocument(userId);
      await userDoc.reference.update({'youthLevel': level});
    } catch (error) {
      debugPrint('Error updating youth level: $error');
    }
  }

  static Future<int> getScoutingLevel(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFunctions.getUserDocument(userId);
      return userDoc.get('scoutingLevel') ?? 1;
    } catch (error) {
      debugPrint('Error loading scouting level: $error');
      return 1;
    }
  }

  static Future<void> updateScoutingLevel(String userId, int level) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFunctions.getUserDocument(userId);
      await userDoc.reference.update({'scoutingLevel': level});
    } catch (error) {
      debugPrint('Error updating scouting level: $error');
    }
  }
}
