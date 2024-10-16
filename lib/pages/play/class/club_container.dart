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

  // Pobieranie najbliższego meczu użytkownika
  Future<Map<String, dynamic>> _getNextMatch(String userClubName) async {
    var leaguesSnapshot = await FirebaseFirestore.instance
        .collection('leagues')
        .where('clubs', arrayContains: userClubName)
        .get();

    if (leaguesSnapshot.docs.isNotEmpty) {
      var leagueData = leaguesSnapshot.docs.first.data();
      var matches = leagueData['matches'] as List;

      // Filtrujemy mecze, aby znaleźć najbliższy, który jeszcze się nie odbył
      var now = DateTime.now();
      matches.sort((a, b) =>
          (a['matchTime'].toDate()).compareTo(b['matchTime'].toDate()));
      var nextMatch = matches.firstWhere(
          (match) => match['matchTime'].toDate().isAfter(now),
          orElse: () => {});

      return nextMatch.isNotEmpty
          ? nextMatch
          : {'club1': 'N/A', 'club2': 'N/A', 'matchTime': null};
    }
    return {'club1': 'N/A', 'club2': 'N/A', 'matchTime': null};
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
          return FutureBuilder<Map<String, dynamic>>(
            future: _getNextMatch(userClubName),
            builder: (context, matchSnapshot) {
              if (!matchSnapshot.hasData || matchSnapshot.data == null) {
                return const CircularProgressIndicator();
              }

              var match = matchSnapshot.data!;
              var club1 = match['club1'];
              var club2 = match['club2'];
              var matchTime = match['matchTime'] != null
                  ? (match['matchTime'] as Timestamp).toDate()
                  : null;

              // Określenie, kto jest przeciwnikiem
              var opponentName = club1 == userClubName ? club2 : club1;
              var matchTimeText = matchTime != null
                  ? matchTime.toString()
                  : 'Brak następnego meczu';

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
                        Text("VS"),
                        ClubInfo(
                          clubCrestPath: 'assets/crests/crest_2.png',
                          clubName: opponentName,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Najbliższy mecz: $matchTimeText",
                      style: TextStyle(
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
