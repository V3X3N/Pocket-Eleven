import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/play/widget/league_service.dart';

class LeagueView extends StatefulWidget {
  const LeagueView({
    required this.screenWidth,
    required this.screenHeight,
    super.key,
  });

  final double screenWidth;
  final double screenHeight;

  @override
  State<LeagueView> createState() => _LeagueViewState();
}

class _LeagueViewState extends State<LeagueView> {
  late Future<_LeagueData> _leagueDataFuture;

  @override
  void initState() {
    super.initState();
    _leagueDataFuture = _fetchLeagueData();
  }

  Future<_LeagueData> _fetchLeagueData() async {
    try {
      final doc = await LeagueService.getLeagueStandings();
      if (!doc.exists) {
        throw Exception('No league standings found');
      }

      final data = doc.data() as Map<String, dynamic>?;
      final standings = data?['standings'] as Map<String, dynamic>? ?? {};

      if (standings.isEmpty) {
        throw Exception('Empty standings data');
      }

      final clubNames = await LeagueService.fetchClubNames(standings.keys);
      final sortedStandings = LeagueService.sortStandings(standings, clubNames);

      return _LeagueData(
        standings: sortedStandings,
        clubNames: clubNames,
      );
    } catch (e) {
      throw Exception('Failed to load league data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final padding = size.width * 0.02;
    final margin = size.width * 0.04;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Container(
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          border: Border.all(color: AppColors.borderColor),
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FutureBuilder<_LeagueData>(
          future: _leagueDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState();
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            final data = snapshot.data;
            if (data == null || data.standings.isEmpty) {
              return _buildEmptyState();
            }

            return _buildStandingsTable(data, padding);
          },
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: LoadingAnimationWidget.waveDots(
        color: AppColors.textEnabledColor,
        size: 50,
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading standings',
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {
              _leagueDataFuture = _fetchLeagueData();
            }),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer,
            size: 48,
            color: AppColors.textEnabledColor,
          ),
          SizedBox(height: 16),
          Text(
            'No league standings available',
            style: TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStandingsTable(_LeagueData data, double padding) {
    return RepaintBoundary(
      child: Column(
        children: [
          _buildHeader(padding),
          Expanded(
            child: _buildStandingsList(data, padding),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double padding) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: const _HeaderRow(),
    );
  }

  Widget _buildStandingsList(_LeagueData data, double padding) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(padding),
      itemCount: data.standings.length,
      itemBuilder: (context, index) {
        final team = data.standings[index];
        final teamData = team.value;
        final teamName = data.clubNames[team.key] ?? team.key;

        return RepaintBoundary(
          child: _StandingRow(
            key: ValueKey(team.key),
            position: index + 1,
            teamName: teamName,
            played: teamData['matchesPlayed'] ?? 0,
            scored: teamData['goalsScored'] ?? 0,
            conceded: teamData['goalsConceded'] ?? 0,
            goalDifference: (teamData['goalsScored'] ?? 0) -
                (teamData['goalsConceded'] ?? 0),
            points: teamData['points'] ?? 0,
          ),
        );
      },
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: 32), // Position number space
        Expanded(flex: 3, child: _HeaderCell('Team')),
        Expanded(child: _HeaderCell('MP')),
        Expanded(child: _HeaderCell('GF')),
        Expanded(child: _HeaderCell('GA')),
        Expanded(child: _HeaderCell('GD')),
        Expanded(child: _HeaderCell('Pts')),
      ],
    );
  }
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: AppColors.textEnabledColor,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.position,
    required this.teamName,
    required this.played,
    required this.scored,
    required this.conceded,
    required this.goalDifference,
    required this.points,
    super.key,
  });

  final int position;
  final String teamName;
  final int played;
  final int scored;
  final int conceded;
  final int goalDifference;
  final int points;

  @override
  Widget build(BuildContext context) {
    final positionColor = _getPositionColor(position);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {/* Handle team selection */},
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildPositionIndicator(positionColor),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Text(
                    teamName,
                    style: const TextStyle(
                      color: AppColors.textEnabledColor,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                _buildStatCell(played.toString()),
                _buildStatCell(scored.toString()),
                _buildStatCell(conceded.toString()),
                _buildStatCell(goalDifference.toString(),
                    color: goalDifference > 0
                        ? Colors.green
                        : goalDifference < 0
                            ? Colors.red
                            : null),
                _buildStatCell(points.toString(), fontWeight: FontWeight.w600),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionIndicator(Color color) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          position.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCell(String value, {Color? color, FontWeight? fontWeight}) {
    return Expanded(
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            color: color ?? AppColors.textEnabledColor,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }

  Color _getPositionColor(int position) {
    if (position <= 4) return Colors.green;
    if (position <= 6) return Colors.orange;
    if (position >= 18) return Colors.red;
    return Colors.grey;
  }
}

class _LeagueData {
  final List<MapEntry<String, dynamic>> standings;
  final Map<String, String> clubNames;

  const _LeagueData({
    required this.standings,
    required this.clubNames,
  });
}
