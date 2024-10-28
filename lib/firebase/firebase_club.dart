import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/models/player.dart';
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
      var clubName = clubData['clubName'];

      DocumentSnapshot? availableLeague =
          await LeagueFunctions.findAvailableLeagueWithBot();

      if (availableLeague != null) {
        var leagueData = availableLeague.data() as Map<String, dynamic>;
        var clubs = List<String>.from(leagueData['clubs']);

        String? botToReplace;
        for (var club in clubs) {
          if (club.startsWith('Bot_')) {
            botToReplace = club;
            break;
          }
        }

        if (botToReplace != null) {
          clubs[clubs.indexOf(botToReplace)] = clubName;
          await availableLeague.reference.update({
            'clubs': clubs,
          });

          await LeagueFunctions.replaceBotInMatches(
              availableLeague, botToReplace, clubName);

          debugPrint(
              "Replaced bot $botToReplace with $clubName in league ${availableLeague.id}");
        } else {
          debugPrint("No bot found to replace.");
        }
      } else {
        String newLeagueId =
            await LeagueFunctions.createNewLeagueWithBots(clubName);
        debugPrint("Created new league with ID: $newLeagueId");
      }
    }
  }

  static Future<String> getClubId(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFunctions.getUserDocument(userId);
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

  static Future<List<Player>> getPlayersForClub(String clubId) async {
    try {
      DocumentReference clubRef =
          FirebaseFirestore.instance.doc('/clubs/$clubId');

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('players')
          .where('club', isEqualTo: clubRef)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return Player(
          playerID: doc.id,
          name: data['name'] ?? '',
          position: data['position'] ?? '',
          ovr: data['ovr'] ?? 0,
          age: data['age'] ?? 0,
          nationality: data['nationality'] ?? '',
          imagePath: data['imagePath'] ?? '',
          flagPath: data['flagPath'] ?? '',
          value: data['value'] ?? 0,
          salary: data['salary'] ?? 0,
          param1: data['param1'] ?? 0,
          param2: data['param2'] ?? 0,
          param3: data['param3'] ?? 0,
          param4: data['param4'] ?? 0,
          param1Name: data['param1Name'] ?? '',
          param2Name: data['param2Name'] ?? '',
          param3Name: data['param3Name'] ?? '',
          param4Name: data['param4Name'] ?? '',
          matchesPlayed: data['matchesPlayed'] ?? 0,
          goals: data['goals'] ?? 0,
          assists: data['assists'] ?? 0,
          yellowCards: data['yellowCards'] ?? 0,
          redCards: data['redCards'] ?? 0,
        );
      }).toList();
    } catch (error) {
      debugPrint('Error fetching players: $error');
      return [];
    }
  }
}
