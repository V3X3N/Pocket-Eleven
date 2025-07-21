import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeagueService {
  static Future<DocumentSnapshot> getLeagueStandings() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not logged in.');

    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userDoc.exists) throw Exception('User document not found.');

    DocumentReference leagueRef = userDoc.get('leagueRef');
    return leagueRef.get();
  }

  static Future<Map<String, String>> fetchClubNames(
      Iterable<String> ids) async {
    Map<String, String> clubNames = {};

    for (String id in ids) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(id).get();

      if (userDoc.exists) {
        clubNames[id] = userDoc.get('clubName');
      } else {
        clubNames[id] = id;
      }
    }

    return clubNames;
  }

  static List<MapEntry<String, dynamic>> sortStandings(
      Map<String, dynamic> standings, Map<String, String> clubNames) {
    var entries = standings.entries.toList();

    entries.sort((a, b) {
      final teamA = a.value;
      final teamB = b.value;

      int pointsA = teamA['points'];
      int pointsB = teamB['points'];

      if (pointsA != pointsB) return pointsB.compareTo(pointsA);

      int goalDiffA = teamA['goalsScored'] - teamA['goalsConceded'];
      int goalDiffB = teamB['goalsScored'] - teamB['goalsConceded'];

      if (goalDiffA != goalDiffB) return goalDiffB.compareTo(goalDiffA);

      int goalsScoredA = teamA['goalsScored'];
      int goalsScoredB = teamB['goalsScored'];

      if (goalsScoredA != goalsScoredB) {
        return goalsScoredB.compareTo(goalsScoredA);
      }

      String nameA = clubNames[a.key] ?? a.key;
      String nameB = clubNames[b.key] ?? b.key;

      return nameA.compareTo(nameB);
    });

    return entries;
  }
}
