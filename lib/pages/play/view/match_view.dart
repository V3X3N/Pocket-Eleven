import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_league.dart';
import 'package:pocket_eleven/pages/play/services/match_service.dart';
import 'package:pocket_eleven/pages/play/widgets/action_button.dart';
import 'package:pocket_eleven/pages/play/widgets/club_info.dart';
import 'package:pocket_eleven/pages/play/widgets/empty_state.dart';
import 'package:pocket_eleven/pages/play/widgets/loading_widget.dart';
import 'package:pocket_eleven/pages/play/widgets/match_tile.dart';
import 'package:pocket_eleven/pages/play/widgets/modern_card.dart';
import 'package:pocket_eleven/pages/play/widgets/vs_container.dart';

/// Main match view displaying next match and upcoming matches.
///
/// This widget provides:
/// - Next match card with simulation capability
/// - List of upcoming matches
/// - Responsive design for all screen sizes
/// - Optimized performance with cached widgets
class MatchView extends StatelessWidget {
  const MatchView({
    super.key,
    required this.screenWidth,
    required this.screenHeight,
  });

  final double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ModernCard(
          height: screenHeight * 0.35,
          child: _NextMatchCard(screenWidth: screenWidth),
        ),
        Expanded(
          child: ModernCard(
            child: _UpcomingMatchesList(screenWidth: screenWidth),
          ),
        ),
      ],
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
            child: ResponsiveLoadingWidget(screenWidth: screenWidth),
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
    return Column(
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
            child: ResponsiveLoadingWidget(screenWidth: screenWidth),
          );
        }

        final matches = snapshot.data ?? [];

        return matches.isNotEmpty
            ? ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: matches.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => MatchTile(
                  opponentName: matches[index].opponentName,
                  matchTime: matches[index].matchTime,
                  screenWidth: screenWidth,
                  onTap: () => debugPrint(
                      'Match tapped: ${matches[index].opponentName}'),
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
