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

// Pobieranie meczów i grupowanie według rund
  Future<List<Map<String, dynamic>>> _getMatches() async {
    var leaguesSnapshot = await FirebaseFirestore.instance
        .collection('leagues')
        .limit(1) // Zakładamy, że liga jest tylko jedna w danym kontekście
        .get();

    if (leaguesSnapshot.docs.isNotEmpty) {
      var leagueData = leaguesSnapshot.docs.first.data();
      var matches = leagueData['matches'] as Map<String, dynamic>;

      // Lista, która będzie zawierać wszystkie mecze z rund
      List<Map<String, dynamic>> allMatches = [];

      // Iterujemy przez rundy w "matches"
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

              // Filtrujemy mecze użytkownika
              var nextMatch = allMatches.firstWhere(
                  (match) =>
                      match['club1'] == userClubName ||
                      match['club2'] == userClubName,
                  orElse: () => {});

              if (nextMatch.isEmpty) {
                return const Text("Brak meczów do wyświetlenia");
              }

              var opponentName = nextMatch['club1'] == userClubName
                  ? nextMatch['club2']
                  : nextMatch['club1'];
              var matchTime = (nextMatch['matchTime'] as Timestamp).toDate();
              var matchTimeText = matchTime.toString();

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
                      "Najbliższy mecz: $matchTimeText",
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
