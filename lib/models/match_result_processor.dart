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

      DocumentReference leagueRef = userDoc.get('leagueRef');
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

            bool club1IsUser = club1Ref.path.startsWith('users/') &&
                club1Ref.id == currentUser.uid;
            bool club2IsUser = club2Ref.path.startsWith('users/') &&
                club2Ref.id == currentUser.uid;

            bool userInvolvedInMatch = club1IsUser || club2IsUser;

            if (userInvolvedInMatch) {
              debugPrint(
                  "User's club is involved in this match. Fetching formations...");

              DocumentSnapshot club1Doc = await club1Ref.get();
              DocumentSnapshot club2Doc = await club2Ref.get();

              if (club1Doc.exists && club2Doc.exists) {
                DocumentReference club1FormationRef =
                    club1Doc.get('formationRef');
                DocumentReference club2FormationRef =
                    club2Doc.get('formationRef');

                Map<String, int> club1Stats =
                    await _processFormation(club1FormationRef, "Club 1");
                Map<String, int> club2Stats =
                    await _processFormation(club2FormationRef, "Club 2");

                int club1OvrSum = club1Stats['totalOvr']!;
                int club1TotalSalary = club1Stats['totalSalary']!;
                int club2OvrSum = club2Stats['totalOvr']!;
                int club2TotalSalary = club2Stats['totalSalary']!;

                debugPrint("Club 1 Total OVR: $club1OvrSum");
                debugPrint("Club 1 Total Salary: $club1TotalSalary");
                debugPrint("Club 2 Total OVR: $club2OvrSum");
                debugPrint("Club 2 Total Salary: $club2TotalSalary");

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

                if (club1IsUser) {
                  int currentMoney = userDoc.get('money') ?? 0;
                  int updatedMoney = currentMoney - club1TotalSalary;
                  debugPrint(
                      "User's money after salary deduction (club1): $updatedMoney");

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userID)
                      .update({'money': updatedMoney});

                  debugPrint("User money updated successfully for club1.");
                }

                if (club2IsUser) {
                  int currentMoney = userDoc.get('money') ?? 0;
                  int updatedMoney = currentMoney - club2TotalSalary;
                  debugPrint(
                      "User's money after salary deduction (club2): $updatedMoney");

                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(userID)
                      .update({'money': updatedMoney});

                  debugPrint("User money updated successfully for club2.");
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

            await updateStandings(
              leagueRef,
              club1Ref.id,
              club2Ref.id,
              match['club1goals'],
              match['club2goals'],
            );
          }
        }
      });
    } catch (e) {
      debugPrint("Error retrieving or updating match result: $e");
    }
  }

  Future<Map<String, int>> _processFormation(
      DocumentReference formationRef, String clubLabel) async {
    int totalOvr = 0;
    int totalSalary = 0;

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

              double salary = playerDoc.get('salary')?.toDouble() ?? 0.0;
              totalSalary += salary.toInt();
              debugPrint("$clubLabel Player Salary [$key]: $salary");
            }
          }
        }
      } else {
        debugPrint("$clubLabel formation document not found.");
      }
    } catch (e) {
      debugPrint("Error processing formation for $clubLabel: $e");
    }

    return {'totalOvr': totalOvr, 'totalSalary': totalSalary};
  }

  Future<void> updateStandings(DocumentReference leagueRef, String club1Id,
      String club2Id, int club1Goals, int club2Goals) async {
    try {
      DocumentSnapshot leagueDoc = await leagueRef.get();

      Map<String, dynamic> standings =
          (leagueDoc.data() as Map<String, dynamic>?)?['standings'] ?? {};

      standings[club1Id] ??= {
        'points': 0,
        'matchesPlayed': 0,
        'goalsScored': 0,
        'goalsConceded': 0
      };

      standings[club2Id] ??= {
        'points': 0,
        'matchesPlayed': 0,
        'goalsScored': 0,
        'goalsConceded': 0
      };

      standings[club1Id]['matchesPlayed'] += 1;
      standings[club1Id]['goalsScored'] += club1Goals;
      standings[club1Id]['goalsConceded'] += club2Goals;

      standings[club2Id]['matchesPlayed'] += 1;
      standings[club2Id]['goalsScored'] += club2Goals;
      standings[club2Id]['goalsConceded'] += club1Goals;

      if (club1Goals > club2Goals) {
        standings[club1Id]['points'] += 3;
      } else if (club1Goals < club2Goals) {
        standings[club2Id]['points'] += 3;
      } else {
        standings[club1Id]['points'] += 1;
        standings[club2Id]['points'] += 1;
      }

      await leagueRef.update({'standings': standings});
      debugPrint("Standings updated successfully.");
    } catch (e) {
      debugPrint("Error updating standings: $e");
    }
  }
}
