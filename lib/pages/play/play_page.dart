import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/play/class/match_view.dart';
import 'package:pocket_eleven/pages/play/class/league_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({super.key});

  @override
  State<PlayPage> createState() => _PlayPageState();
}

class _PlayPageState extends State<PlayPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _matchResult();
  }

  void _onOptionSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _matchResult() async {
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
              match['club1goals'] = 1;
              match['club2goals'] = 1;
            } else if (club1IsUser || club2IsUser) {
              if (club1IsUser) {
                match['club1goals'] = 2;
                match['club2goals'] = 0;
              } else {
                match['club1goals'] = 0;
                match['club2goals'] = 2;
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: ReusableAppBar(appBarHeight: screenHeight * 0.07),
      body: Container(
        color: AppColors.primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OptionButton(
                    index: 0,
                    text: 'Match',
                    onTap: () => _onOptionSelected(0),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    selectedIndex: _selectedIndex,
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  OptionButton(
                    index: 1,
                    text: 'League',
                    onTap: () => _onOptionSelected(1),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    selectedIndex: _selectedIndex,
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  MatchView(
                      screenWidth: screenWidth, screenHeight: screenHeight),
                  LeagueView(
                      screenWidth: screenWidth, screenHeight: screenHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
