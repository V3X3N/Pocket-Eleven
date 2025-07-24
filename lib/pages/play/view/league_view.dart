import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/play/services/league_service.dart';
import 'package:pocket_eleven/pages/play/widgets/empty_state_widget.dart';
import 'package:pocket_eleven/pages/play/widgets/error_state_widget.dart';
import 'package:pocket_eleven/pages/play/widgets/standings_header.dart';
import 'package:pocket_eleven/pages/play/widgets/standings_row.dart';

class LeagueView extends StatefulWidget {
  const LeagueView({super.key});

  @override
  State<LeagueView> createState() => _LeagueViewState();
}

class _LeagueViewState extends State<LeagueView> {
  static const _gradientColors = [
    AppColors.primaryColor,
    AppColors.secondaryColor,
    AppColors.accentColor,
  ];

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
        throw Exception('League standings not found');
      }

      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) {
        throw Exception('Invalid standings data format');
      }

      final standings = data['standings'] as Map<String, dynamic>? ?? {};
      if (standings.isEmpty) {
        throw Exception('No standings data available');
      }

      final clubNames = await LeagueService.fetchClubNames(standings.keys);
      final sortedStandings = LeagueService.sortStandings(standings, clubNames);

      return _LeagueData(
        standings: sortedStandings,
        clubNames: clubNames,
      );
    } catch (e) {
      throw Exception('Failed to load league data: ${e.toString()}');
    }
  }

  void _retryLoading() {
    setState(() {
      _leagueDataFuture = _fetchLeagueData();
    });
  }

  Widget _buildModernContainer({required Widget child}) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.05),
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

  Widget _buildLoadingIndicator() {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: CircularProgressIndicator(
        valueColor: const AlwaysStoppedAnimation(AppColors.textEnabledColor),
        strokeWidth: screenWidth * 0.008,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _buildModernContainer(
            child: FutureBuilder<_LeagueData>(
              future: _leagueDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingIndicator();
                }

                if (snapshot.hasError) {
                  return ErrorStateWidget(
                    title: 'Error loading standings',
                    message: snapshot.error.toString(),
                    onRetry: _retryLoading,
                  );
                }

                final data = snapshot.data;
                if (data == null || data.standings.isEmpty) {
                  return const EmptyStateWidget(
                    title: 'No league standings available',
                    subtitle: 'Check back later for updated standings',
                  );
                }

                return _StandingsTable(data: data);
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Optimized standings table with efficient rendering
class _StandingsTable extends StatelessWidget {
  const _StandingsTable({required this.data});

  final _LeagueData data;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.hoverColor.withValues(alpha: 0.6),
              border: Border(
                bottom: BorderSide(
                  color: AppColors.borderColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
            child:
                const StandingsHeader(headers: StandingsHeader.defaultHeaders),
          ),
          Expanded(
            child: _StandingsList(data: data),
          ),
        ],
      ),
    );
  }
}

/// Optimized list view with proper key usage and minimal rebuilds
class _StandingsList extends StatelessWidget {
  const _StandingsList({required this.data});

  final _LeagueData data;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.hoverColor.withValues(alpha: 0.1),
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.all(screenWidth * 0.04),
        itemCount: data.standings.length,
        separatorBuilder: (context, index) => Container(
          height: 1,
          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.transparent,
                AppColors.borderColor.withValues(alpha: 0.2),
                Colors.transparent,
              ],
            ),
          ),
        ),
        itemBuilder: (context, index) {
          final team = data.standings[index];
          final teamData = team.value as Map<String, dynamic>;
          final teamName = data.clubNames[team.key] ?? team.key;

          return Container(
            decoration: BoxDecoration(
              color: index % 2 == 0
                  ? AppColors.hoverColor.withValues(alpha: 0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.borderColor.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
            child: StandingsRow(
              key: ValueKey(team.key),
              position: index + 1,
              teamName: teamName,
              matchesPlayed: teamData['matchesPlayed'] as int? ?? 0,
              goalsFor: teamData['goalsScored'] as int? ?? 0,
              goalsAgainst: teamData['goalsConceded'] as int? ?? 0,
              points: teamData['points'] as int? ?? 0,
              onTap: () => _handleTeamTap(team.key, teamName),
            ),
          );
        },
      ),
    );
  }

  void _handleTeamTap(String teamId, String teamName) {
    // Handle team selection - can be extended for navigation
    debugPrint('Selected team: $teamName (ID: $teamId)');
  }
}

/// Data model for league standings
class _LeagueData {
  const _LeagueData({
    required this.standings,
    required this.clubNames,
  });

  final List<MapEntry<String, dynamic>> standings;
  final Map<String, String> clubNames;
}
