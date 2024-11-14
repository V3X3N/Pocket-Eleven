import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pocket_eleven/pages/play/widget/league_service.dart';
import 'package:pocket_eleven/pages/play/widget/standings_list.dart';

class LeagueView extends StatelessWidget {
  const LeagueView(
      {required this.screenWidth, required this.screenHeight, super.key});

  final double screenWidth;
  final double screenHeight;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Container(
        margin: EdgeInsets.all(screenWidth * 0.04),
        decoration: BoxDecoration(
          color: AppColors.hoverColor,
          border: Border.all(color: AppColors.borderColor, width: 1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        width: screenWidth,
        height: screenHeight,
        child: FutureBuilder<DocumentSnapshot>(
          future: LeagueService.getLeagueStandings(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: LoadingAnimationWidget.waveDots(
                  color: AppColors.textEnabledColor,
                  size: 50,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || !(snapshot.data!.exists)) {
              return const Center(child: Text('No league standings found.'));
            }

            Map<String, dynamic> standings =
                (snapshot.data!.data() as Map<String, dynamic>)['standings'] ??
                    {};

            return FutureBuilder<Map<String, String>>(
              future: LeagueService.fetchClubNames(standings.keys),
              builder: (context, namesSnapshot) {
                if (namesSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: LoadingAnimationWidget.waveDots(
                      color: AppColors.textEnabledColor,
                      size: 50,
                    ),
                  );
                } else if (namesSnapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${namesSnapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final clubNames = namesSnapshot.data ?? {};
                return StandingsList(
                  screenWidth: screenWidth,
                  screenHeight: screenHeight,
                  standings: standings,
                  clubNames: clubNames,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
