import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MatchResultProcessor {
  Future<void> processMatchResults() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint("No current user logged in.");
        return;
      }

      String userID = currentUser.uid;
      debugPrint("User ID: $userID");

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .get();

      if (!userDoc.exists) {
        debugPrint("User document not found.");
        return;
      }

      String clubName = userDoc.get('clubName');
      DocumentReference leagueRef = userDoc.get('leagueRef');

      debugPrint("Club Name: $clubName");
      debugPrint("League Reference: $leagueRef");

      DocumentSnapshot leagueDoc = await leagueRef.get();

      if (!leagueDoc.exists) {
        debugPrint("League document not found.");
        return;
      }

      Map<String, dynamic> matches = leagueDoc.get('matches');
      var now = DateTime.now();

      matches.forEach((roundKey, roundMatches) async {
        for (var match in roundMatches) {
          var matchTime = (match['matchTime'] as Timestamp).toDate();
          var club1goals = match['club1goals'];
          var club2goals = match['club2goals'];

          if (club1goals != null && club2goals != null) {
            debugPrint("Results already exist for Round: $roundKey");
            continue;
          }

          if (matchTime.isBefore(now)) {
            var club1Ref = match['club1'] as DocumentReference;
            var club2Ref = match['club2'] as DocumentReference;

            debugPrint("Round: $roundKey");
            debugPrint("Club 1 ID: ${club1Ref.id}");
            debugPrint("Club 2 ID: ${club2Ref.id}");
            debugPrint("Match Time: $matchTime");

            bool club1IsUser = club1Ref.path.startsWith('users/');
            bool club2IsUser = club2Ref.path.startsWith('users/');

            if (club1IsUser && club2IsUser) {
              debugPrint("Both clubs are users. Fetching formations...");

              DocumentSnapshot club1Doc = await club1Ref.get();
              DocumentSnapshot club2Doc = await club2Ref.get();

              if (club1Doc.exists && club2Doc.exists) {
                DocumentReference club1FormationRef =
                    club1Doc.get('formationRef');
                DocumentReference club2FormationRef =
                    club2Doc.get('formationRef');

                int club1OvrSum =
                    await _processFormation(club1FormationRef, "Club 1");
                int club2OvrSum =
                    await _processFormation(club2FormationRef, "Club 2");

                debugPrint("Club 1 Total OVR: $club1OvrSum");
                debugPrint("Club 2 Total OVR: $club2OvrSum");

                if (club1OvrSum > club2OvrSum) {
                  match['club1goals'] = 2;
                  match['club2goals'] = 1;
                } else if (club2OvrSum > club1OvrSum) {
                  match['club1goals'] = 1;
                  match['club2goals'] = 2;
                } else {
                  match['club1goals'] = 1;
                  match['club2goals'] = 1;
                }
              }
            } else {
              match['club1goals'] = 0;
              match['club2goals'] = 0;
            }

            await leagueRef.update({
              'matches.$roundKey': roundMatches,
            });

            debugPrint("Updated match result for Round: $roundKey");
          }
        }
      });
    } catch (e) {
      debugPrint("Error retrieving or updating match result: $e");
    }
  }

  Future<int> _processFormation(
      DocumentReference formationRef, String clubLabel) async {
    int totalOvr = 0;

    try {
      DocumentSnapshot formationDoc = await formationRef.get();

      if (formationDoc.exists) {
        debugPrint("$clubLabel Formation: ${formationRef.id}");

        Map<String, dynamic> formationData =
            formationDoc.data() as Map<String, dynamic>;

        for (var entry in formationData.entries) {
          var key = entry.key;
          var value = entry.value;

          if (value is DocumentReference && value.path.startsWith('players/')) {
            DocumentSnapshot playerDoc = await value.get();
            if (playerDoc.exists) {
              int ovr = playerDoc.get('ovr');
              totalOvr += ovr;
              debugPrint("$clubLabel Player OVR [$key]: $ovr");
            }
          }
        }
      } else {
        debugPrint("$clubLabel formation document not found.");
      }
    } catch (e) {
      debugPrint("Error processing formation for $clubLabel: $e");
    }

    return totalOvr;
  }
}
