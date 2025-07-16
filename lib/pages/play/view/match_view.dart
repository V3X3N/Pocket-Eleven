import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_league.dart';

// Optimized data models with freezed-like immutability
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

// Singleton service with optimized caching
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
        } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
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
    } catch (e) {
      return {'name': 'Unknown', 'avatar': '0'};
    }
  }
}

// Responsive utility with cached calculations
class ResponsiveHelper {
  static final _cache = <String, double>{};

  static double scale(BuildContext context, double size) {
    final screenWidth = MediaQuery.of(context).size.width;
    final key = '${screenWidth}_$size';
    return _cache.putIfAbsent(
        key, () => size * (screenWidth / 375.0).clamp(0.8, 2.0));
  }

  static EdgeInsets get padding => const EdgeInsets.all(16);
  static EdgeInsets get cardPadding => const EdgeInsets.all(20);
}

// Modern card decoration with glassmorphism effect
class ModernCard extends StatelessWidget {
  const ModernCard({super.key, required this.child, this.height});

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: ResponsiveHelper.padding,
      padding: ResponsiveHelper.cardPadding,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.hoverColor.withOpacity(0.9),
            AppColors.hoverColor.withOpacity(0.7),
            AppColors.hoverColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

// Main optimized match view
class MatchView extends StatelessWidget {
  const MatchView(
      {super.key, required this.screenWidth, required this.screenHeight});

  final double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ModernCard(
          height: screenHeight * 0.35,
          child: const _NextMatchCard(),
        ),
        Expanded(
          child: ModernCard(
            child: const _UpcomingMatchesList(),
          ),
        ),
      ],
    );
  }
}

// Optimized next match card
class _NextMatchCard extends StatelessWidget {
  const _NextMatchCard();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MatchData?>(
      future: MatchService().getNextMatch(),
      builder: (context, snapshot) => switch (snapshot.connectionState) {
        ConnectionState.waiting => Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: AppColors.textEnabledColor,
              size: ResponsiveHelper.scale(context, 40),
            ),
          ),
        _ => snapshot.hasData
            ? _buildMatchInfo(context, snapshot.data!)
            : _buildEmptyState(context),
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer_rounded,
            size: ResponsiveHelper.scale(context, 60),
            color: AppColors.textEnabledColor.withOpacity(0.6),
          ),
          const SizedBox(height: 16),
          Text(
            "No upcoming matches",
            style: TextStyle(
              fontSize: ResponsiveHelper.scale(context, 18),
              color: AppColors.textEnabledColor.withOpacity(0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchInfo(BuildContext context, MatchData matchData) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            Expanded(
                child: _ClubInfo(
              crestPath: 'assets/crests/crest_${matchData.userAvatar}.png',
              clubName: matchData.userClubName,
            )),
            _VSContainer(),
            Expanded(
                child: _ClubInfo(
              crestPath: 'assets/crests/crest_${matchData.opponentAvatar}.png',
              clubName: matchData.opponentName,
            )),
          ],
        ),
        _SimulateButton(),
      ],
    );
  }
}

// Optimized club info with cached image
class _ClubInfo extends StatelessWidget {
  const _ClubInfo({required this.crestPath, required this.clubName});

  final String crestPath, clubName;

  @override
  Widget build(BuildContext context) {
    final imageSize = ResponsiveHelper.scale(context, 80);

    return RepaintBoundary(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Hero(
            tag: crestPath,
            child: Container(
              height: imageSize,
              width: imageSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  crestPath,
                  fit: BoxFit.cover,
                  cacheHeight: imageSize.toInt(),
                  cacheWidth: imageSize.toInt(),
                  errorBuilder: (_, __, ___) => Container(
                    decoration: BoxDecoration(
                      color: AppColors.borderColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.sports_soccer_rounded,
                      size: imageSize * 0.5,
                      color: AppColors.textEnabledColor.withOpacity(0.6),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            clubName,
            style: TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: ResponsiveHelper.scale(context, 14),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Modern VS container
class _VSContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.borderColor.withOpacity(0.3),
            AppColors.borderColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Text(
        "VS",
        style: TextStyle(
          fontSize: ResponsiveHelper.scale(context, 24),
          fontWeight: FontWeight.bold,
          color: AppColors.textEnabledColor,
        ),
      ),
    );
  }
}

// Modern simulate button with animation
class _SimulateButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            HapticFeedback.lightImpact();
            try {
              final userId = FirebaseAuth.instance.currentUser?.uid;
              if (userId != null) {
                await LeagueFunctions.simulateNextMatch(userId);
              }
            } catch (e) {
              debugPrint('Error simulating match: $e');
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_arrow_rounded, size: 24, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  "Simulate Match",
                  style: TextStyle(
                    fontSize: ResponsiveHelper.scale(context, 16),
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Optimized upcoming matches list
class _UpcomingMatchesList extends StatelessWidget {
  const _UpcomingMatchesList();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UpcomingMatch>>(
      future: MatchService().getUpcomingMatches(),
      builder: (context, snapshot) => switch (snapshot.connectionState) {
        ConnectionState.waiting => Center(
            child: LoadingAnimationWidget.threeArchedCircle(
              color: AppColors.textEnabledColor,
              size: ResponsiveHelper.scale(context, 40),
            ),
          ),
        _ => snapshot.hasData && snapshot.data!.isNotEmpty
            ? ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => RepaintBoundary(
                  child: _MatchTile(match: snapshot.data![index]),
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: ResponsiveHelper.scale(context, 60),
                      color: AppColors.textEnabledColor.withOpacity(0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No upcoming matches",
                      style: TextStyle(
                        fontSize: ResponsiveHelper.scale(context, 18),
                        color: AppColors.textEnabledColor.withOpacity(0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
      },
    );
  }
}

// Modern match tile
class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.match});

  final UpcomingMatch match;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.lightImpact();
          debugPrint('Match tapped: ${match.opponentName}');
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.buttonColor.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  match.opponentName,
                  style: TextStyle(
                    fontSize: ResponsiveHelper.scale(context, 16),
                    color: AppColors.textEnabledColor,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.hoverColor.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatMatchTime(match.matchTime),
                  style: TextStyle(
                    fontSize: ResponsiveHelper.scale(context, 12),
                    color: AppColors.textEnabledColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatMatchTime(DateTime matchTime) {
    final difference = matchTime.difference(DateTime.now());
    return switch (difference.inDays) {
      > 0 => '${difference.inDays}d',
      _ => switch (difference.inHours) {
          > 0 => '${difference.inHours}h',
          _ => switch (difference.inMinutes) {
              > 0 => '${difference.inMinutes}m',
              _ => 'Now',
            },
        },
    };
  }
}
