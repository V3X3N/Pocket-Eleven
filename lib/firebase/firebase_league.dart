import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:pocket_eleven/firebase/firebase_club.dart';

class LeagueFunctions {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Cache for bot references to avoid repeated queries
  static List<DocumentReference>? _cachedBotRefs;

  // Get bot references with caching
  static List<DocumentReference> _getBotReferences() {
    _cachedBotRefs ??= List.generate(
      10,
      (index) => _firestore.collection('bots').doc('Bot_${index + 1}'),
    );
    return _cachedBotRefs!;
  }

  // Main initialization method called from RegisterService
  static Future<void> initializeUserWithLeague(
    String userId,
    dynamic userData, // RegisterData or similar
  ) async {
    try {
      final batch = _firestore.batch();
      final userRef = _firestore.collection('users').doc(userId);

      // Initialize user data
      await _initializeUserData(userRef, userId, batch);

      // Create personal league with matches
      await _createPersonalLeagueWithMatches(userId, batch);

      // Commit all operations
      await batch.commit();
    } catch (e) {
      debugPrint('Error initializing user with league: $e');
      rethrow;
    }
  }

  // Initialize user data using ClubFunctions
  static Future<void> _initializeUserData(
    DocumentReference userRef,
    String userId,
    WriteBatch batch,
  ) async {
    try {
      final userData = await ClubFunctions.getUserData(userId);
      if (userData == null) {
        throw Exception('Failed to retrieve user data after creation');
      }

      // Use ClubFunctions to initialize sector levels
      await ClubFunctions.initializeSectorLevels(userRef, userData);
    } catch (e) {
      throw Exception('Failed to initialize user data: $e');
    }
  }

  // Create personal league with optimized batch operations
  static Future<void> _createPersonalLeagueWithMatches(
    String userId,
    WriteBatch batch,
  ) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final bots = _getBotReferences();

      // Create clubs list with user as first club
      final clubs = [userRef, ...bots.take(9)];

      // Create league document
      final leagueRef = _firestore.collection('leagues').doc(userId);

      // Create standings
      final standings = _createInitialStandings(clubs);

      batch.set(leagueRef, {
        'userId': userId,
        'clubs': clubs,
        'clubs_count': 10,
        'standings': standings,
        'currentRound': 1,
        'totalRounds': 18, // Zmienione z 9 na 18
        'season': 1,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create matches document
      final matchesRef = _firestore.collection('matches').doc(userId);
      final matchesData = _generateOptimizedMatches(clubs);

      batch.set(matchesRef, {
        'userId': userId,
        'leagueId': userId,
        'matches': matchesData,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update user with league reference
      batch.update(userRef, {
        'leagueRef': leagueRef,
        'matchesRef': matchesRef,
      });
    } catch (e) {
      throw Exception('Failed to create personal league: $e');
    }
  }

  // Create initial standings for all clubs
  static Map<String, dynamic> _createInitialStandings(
      List<DocumentReference> clubs) {
    return {
      for (var club in clubs)
        club.id: {
          'points': 0,
          'matchesPlayed': 0,
          'wins': 0,
          'draws': 0,
          'losses': 0,
          'goalsScored': 0,
          'goalsConceded': 0,
          'goalDifference': 0,
        }
    };
  }

  // Generate optimized matches structure
  static Map<String, dynamic> _generateOptimizedMatches(
      List<DocumentReference> clubs) {
    final matches = <String, dynamic>{};
    final numTeams = clubs.length;
// Double round-robin
    final numMatchesPerRound = numTeams ~/ 2;

    List<DocumentReference> rotatingClubs = List.from(clubs);

    // First round-robin (everyone plays everyone once)
    for (int round = 0; round < numTeams - 1; round++) {
      final roundMatches = <Map<String, dynamic>>[];

      for (int i = 0; i < numMatchesPerRound; i++) {
        final homeTeam = rotatingClubs[i];
        final awayTeam = rotatingClubs[numTeams - 1 - i];

        roundMatches.add({
          'matchId': '${round + 1}_${i + 1}',
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'homeGoals': null,
          'awayGoals': null,
          'status': 'scheduled',
          'round': round + 1,
        });
      }

      matches['round${round + 1}'] = roundMatches;

      // Rotate clubs for next round (keep first club fixed)
      final lastClub = rotatingClubs.removeLast();
      rotatingClubs.insert(1, lastClub);
    }

    // Second round-robin (reverse home/away)
    rotatingClubs = List.from(clubs);
    for (int round = 0; round < numTeams - 1; round++) {
      final roundMatches = <Map<String, dynamic>>[];
      final actualRound = round + numTeams;

      for (int i = 0; i < numMatchesPerRound; i++) {
        final awayTeam = rotatingClubs[i]; // Switched roles
        final homeTeam = rotatingClubs[numTeams - 1 - i]; // Switched roles

        roundMatches.add({
          'matchId': '${actualRound}_${i + 1}',
          'homeTeam': homeTeam,
          'awayTeam': awayTeam,
          'homeGoals': null,
          'awayGoals': null,
          'status': 'scheduled',
          'round': actualRound,
        });
      }

      matches['round$actualRound'] = roundMatches;

      // Rotate clubs for next round
      final lastClub = rotatingClubs.removeLast();
      rotatingClubs.insert(1, lastClub);
    }

    return matches;
  }

  // Get user's matches with optimized querying
  static Future<Map<String, dynamic>?> getUserMatches(String userId) async {
    try {
      final matchesDoc =
          await _firestore.collection('matches').doc(userId).get();

      if (matchesDoc.exists) {
        return matchesDoc.data();
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user matches: $e');
      return null;
    }
  }

  // Get specific round matches
  static Future<List<Map<String, dynamic>>?> getRoundMatches(
    String userId,
    int round,
  ) async {
    try {
      final matchesDoc =
          await _firestore.collection('matches').doc(userId).get();

      if (matchesDoc.exists) {
        final data = matchesDoc.data() as Map<String, dynamic>;
        final matches = data['matches'] as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(matches['round$round'] ?? []);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching round matches: $e');
      return null;
    }
  }

  // Update match result with optimized batch operations
  static Future<void> updateMatchResult(
    String userId,
    String matchId,
    int homeGoals,
    int awayGoals,
  ) async {
    try {
      final batch = _firestore.batch();

      // Update matches document
      _firestore.collection('matches').doc(userId);

      // Note: This is a simplified update - in real implementation,
      // you'd need to find the specific match and update it
      // This would require a more complex query or restructuring

      // Update league standings
      _firestore.collection('leagues').doc(userId);

      // Commit batch
      await batch.commit();
    } catch (e) {
      debugPrint('Error updating match result: $e');
      rethrow;
    }
  }

  // Stream user matches for real-time updates
  static Stream<Map<String, dynamic>?> getUserMatchesStream(String userId) {
    return _firestore
        .collection('matches')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return snapshot.data();
      }
      return null;
    });
  }

  // Stream specific round matches
  static Stream<List<Map<String, dynamic>>?> getRoundMatchesStream(
    String userId,
    int round,
  ) {
    return _firestore
        .collection('matches')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final matches = data['matches'] as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(matches['round$round'] ?? []);
      }
      return null;
    });
  }

  // Get user's league standings
  static Future<Map<String, dynamic>?> getUserLeagueStandings(
      String userId) async {
    try {
      final leagueDoc =
          await _firestore.collection('leagues').doc(userId).get();

      if (leagueDoc.exists) {
        final data = leagueDoc.data() as Map<String, dynamic>;
        return data['standings'] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching league standings: $e');
      return null;
    }
  }

  // Stream user's league standings
  static Stream<Map<String, dynamic>?> getUserLeagueStandingsStream(
      String userId) {
    return _firestore
        .collection('leagues')
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        return data['standings'] as Map<String, dynamic>?;
      }
      return null;
    });
  }

  // Clean up user's league and matches (for error recovery)
  static Future<void> cleanupUserLeague(String userId) async {
    try {
      final batch = _firestore.batch();

      batch.delete(_firestore.collection('leagues').doc(userId));
      batch.delete(_firestore.collection('matches').doc(userId));

      await batch.commit();
    } catch (e) {
      debugPrint('Error cleaning up user league: $e');
    }
  }

  // Simulate next match and advance to next one
  static Future<void> simulateNextMatch(String userId) async {
    try {
      final batch = _firestore.batch();
      final matchesRef = _firestore.collection('matches').doc(userId);
      final leagueRef = _firestore.collection('leagues').doc(userId);

      final matchesDoc = await matchesRef.get();
      final leagueDoc = await leagueRef.get();

      if (!matchesDoc.exists || !leagueDoc.exists) return;

      final matchesData = matchesDoc.data() as Map<String, dynamic>;

      // Find next match to simulate
      final nextMatch = await _findNextScheduledMatch(userId, matchesData);
      if (nextMatch == null) {
        // No more matches - generate new season
        await _generateNewSeason(userId);
        return;
      }

      // TODO: Add actual match simulation logic here
      // For now, just mark as completed and generate random result
      final homeGoals = Random().nextInt(4);
      final awayGoals = Random().nextInt(4);

      // Update match status
      await _updateMatchResult(userId, nextMatch, homeGoals, awayGoals);

      await batch.commit();
    } catch (e) {
      debugPrint('Error simulating match: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> _findNextScheduledMatch(
      String userId, Map<String, dynamic> matchesData) async {
    final matches = matchesData['matches'] as Map<String, dynamic>? ?? {};

    for (int round = 1; round <= 18; round++) {
      // 18 rounds for double round-robin
      final roundMatches = matches['round$round'] as List? ?? [];

      for (final match in roundMatches) {
        if (match['status'] == 'scheduled') {
          final homeTeam = match['homeTeam'] as DocumentReference?;
          final awayTeam = match['awayTeam'] as DocumentReference?;

          if (homeTeam?.id == userId || awayTeam?.id == userId) {
            return match;
          }
        }
      }
    }

    return null;
  }

  static Future<void> _generateNewSeason(String userId) async {
    // Reset all matches and standings for new season
    final batch = _firestore.batch();

    final userRef = _firestore.collection('users').doc(userId);
    final leagueRef = _firestore.collection('leagues').doc(userId);
    final matchesRef = _firestore.collection('matches').doc(userId);

    final bots = _getBotReferences();
    final clubs = [userRef, ...bots.take(9)];

    // Generate new matches
    final newMatches = _generateOptimizedMatches(clubs);

    // Reset standings
    final newStandings = _createInitialStandings(clubs);

    // Update documents
    batch.update(leagueRef, {
      'standings': newStandings,
      'currentRound': 1,
      'totalRounds': 18,
      'season': FieldValue.increment(1),
    });

    batch.update(matchesRef, {
      'matches': newMatches,
    });

    await batch.commit();
  }

  // Update specific match result
  static Future<void> _updateMatchResult(String userId,
      Map<String, dynamic> matchToUpdate, int homeGoals, int awayGoals) async {
    try {
      final matchesRef = _firestore.collection('matches').doc(userId);
      final leagueRef = _firestore.collection('leagues').doc(userId);

      final matchesDoc = await matchesRef.get();
      final leagueDoc = await leagueRef.get();

      if (!matchesDoc.exists || !leagueDoc.exists) return;

      final matchesData = matchesDoc.data() as Map<String, dynamic>;
      final leagueData = leagueDoc.data() as Map<String, dynamic>;

      // Update match in matches collection
      final matches = Map<String, dynamic>.from(
          matchesData['matches'] as Map<String, dynamic>);
      final roundKey = 'round${matchToUpdate['round']}';
      final roundMatches =
          List<Map<String, dynamic>>.from(matches[roundKey] as List);

      // Find and update the specific match
      for (int i = 0; i < roundMatches.length; i++) {
        if (roundMatches[i]['matchId'] == matchToUpdate['matchId']) {
          roundMatches[i] = {
            ...roundMatches[i],
            'homeGoals': homeGoals,
            'awayGoals': awayGoals,
            'status': 'finished',
          };
          break;
        }
      }

      matches[roundKey] = roundMatches;

      // Update standings
      final standings = Map<String, dynamic>.from(
          leagueData['standings'] as Map<String, dynamic>);
      final homeTeamId = (matchToUpdate['homeTeam'] as DocumentReference).id;
      final awayTeamId = (matchToUpdate['awayTeam'] as DocumentReference).id;

      _updateTeamStandings(standings, homeTeamId, homeGoals, awayGoals, true);
      _updateTeamStandings(standings, awayTeamId, awayGoals, homeGoals, false);

      // Batch update both documents
      final batch = _firestore.batch();

      batch.update(matchesRef, {'matches': matches});
      batch.update(leagueRef, {'standings': standings});

      await batch.commit();
    } catch (e) {
      debugPrint('Error updating match result: $e');
      rethrow;
    }
  }

// Helper method to update team standings
  static void _updateTeamStandings(Map<String, dynamic> standings,
      String teamId, int goalsFor, int goalsAgainst, bool isHome) {
    final teamStats =
        Map<String, dynamic>.from(standings[teamId] as Map<String, dynamic>);

    teamStats['matchesPlayed'] = (teamStats['matchesPlayed'] as int) + 1;
    teamStats['goalsScored'] = (teamStats['goalsScored'] as int) + goalsFor;
    teamStats['goalsConceded'] =
        (teamStats['goalsConceded'] as int) + goalsAgainst;
    teamStats['goalDifference'] =
        (teamStats['goalsScored'] as int) - (teamStats['goalsConceded'] as int);

    if (goalsFor > goalsAgainst) {
      // Win
      teamStats['wins'] = (teamStats['wins'] as int) + 1;
      teamStats['points'] = (teamStats['points'] as int) + 3;
    } else if (goalsFor == goalsAgainst) {
      // Draw
      teamStats['draws'] = (teamStats['draws'] as int) + 1;
      teamStats['points'] = (teamStats['points'] as int) + 1;
    } else {
      // Loss
      teamStats['losses'] = (teamStats['losses'] as int) + 1;
    }

    standings[teamId] = teamStats;
  }

  // Legacy methods kept for compatibility but deprecated
  @deprecated
  static Future<DocumentSnapshot?> findAvailableLeagueWithBot() async {
    // This method is now deprecated as each user gets their own league
    debugPrint('Warning: findAvailableLeagueWithBot is deprecated');
    return null;
  }

  @deprecated
  static Future<String> createNewLeagueWithBots() async {
    // This method is now deprecated as each user gets their own league
    debugPrint('Warning: createNewLeagueWithBots is deprecated');
    return '';
  }

  @deprecated
  static Future<void> replaceBotInMatches(
      DocumentSnapshot leagueSnapshot, String botId, String clubId) async {
    // This method is now deprecated as each user gets their own league
    debugPrint('Warning: replaceBotInMatches is deprecated');
  }

  @deprecated
  static Future<void> replaceBotInStandings(
      DocumentReference leagueRef, String botId, String userId) async {
    // This method is now deprecated as each user gets their own league
    debugPrint('Warning: replaceBotInStandings is deprecated');
  }
}
