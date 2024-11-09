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
      var clubs = List<String>.from(leagueData['clubs']);

      if (clubs.any((club) => club.startsWith('Bot_'))) {
        return league;
      }
    }
    return null;
  }

  static Future<String> createNewLeagueWithBots(String clubName) async {
    List<String> bots = List.generate(9, (index) => 'Bot_${index + 1}');
    Map<String, dynamic> matchesByRound =
        generateInitialMatches([clubName, ...bots]);

    DocumentReference leagueRef =
        await FirebaseFirestore.instance.collection('leagues').add({
      'clubs': [clubName, ...bots],
      'clubs_count': 10,
      'matches': matchesByRound,
    });

    return leagueRef.id;
  }

  static Map<String, dynamic> generateInitialMatches(List<String> clubs) {
    Map<String, dynamic> matchesByRound = {};
    if (clubs.length % 2 != 0) clubs.add('BYE');

    int numTeams = clubs.length;
    int numRounds = numTeams - 1;
    int numMatchesPerDay = numTeams ~/ 2;

    List<String> currentClubs = List.from(clubs);

    for (int round = 0; round < numRounds; round++) {
      List<Map<String, dynamic>> roundMatches = [];

      for (int i = 0; i < numMatchesPerDay; i++) {
        String homeTeam = currentClubs[i];
        String awayTeam = currentClubs[numTeams - 1 - i];

        roundMatches.add({
          'club1': homeTeam,
          'club2': awayTeam,
          'matchTime': null,
          'score': null,
        });
      }

      matchesByRound['round${round + 1}'] = roundMatches;
      String lastTeam = currentClubs.removeAt(currentClubs.length - 1);
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
      DocumentSnapshot leagueSnapshot, String botName, String clubName) async {
    var leagueData = leagueSnapshot.data() as Map<String, dynamic>;
    List<dynamic> matches = leagueData['matches'];

    for (int i = 0; i < matches.length; i++) {
      var match = matches[i] as Map<String, dynamic>;

      if (match['club1'] == botName) {
        matches[i]['club1'] = clubName;
      } else if (match['club2'] == botName) {
        matches[i]['club2'] = clubName;
      }
    }

    await leagueSnapshot.reference.update({'matches': matches});
    debugPrint("Replaced bot $botName with $clubName in all matches.");
  }

  static Future<bool> isClubInLeague(String email) async {
    var clubSnapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .where('managerEmail', isEqualTo: email)
        .limit(1)
        .get();

    if (clubSnapshot.docs.isNotEmpty) {
      var clubData = clubSnapshot.docs.first.data();
      var leagueId = clubData['leagueId'];
      return leagueId != null;
    }
    return false;
  }
}
