import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firebase_league.dart';

class ClubFunctions {
  static Future<bool> isClubInLeague(String email) async {
    var clubSnapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .where('managerEmail', isEqualTo: email)
        .limit(1)
        .get();

    if (clubSnapshot.docs.isNotEmpty) {
      var clubData = clubSnapshot.docs.first.data();
      var leagueId = clubData['leagueId'];
      return leagueId != null;
    }
    return false;
  }

  static Future<void> assignClubToLeague(String email) async {
    var clubSnapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .where('managerEmail', isEqualTo: email)
        .limit(1)
        .get();

    if (clubSnapshot.docs.isNotEmpty) {
      var clubDoc = clubSnapshot.docs.first;
      var clubData = clubDoc.data();
      var userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(clubData['managerId']);

      DocumentSnapshot? availableLeague =
          await LeagueFunctions.findAvailableLeagueWithBot();

      if (availableLeague != null) {
        var leagueData = availableLeague.data() as Map<String, dynamic>;
        var clubs = List<DocumentReference>.from(leagueData['clubs']);

        DocumentReference? botToReplace;
        for (var club in clubs) {
          if (club.id.startsWith('Bot_')) {
            botToReplace = club;
            break;
          }
        }

        if (botToReplace != null) {
          clubs[clubs.indexOf(botToReplace)] = userRef;
          await availableLeague.reference.update({
            'clubs': clubs,
          });

          await LeagueFunctions.replaceBotInMatches(
              availableLeague, botToReplace.id, userRef.id);

          await userRef.update({
            'leagueRef': availableLeague.reference,
          });

          debugPrint(
              "Replaced bot ${botToReplace.id} with ${userRef.id} in league ${availableLeague.id}");
        } else {
          debugPrint("No bot found to replace.");
        }
      } else {
        String newLeagueId = await LeagueFunctions.createNewLeagueWithBots();
        debugPrint("Created new league with ID: $newLeagueId");

        DocumentReference newLeagueRef =
            FirebaseFirestore.instance.collection('leagues').doc(newLeagueId);
        await userRef.update({
          'leagueRef': newLeagueRef,
        });
      }
    }
  }

  static Future<String> getClubId(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('club')) {
        DocumentReference clubRef = userData['club'];
        return clubRef.id;
      }
      return '';
    } catch (error) {
      debugPrint('Error loading club id: $error');
      return '';
    }
  }

  static Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
    return null;
  }

  static Future<Map<String, int>> initializeSectorLevels(
      DocumentReference userDocRef, Map<String, dynamic> userData) async {
    Map<String, int> defaultSectorLevels = {
      'sector1': 0,
      'sector2': 0,
      'sector3': 0,
      'sector4': 0,
      'sector5': 0,
      'sector6': 0,
      'sector7': 0,
      'sector8': 0,
      'sector9': 0,
    };

    if (!userData.containsKey('sectorLevel')) {
      await userDocRef.update({'sectorLevel': defaultSectorLevels});
      debugPrint('Sector levels created with default values');
    } else {
      defaultSectorLevels =
          Map<String, int>.from(userData['sectorLevel'] as Map);
      debugPrint('Loaded sector levels: $defaultSectorLevels');
    }
    return defaultSectorLevels;
  }
}
