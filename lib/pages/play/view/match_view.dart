import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_league.dart';
import 'package:pocket_eleven/pages/play/services/match_service.dart';
import 'package:pocket_eleven/pages/play/widgets/action_button.dart';
import 'package:pocket_eleven/pages/play/widgets/club_info.dart';
import 'package:pocket_eleven/pages/play/widgets/empty_state.dart';
import 'package:pocket_eleven/pages/play/widgets/match_tile.dart';
import 'package:pocket_eleven/pages/play/widgets/vs_container.dart';

class MatchView extends StatelessWidget {
  const MatchView({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  final double screenWidth, screenHeight;

  static const _gradientColors = [
    AppColors.primaryColor,
    AppColors.secondaryColor,
    AppColors.accentColor,
  ];

  Widget _buildModernContainer({
    required Widget child,
    double? height,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.hoverColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.borderColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            offset: Offset(0, 8),
            blurRadius: 32,
          ),
          BoxShadow(
            color: Color(0x1AFFFFFF),
            offset: Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _gradientColors,
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.05),
          child: Column(
            children: [
              _buildModernContainer(
                height: screenHeight * 0.35,
                child: _NextMatchCard(screenWidth: screenWidth),
              ),
              SizedBox(height: screenWidth * 0.04),
              Expanded(
                child: _buildModernContainer(
                  child: _UpcomingMatchesList(screenWidth: screenWidth),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Next match card widget showing the upcoming match with simulation button.
class _NextMatchCard extends StatelessWidget {
  const _NextMatchCard({required this.screenWidth});
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<MatchData?>(
      future: MatchService().getNextMatch(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.textEnabledColor),
              strokeWidth: screenWidth * 0.008,
            ),
          );
        }

        return snapshot.hasData
            ? _MatchInfoContent(
                matchData: snapshot.data!, screenWidth: screenWidth)
            : EmptyState(
                icon: Icons.sports_soccer_rounded,
                message: "No upcoming matches",
                screenWidth: screenWidth,
              );
      },
    );
  }
}

/// Match information content displaying clubs and simulate button.
class _MatchInfoContent extends StatelessWidget {
  const _MatchInfoContent({
    required this.matchData,
    required this.screenWidth,
  });

  final MatchData matchData;
  final double screenWidth;

  Future<void> _handleSimulation() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await LeagueFunctions.simulateNextMatch(userId);
      }
    } catch (e) {
      debugPrint('Error simulating match: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.06),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(
            children: [
              Expanded(
                child: ClubInfo(
                  crestPath: 'assets/crests/crest_${matchData.userAvatar}.png',
                  clubName: matchData.userClubName,
                  screenWidth: screenWidth,
                ),
              ),
              VSContainer(screenWidth: screenWidth),
              Expanded(
                child: ClubInfo(
                  crestPath:
                      'assets/crests/crest_${matchData.opponentAvatar}.png',
                  clubName: matchData.opponentName,
                  screenWidth: screenWidth,
                ),
              ),
            ],
          ),
          ActionButton(
            text: "Simulate Match",
            icon: Icons.play_arrow_rounded,
            onPressed: _handleSimulation,
            screenWidth: screenWidth,
          ),
        ],
      ),
    );
  }
}

/// List of upcoming matches with optimized scrolling performance.
class _UpcomingMatchesList extends StatelessWidget {
  const _UpcomingMatchesList({required this.screenWidth});
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UpcomingMatch>>(
      future: MatchService().getUpcomingMatches(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor:
                  const AlwaysStoppedAnimation(AppColors.textEnabledColor),
              strokeWidth: screenWidth * 0.008,
            ),
          );
        }

        final matches = snapshot.data ?? [];

        return matches.isNotEmpty
            ? Padding(
                padding: EdgeInsets.all(screenWidth * 0.04),
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: matches.length,
                  separatorBuilder: (_, __) =>
                      SizedBox(height: screenWidth * 0.03),
                  itemBuilder: (context, index) => MatchTile(
                    opponentName: matches[index].opponentName,
                    matchTime: matches[index].matchTime,
                    screenWidth: screenWidth,
                    onTap: () => debugPrint(
                        'Match tapped: ${matches[index].opponentName}'),
                  ),
                ),
              )
            : EmptyState(
                icon: Icons.schedule_rounded,
                message: "No upcoming matches",
                screenWidth: screenWidth,
              );
      },
    );
  }
}
