import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class LeagueFunctions {
  static Future<DocumentSnapshot?> findAvailableLeagueWithBot() async {
    var leagues = await FirebaseFirestore.instance
        .collection('leagues')
        .where('clubs_count', isEqualTo: 10)
        .get();

    for (var league in leagues.docs) {
      var leagueData = league.data();
      var clubs = List<DocumentReference>.from(leagueData['clubs']);

      if (clubs.any((club) => club.id.startsWith('Bot_'))) {
        return league;
      }
    }
    return null;
  }

  static Future<String> createNewLeagueWithBots() async {
    List<DocumentReference> bots = List.generate(
        10,
        (index) => FirebaseFirestore.instance
            .collection('bots')
            .doc('Bot_${index + 1}'));

    Map<String, dynamic> matchesByRound = generateInitialMatches(bots);

    DocumentReference leagueRef =
        await FirebaseFirestore.instance.collection('leagues').add({
      'clubs': bots,
      'clubs_count': 10,
      'matches': matchesByRound,
    });

    return leagueRef.id;
  }

  static Map<String, dynamic> generateInitialMatches(
      List<DocumentReference> clubs) {
    Map<String, dynamic> matchesByRound = {};

    int numTeams = clubs.length;
    int numRounds = numTeams - 1;
    int numMatchesPerDay = numTeams ~/ 2;

    List<DocumentReference> currentClubs = List.from(clubs);

    for (int round = 0; round < numRounds; round++) {
      List<Map<String, dynamic>> roundMatches = [];

      for (int i = 0; i < numMatchesPerDay; i++) {
        DocumentReference homeTeam = currentClubs[i];
        DocumentReference awayTeam = currentClubs[numTeams - 1 - i];

        roundMatches.add({
          'club1': homeTeam,
          'club2': awayTeam,
          'club1goals': null,
          'club2goals': null,
          'matchTime': null,
        });
      }

      matchesByRound['round${round + 1}'] = roundMatches;
      DocumentReference lastTeam =
          currentClubs.removeAt(currentClubs.length - 1);
      currentClubs.insert(1, lastTeam);
    }

    matchesByRound = assignMatchTimesByRound(matchesByRound);
    return matchesByRound;
  }

  static Map<String, dynamic> assignMatchTimesByRound(
      Map<String, dynamic> matchesByRound) {
    DateTime now = DateTime.now();
    DateTime matchTime = DateTime(now.year, now.month, now.day, 12);

    matchesByRound.forEach((roundKey, roundMatches) {
      for (int i = 0; i < roundMatches.length; i++) {
        roundMatches[i]['matchTime'] = matchTime;
        matchTime = matchTime.add(const Duration(hours: 2));

        if ((i + 1) % 5 == 0) {
          matchTime = matchTime.add(const Duration(hours: 18));
        }
      }
    });

    return matchesByRound;
  }

  static Future<void> replaceBotInMatches(
      DocumentSnapshot leagueSnapshot, String botId, String clubId) async {
    var leagueData = leagueSnapshot.data() as Map<String, dynamic>;
    Map<String, dynamic> matches = leagueData['matches'];

    matches.forEach((roundKey, roundMatches) {
      for (var match in roundMatches) {
        if ((match['club1'] as DocumentReference).id == botId) {
          match['club1'] =
              FirebaseFirestore.instance.collection('users').doc(clubId);
        } else if ((match['club2'] as DocumentReference).id == botId) {
          match['club2'] =
              FirebaseFirestore.instance.collection('users').doc(clubId);
        }
      }
    });

    await leagueSnapshot.reference.update({'matches': matches});
    debugPrint("Replaced bot $botId with $clubId in all matches.");
  }
}
