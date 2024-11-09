import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/play/widgets/club_info.dart';

class ClubInfoContainer extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const ClubInfoContainer({
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  Future<String?> _getUserClubName() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .get();

      if (userDoc.exists) {
        var userData = userDoc.data();
        if (userData != null) {
          return userData['clubName'] as String?;
        }
      }
    } catch (e) {
      debugPrint('Error fetching user club name: $e');
    }
    return null;
  }

  Future<Map<String, dynamic>?> _getNextMatch(String userClubName) async {
    var now = DateTime.now();
    var leaguesSnapshot =
        await FirebaseFirestore.instance.collection('leagues').limit(1).get();

    if (leaguesSnapshot.docs.isNotEmpty) {
      var leagueData = leaguesSnapshot.docs.first.data();
      var matches = leagueData['matches'] as Map<String, dynamic>;

      List<Map<String, dynamic>> allMatches = [];

      matches.forEach((_, roundMatches) {
        var matchList = List<Map<String, dynamic>>.from(roundMatches);
        allMatches.addAll(matchList);
      });

      var upcomingMatches = allMatches.where((match) {
        var matchTime = (match['matchTime'] as Timestamp).toDate();
        return matchTime.isAfter(now) &&
            (match['club1'] == userClubName || match['club2'] == userClubName);
      }).toList();

      upcomingMatches.sort((a, b) {
        return (a['matchTime'] as Timestamp)
            .toDate()
            .compareTo((b['matchTime'] as Timestamp).toDate());
      });

      return upcomingMatches.isNotEmpty ? upcomingMatches.first : null;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: FutureBuilder<String?>(
        future: _getUserClubName(),
        builder: (context, clubNameSnapshot) {
          if (!clubNameSnapshot.hasData) {
            return const CircularProgressIndicator();
          }

          var userClubName = clubNameSnapshot.data!;
          return FutureBuilder<Map<String, dynamic>?>(
            future: _getNextMatch(userClubName),
            builder: (context, matchSnapshot) {
              if (!matchSnapshot.hasData || matchSnapshot.data == null) {
                return const Text("Brak nadchodzących meczów.");
              }

              var nextMatch = matchSnapshot.data!;
              var opponentName = nextMatch['club1'] == userClubName
                  ? nextMatch['club2']
                  : nextMatch['club1'];
              var matchTime =
                  (nextMatch['matchTime'] as Timestamp).toDate().toString();

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
          );
        },
      ),
    );
  }
}
