import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_league.dart';
import 'package:pocket_eleven/pages/play/match_service.dart';

class _ResponsiveCache {
  static final _values = <String, double>{};
  static double scale(double screenWidth, double size) => _values.putIfAbsent(
      '${screenWidth}_$size',
      () => size * (screenWidth / 375.0).clamp(0.8, 2.0));
}

class MatchView extends StatelessWidget {
  const MatchView(
      {super.key, required this.screenWidth, required this.screenHeight});

  final double screenWidth, screenHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ModernCard(
          height: screenHeight * 0.35,
          child: _NextMatchCard(screenWidth: screenWidth),
        ),
        Expanded(
          child: _ModernCard(
            child: _UpcomingMatchesList(screenWidth: screenWidth),
          ),
        ),
      ],
    );
  }
}

class _ModernCard extends StatelessWidget {
  const _ModernCard({required this.child, this.height});
  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.hoverColor.withValues(alpha: 0.9),
            AppColors.hoverColor.withValues(alpha: 0.7),
            AppColors.hoverColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.textEnabledColor.withValues(alpha: 0.05),
            blurRadius: 1,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: AppColors.textEnabledColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

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
            child: LoadingAnimationWidget.threeArchedCircle(
              color: AppColors.textEnabledColor,
              size: _ResponsiveCache.scale(screenWidth, 40),
            ),
          );
        }

        return snapshot.hasData
            ? _buildMatchInfo(context, snapshot.data!)
            : _buildEmptyState(context);
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
            size: _ResponsiveCache.scale(screenWidth, 60),
            color: AppColors.textEnabledColor.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 16),
          Text(
            "No upcoming matches",
            style: TextStyle(
              fontSize: _ResponsiveCache.scale(screenWidth, 18),
              color: AppColors.textEnabledColor.withValues(alpha: 0.8),
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
                screenWidth: screenWidth,
              ),
            ),
            _VSContainer(screenWidth: screenWidth),
            Expanded(
              child: _ClubInfo(
                crestPath:
                    'assets/crests/crest_${matchData.opponentAvatar}.png',
                clubName: matchData.opponentName,
                screenWidth: screenWidth,
              ),
            ),
          ],
        ),
        _SimulateButton(screenWidth: screenWidth),
      ],
    );
  }
}

class _ClubInfo extends StatelessWidget {
  const _ClubInfo({
    required this.crestPath,
    required this.clubName,
    required this.screenWidth,
  });
  final String crestPath, clubName;
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    final imageSize = _ResponsiveCache.scale(screenWidth, 80);

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
                    color: AppColors.primaryColor.withValues(alpha: 0.15),
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
                      color: AppColors.borderColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.sports_soccer_rounded,
                      size: imageSize * 0.5,
                      color: AppColors.textEnabledColor.withValues(alpha: 0.6),
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
              fontSize: _ResponsiveCache.scale(screenWidth, 14),
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

class _VSContainer extends StatelessWidget {
  const _VSContainer({required this.screenWidth});
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.borderColor.withValues(alpha: 0.3),
            AppColors.borderColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.textEnabledColor.withValues(alpha: 0.1)),
      ),
      child: Text(
        "VS",
        style: TextStyle(
          fontSize: _ResponsiveCache.scale(screenWidth, 24),
          fontWeight: FontWeight.bold,
          color: AppColors.textEnabledColor,
        ),
      ),
    );
  }
}

class _SimulateButton extends StatelessWidget {
  const _SimulateButton({required this.screenWidth});
  final double screenWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.green.withValues(alpha: 0.8), AppColors.green],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.green.withValues(alpha: 0.4),
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
                const Icon(Icons.play_arrow_rounded,
                    size: 24, color: AppColors.textEnabledColor),
                const SizedBox(width: 8),
                Text(
                  "Simulate Match",
                  style: TextStyle(
                    fontSize: _ResponsiveCache.scale(screenWidth, 16),
                    color: AppColors.textEnabledColor,
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
            child: LoadingAnimationWidget.threeArchedCircle(
              color: AppColors.textEnabledColor,
              size: _ResponsiveCache.scale(screenWidth, 40),
            ),
          );
        }

        return snapshot.hasData && snapshot.data!.isNotEmpty
            ? ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: snapshot.data!.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) => RepaintBoundary(
                  child: _MatchTile(
                      match: snapshot.data![index], screenWidth: screenWidth),
                ),
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: _ResponsiveCache.scale(screenWidth, 60),
                      color: AppColors.textEnabledColor.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "No upcoming matches",
                      style: TextStyle(
                        fontSize: _ResponsiveCache.scale(screenWidth, 18),
                        color:
                            AppColors.textEnabledColor.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.match, required this.screenWidth});
  final UpcomingMatch match;
  final double screenWidth;

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
            color: AppColors.buttonColor.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.borderColor.withValues(alpha: 0.3),
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
                    fontSize: _ResponsiveCache.scale(screenWidth, 16),
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
                    fontSize: _ResponsiveCache.scale(screenWidth, 12),
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
