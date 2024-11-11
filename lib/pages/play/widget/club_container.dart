import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/play/widget/club_info.dart';

class ClubInfoContainer extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const ClubInfoContainer({
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  Future<Map<String, dynamic>?> _getNextMatch(String userClubName) async {
    var now = DateTime.now();

    List<Map<String, dynamic>> upcomingMatchesList = [];

    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    var userLeagueRef = userDoc.data()?['leagueRef'] as DocumentReference?;

    if (userLeagueRef != null) {
      var leagueDoc = await userLeagueRef.get();
      var leagueData = leagueDoc.data() as Map<String, dynamic>;
      var clubs = List<DocumentReference>.from(leagueData['clubs']);

      debugPrint("Looking for the user's club reference...");
      for (var club in clubs) {
        if (club.id == FirebaseAuth.instance.currentUser?.uid) {
          debugPrint("Found user's club reference: ${club.id}");
        }
      }

      var matches = leagueData['matches'] as Map<String, dynamic>;

      matches.forEach((roundKey, roundMatches) {
        for (var match in roundMatches) {
          if ((match['club1'] as DocumentReference).id ==
                  FirebaseAuth.instance.currentUser?.uid ||
              (match['club2'] as DocumentReference).id ==
                  FirebaseAuth.instance.currentUser?.uid) {
            var matchTime = (match['matchTime'] as Timestamp).toDate();

            if (matchTime.isAfter(now)) {
              var club1Ref = match['club1'] as DocumentReference;
              var club2Ref = match['club2'] as DocumentReference;

              var matchData = {
                'matchTime': matchTime,
                'club1': club1Ref,
                'club2': club2Ref,
              };
              upcomingMatchesList.add(matchData);
            }
          }
        }
      });

      upcomingMatchesList.sort((a, b) {
        return (a['matchTime'] as DateTime)
            .compareTo(b['matchTime'] as DateTime);
      });

      if (upcomingMatchesList.isNotEmpty) {
        var nextMatch = upcomingMatchesList.first;
        var userClubName = userDoc.data()?['clubName'] as String?;
        var opponentRef = nextMatch['club1'] ==
                FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser?.uid)
            ? nextMatch['club2']
            : nextMatch['club1'];

        var opponentName = await _resolveClubName(opponentRef);

        return {
          'userClubName': userClubName,
          'opponentName': opponentName,
          'matchTime': nextMatch['matchTime'],
        };
      }
    }

    return null;
  }

  Future<String> _resolveClubName(DocumentReference clubRef) async {
    var doc = await clubRef.get();
    var data = doc.data() as Map<String, dynamic>?;

    if (clubRef.path.startsWith('users/')) {
      return data?['clubName'] ?? 'Unknown Club';
    } else if (clubRef.path.startsWith('bots/')) {
      return clubRef.id;
    }
    return 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: FutureBuilder<Map<String, dynamic>?>(
        future: _getNextMatch(''),
        builder: (context, matchSnapshot) {
          if (!matchSnapshot.hasData || matchSnapshot.data == null) {
            return const Text("Brak nadchodzących meczów.");
          }

          var matchData = matchSnapshot.data!;
          var userClubName = matchData['userClubName'];
          var opponentName = matchData['opponentName'];
          var matchTime = matchData['matchTime'].toString();

          return Container(
            margin: EdgeInsets.all(screenWidth * 0.05),
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: AppColors.hoverColor,
              border: Border.all(color: AppColors.borderColor, width: 1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            height: screenHeight * 0.25,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ClubInfo(
                      clubCrestPath: 'assets/crests/crest_1.png',
                      clubName: userClubName,
                    ),
                    const Text("VS"),
                    ClubInfo(
                      clubCrestPath: 'assets/crests/crest_2.png',
                      clubName: opponentName,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  "Najbliższy mecz: $matchTime",
                  style: const TextStyle(
                      fontSize: 16, color: AppColors.textEnabledColor),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
