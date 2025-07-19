import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

@immutable
class MatchData {
  const MatchData({
    required this.userClubName,
    required this.opponentName,
    required this.matchTime,
    required this.userAvatar,
    required this.opponentAvatar,
  });

  final String userClubName, opponentName;
  final DateTime matchTime;
  final int userAvatar, opponentAvatar;

  factory MatchData.fromMap(Map<String, dynamic> map) => MatchData(
        userClubName: map['userClubName']?.toString() ?? 'Unknown Club',
        opponentName: map['opponentName']?.toString() ?? 'Unknown Opponent',
        matchTime: map['matchTime'] is DateTime
            ? map['matchTime']
            : DateTime.now().add(const Duration(hours: 1)),
        userAvatar: _parseInt(map['userAvatar']),
        opponentAvatar: _parseInt(map['opponentAvatar']),
      );

  static int _parseInt(dynamic value) => switch (value) {
        int v => v.clamp(0, 100),
        String v => int.tryParse(v)?.clamp(0, 100) ?? 0,
        _ => 0,
      };
}

@immutable
class UpcomingMatch {
  const UpcomingMatch({
    required this.opponentName,
    required this.matchTime,
    required this.matchId,
  });

  final String opponentName, matchId;
  final DateTime matchTime;

  factory UpcomingMatch.fromMap(Map<String, dynamic> map) => UpcomingMatch(
        opponentName: map['opponentName']?.toString() ?? 'Unknown',
        matchTime: map['matchTime'] is DateTime
            ? map['matchTime']
            : DateTime.now().add(const Duration(hours: 1)),
        matchId: map['matchId']?.toString() ?? '',
      );
}

class MatchService {
  static final MatchService _instance = MatchService._internal();
  factory MatchService() => _instance;
  MatchService._internal();

  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _cache = <String, (DateTime, dynamic)>{};
  static const _cacheExpiration = Duration(minutes: 5);

  Future<MatchData?> getNextMatch() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    const cacheKey = 'nextMatch';
    final cached = _cache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.$1) < _cacheExpiration) {
      return MatchData.fromMap(cached.$2);
    }

    try {
      final [userDoc, matchesDoc] = await Future.wait([
        _firestore.collection('users').doc(userId).get(),
        _firestore.collection('matches').doc(userId).get(),
      ]).timeout(const Duration(seconds: 8));

      if (!userDoc.exists || !matchesDoc.exists) return null;

      final userData = userDoc.data() ?? {};
      final matchesData = matchesDoc.data() ?? {};
      final nextMatch = _findNextMatch(userId, matchesData);
      if (nextMatch == null) return null;

      final opponentData = await _getClubData(nextMatch['opponentRef']);
      final matchData = MatchData(
        userClubName: userData['clubName']?.toString() ?? 'Unknown Club',
        opponentName: opponentData['name'] ?? 'Unknown Opponent',
        matchTime: nextMatch['matchTime'] ??
            DateTime.now().add(const Duration(hours: 1)),
        userAvatar: MatchData._parseInt(userData['avatar']),
        opponentAvatar: MatchData._parseInt(opponentData['avatar']),
      );

      _cache[cacheKey] = (
        DateTime.now(),
        {
          'userClubName': matchData.userClubName,
          'opponentName': matchData.opponentName,
          'matchTime': matchData.matchTime,
          'userAvatar': matchData.userAvatar,
          'opponentAvatar': matchData.opponentAvatar,
        }
      );

      return matchData;
    } catch (e) {
      debugPrint('Error fetching next match: $e');
      return null;
    }
  }

  Future<List<UpcomingMatch>> getUpcomingMatches() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    const cacheKey = 'upcomingMatches';
    final cached = _cache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.$1) < _cacheExpiration) {
      return (cached.$2 as List).map((m) => UpcomingMatch.fromMap(m)).toList();
    }

    try {
      final matchesDoc = await _firestore
          .collection('matches')
          .doc(userId)
          .get()
          .timeout(const Duration(seconds: 8));
      if (!matchesDoc.exists) return [];

      final matchesData = matchesDoc.data() ?? {};
      final upcomingMatches = _getAllUpcomingMatches(userId, matchesData);
      if (upcomingMatches.isNotEmpty) upcomingMatches.removeAt(0);

      final result = <UpcomingMatch>[];
      for (final match in upcomingMatches) {
        try {
          final opponentData = await _getClubData(match['opponentRef']);
          result.add(UpcomingMatch(
            opponentName: opponentData['name'] ?? 'Unknown',
            matchTime: match['matchTime'] ??
                DateTime.now().add(const Duration(hours: 1)),
            matchId: match['matchId']?.toString() ?? '',
          ));
        } catch (_) {
          continue;
        }
      }

      _cache[cacheKey] = (
        DateTime.now(),
        result
            .map((m) => {
                  'opponentName': m.opponentName,
                  'matchTime': m.matchTime,
                  'matchId': m.matchId,
                })
            .toList()
      );

      return result;
    } catch (e) {
      debugPrint('Error fetching upcoming matches: $e');
      return [];
    }
  }

  Map<String, dynamic>? _findNextMatch(
      String userId, Map<String, dynamic> matchesData) {
    try {
      final matches = matchesData['matches'] as Map<String, dynamic>? ?? {};
      for (int round = 1; round <= 18; round++) {
        final roundMatches = matches['round$round'] as List? ?? [];
        for (final match in roundMatches) {
          if (match['status'] != 'scheduled') continue;
          final homeTeam = match['homeTeam'] as DocumentReference?;
          final awayTeam = match['awayTeam'] as DocumentReference?;
          if (homeTeam?.id == userId || awayTeam?.id == userId) {
            return {
              ...match,
              'opponentRef': homeTeam?.id == userId ? awayTeam : homeTeam
            };
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  List<Map<String, dynamic>> _getAllUpcomingMatches(
      String userId, Map<String, dynamic> matchesData) {
    try {
      final matches = matchesData['matches'] as Map<String, dynamic>? ?? {};
      final now = DateTime.now();
      final upcomingMatches = <Map<String, dynamic>>[];

      for (final roundMatches in matches.values) {
        if (roundMatches is! List) continue;
        for (final match in roundMatches) {
          if (match is! Map<String, dynamic>) continue;
          final matchTimeStamp = match['matchTime'];
          if (matchTimeStamp == null) continue;
          final matchTime = switch (matchTimeStamp) {
            Timestamp ts => ts.toDate(),
            DateTime dt => dt,
            _ => null,
          };
          if (matchTime == null || !matchTime.isAfter(now)) continue;
          final homeTeam = match['homeTeam'] as DocumentReference?;
          final awayTeam = match['awayTeam'] as DocumentReference?;
          if (homeTeam?.id == userId || awayTeam?.id == userId) {
            upcomingMatches.add({
              ...match,
              'matchTime': matchTime,
              'opponentRef': homeTeam?.id == userId ? awayTeam : homeTeam,
            });
          }
        }
      }

      upcomingMatches.sort((a, b) =>
          (a['matchTime'] as DateTime).compareTo(b['matchTime'] as DateTime));
      return upcomingMatches;
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, String>> _getClubData(DocumentReference? clubRef) async {
    if (clubRef == null) return {'name': 'Unknown', 'avatar': '0'};
    final cacheKey = 'club_${clubRef.id}';
    final cached = _cache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.$1) < _cacheExpiration) {
      return Map<String, String>.from(cached.$2);
    }

    try {
      final doc = await clubRef.get().timeout(const Duration(seconds: 5));
      if (!doc.exists) return {'name': 'Unknown', 'avatar': '0'};
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final result = clubRef.path.startsWith('users/')
          ? {
              'name': data['clubName']?.toString() ?? 'Unknown Club',
              'avatar': data['avatar']?.toString() ?? '0'
            }
          : {'name': clubRef.id, 'avatar': '0'};
      _cache[cacheKey] = (DateTime.now(), result);
      return result;
    } catch (_) {
      return {'name': 'Unknown', 'avatar': '0'};
    }
  }

  void clearCache() => _cache.clear();
}
