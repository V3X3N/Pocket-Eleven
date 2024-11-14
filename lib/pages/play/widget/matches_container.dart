import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/components/match_tile_button.dart';
import 'package:pocket_eleven/design/colors.dart';

class MatchesContainer extends StatelessWidget {
  final double screenWidth;
  final double screenHeight;

  const MatchesContainer({
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  Future<List<Map<String, dynamic>>> _getUpcomingUserMatches() async {
    var now = DateTime.now();

    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    var userLeagueRef = userDoc.data()?['leagueRef'] as DocumentReference?;

    if (userLeagueRef != null) {
      var leagueDoc = await userLeagueRef.get();
      var leagueData = leagueDoc.data() as Map<String, dynamic>;
      var matches = leagueData['matches'] as Map<String, dynamic>;

      List<Map<String, dynamic>> userMatches = [];

      matches.forEach((_, roundMatches) {
        for (var match in roundMatches) {
          var matchTime = (match['matchTime'] as Timestamp).toDate();
          if (matchTime.isAfter(now)) {
            if ((match['club1'] as DocumentReference).id ==
                    FirebaseAuth.instance.currentUser?.uid ||
                (match['club2'] as DocumentReference).id ==
                    FirebaseAuth.instance.currentUser?.uid) {
              userMatches.add({
                ...match,
                'matchTime': matchTime,
              });
            }
          }
        }
      });

      userMatches.sort((a, b) {
        return (a['matchTime'] as DateTime)
            .compareTo(b['matchTime'] as DateTime);
      });

      if (userMatches.isNotEmpty) {
        userMatches.removeAt(0);
      }

      return userMatches;
    }

    return [];
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
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _getUpcomingUserMatches(),
        builder: (context, matchSnapshot) {
          if (!matchSnapshot.hasData) {
            return Center(
              child: LoadingAnimationWidget.waveDots(
                color: AppColors.textEnabledColor,
                size: 50,
              ),
            );
          }

          var userMatches = matchSnapshot.data!;

          if (userMatches.isEmpty) {
            return const Text("Brak nadchodzących meczów.");
          }

          return Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.all(screenWidth * 0.05),
                  padding: EdgeInsets.all(screenWidth * 0.04),
                  decoration: BoxDecoration(
                    color: AppColors.hoverColor,
                    border: Border.all(color: AppColors.borderColor, width: 1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListView.builder(
                    itemCount: userMatches.length,
                    itemBuilder: (context, index) {
                      var match = userMatches[index];
                      var opponentRef =
                          (match['club1'] as DocumentReference).id ==
                                  FirebaseAuth.instance.currentUser?.uid
                              ? match['club2'] as DocumentReference
                              : match['club1'] as DocumentReference;

                      var matchTime = match['matchTime'] as DateTime;

                      return FutureBuilder<String>(
                        future: _resolveClubName(opponentRef),
                        builder: (context, opponentSnapshot) {
                          if (!opponentSnapshot.hasData) {
                            return Center(
                              child: LoadingAnimationWidget.waveDots(
                                color: AppColors.textEnabledColor,
                                size: 50,
                              ),
                            );
                          }

                          return Column(
                            children: [
                              MatchTileButton(
                                isSelected: false,
                                opponentName: opponentSnapshot.data!,
                                matchTime: matchTime.toString(),
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                fontSizeMultiplier: 1.0,
                                onTap: () {},
                              ),
                              SizedBox(height: screenHeight * 0.02),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
