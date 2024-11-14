import 'package:flutter/material.dart';
import 'standings_header.dart';
import 'standings_row.dart';
import 'league_service.dart';

class StandingsList extends StatelessWidget {
  const StandingsList({
    required this.screenWidth,
    required this.screenHeight,
    required this.standings,
    required this.clubNames,
    super.key,
  });

  final double screenWidth;
  final double screenHeight;
  final Map<String, dynamic> standings;
  final Map<String, String> clubNames;

  @override
  Widget build(BuildContext context) {
    final sortedStandings = LeagueService.sortStandings(standings, clubNames);

    return Column(
      children: [
        StandingsHeader(screenWidth: screenWidth),
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: ListView.builder(
              itemCount: sortedStandings.length,
              itemBuilder: (context, index) {
                final team = sortedStandings[index];
                final data = team.value;

                return StandingsRow(
                  teamName: clubNames[team.key] ?? team.key,
                  played: data['matchesPlayed'],
                  scored: data['goalsScored'],
                  conceded: data['goalsConceded'],
                  goalDifference: data['goalsScored'] - data['goalsConceded'],
                  points: data['points'],
                  screenHeight: screenHeight,
                  screenWidth: screenWidth,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
