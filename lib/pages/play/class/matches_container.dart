import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  Future<String?> _getUserClubName() async {
    var userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();

    // Sprawdzamy, czy dokument istnieje i rzutujemy go na mapę
    if (userDoc.exists) {
      var userData =
          userDoc.data() as Map<String, dynamic>; // Rzutowanie danych na Map
      DocumentReference clubRef = userData['club'] as DocumentReference;

      // Pobieranie danych klubu
      var clubDoc = await clubRef.get();
      var clubData = clubDoc.data()
          as Map<String, dynamic>; // Rzutowanie danych klubu na Map
      return clubData['clubName'] as String?;
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> _getMatches() async {
    var leaguesSnapshot =
        await FirebaseFirestore.instance.collection('leagues').limit(1).get();

    if (leaguesSnapshot.docs.isNotEmpty) {
      var leagueData =
          leaguesSnapshot.docs.first.data() as Map<String, dynamic>;
      var matches = leagueData['matches'] as Map<String, dynamic>;

      List<Map<String, dynamic>> allMatches = [];

      matches.forEach((roundKey, roundMatches) {
        var matchList = List<Map<String, dynamic>>.from(roundMatches);
        allMatches.addAll(matchList);
      });

      return allMatches;
    }
    return [];
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
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: _getMatches(),
            builder: (context, matchSnapshot) {
              if (!matchSnapshot.hasData || matchSnapshot.data == null) {
                return const CircularProgressIndicator();
              }

              var allMatches = matchSnapshot.data!;

              // Filtruj mecze gracza
              var userMatches = allMatches
                  .where((match) =>
                      match['club1'] == userClubName ||
                      match['club2'] == userClubName)
                  .toList();

              // Sortowanie meczów według daty
              userMatches.sort((a, b) {
                return (a['matchTime'] as Timestamp)
                    .toDate()
                    .compareTo((b['matchTime'] as Timestamp).toDate());
              });

              if (userMatches.isEmpty) {
                return const Text("Brak nadchodzących meczów.");
              }

              // Pobranie najbliższego meczu (pierwszy mecz po sortowaniu)
              var nextMatch =
                  userMatches.removeAt(0); // Usuń najbliższy mecz z listy
              var nextOpponent = nextMatch['club1'] == userClubName
                  ? nextMatch['club2']
                  : nextMatch['club1'];
              var nextMatchTime =
                  (nextMatch['matchTime'] as Timestamp).toDate();
              var nextMatchTimeText = nextMatchTime.toString();

              return Column(
                children: [
                  // ClubContainer - Najbliższy mecz
                  Container(
                    margin: EdgeInsets.all(screenWidth * 0.05),
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: AppColors.hoverColor,
                      border:
                          Border.all(color: AppColors.borderColor, width: 1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Text(
                      'Następny mecz: $nextOpponent - $nextMatchTimeText',
                      style: const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),

                  // MatchesContainer - Pozostałe mecze
                  Expanded(
                    child: Container(
                      margin: EdgeInsets.all(screenWidth * 0.05),
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      decoration: BoxDecoration(
                        color: AppColors.hoverColor,
                        border:
                            Border.all(color: AppColors.borderColor, width: 1),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: ListView.builder(
                        itemCount: userMatches.length,
                        itemBuilder: (context, index) {
                          var match = userMatches[index];
                          var opponentName = match['club1'] == userClubName
                              ? match['club2']
                              : match['club1'];
                          var matchTime =
                              (match['matchTime'] as Timestamp).toDate();
                          var matchTimeText = matchTime.toString();

                          return Column(
                            children: [
                              MatchTileButton(
                                isSelected: false,
                                opponentName: opponentName,
                                matchTime: matchTimeText,
                                screenWidth: screenWidth,
                                screenHeight: screenHeight,
                                fontSizeMultiplier: 1.0,
                                onTap: () {
                                  // Można dodać logikę po kliknięciu
                                },
                              ),
                              SizedBox(
                                  height: screenHeight *
                                      0.02), // Odstęp między pastylkami
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
