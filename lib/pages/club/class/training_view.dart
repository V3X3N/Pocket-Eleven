import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/club/widget/build_info.dart';
import 'package:pocket_eleven/models/player.dart';

class TrainingView extends StatefulWidget {
  const TrainingView({
    super.key,
  });

  @override
  State<TrainingView> createState() => _TrainingViewState();
}

class _TrainingViewState extends State<TrainingView> {
  int level = 1;
  int upgradeCost = 100000;
  double userMoney = 0;
  String? userId;
  List<Player> players = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPlayers(); // Load players for training
  }

  Future<void> _loadUserData() async {
    try {
      userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Map<String, dynamic> userData = await FirebaseFunctions.getUserData();
        level = await FirebaseFunctions.getTrainingLevel(userId!);
        upgradeCost = FirebaseFunctions.calculateUpgradeCost(level);
        userMoney = (userData['money'] ?? 0).toDouble();
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _loadPlayers() async {
    if (userId != null) {
      final String clubId = await FirebaseFunctions.getClubId(userId!);
      if (clubId.isNotEmpty) {
        final List<Player> loadedPlayers =
            await FirebaseFunctions.getPlayersForClub(clubId);
        setState(() {
          players = loadedPlayers;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> trainPlayer(Player player, String paramName) async {
    // Increase the selected parameter and update Firestore
    int newValue;
    switch (paramName) {
      case 'param1':
        newValue = min(player.param1 + 1, 99);
        player.param1 = newValue;
        break;
      case 'param2':
        newValue = min(player.param2 + 1, 99);
        player.param2 = newValue;
        break;
      case 'param3':
        newValue = min(player.param3 + 1, 99);
        player.param3 = newValue;
        break;
      case 'param4':
        newValue = min(player.param4 + 1, 99);
        player.param4 = newValue;
        break;
    }

    // Update the player in Firestore
    await FirebaseFunctions.updatePlayerData(
        player.playerID, player.toDocument());

    // Update UI
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        screenWidth * 0.04), // Proporcjonalny padding
                    decoration: BoxDecoration(
                      color: AppColors.hoverColor,
                      border:
                          Border.all(color: AppColors.borderColor, width: 1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: BuildInfo(
                      headerText: 'Training',
                      level: level,
                      upgradeCost: upgradeCost,
                      isUpgradeEnabled: userMoney >= upgradeCost,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // New Section: Training Players
                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : Expanded(
                          child: ListView.builder(
                            itemCount: players.length,
                            itemBuilder: (context, index) {
                              final player = players[index];
                              return Container(
                                margin: EdgeInsets.only(
                                  bottom: screenHeight *
                                      0.01, // Proporcjonalny margines
                                ),
                                padding: EdgeInsets.all(screenWidth *
                                    0.03), // Proporcjonalny padding
                                decoration: BoxDecoration(
                                  color: AppColors.hoverColor,
                                  border: Border.all(
                                      color: AppColors.borderColor, width: 1),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      player.name,
                                      style: TextStyle(
                                        fontSize: screenWidth *
                                            0.045, // Skalowanie rozmiaru tekstu
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textEnabledColor,
                                      ),
                                    ),
                                    SizedBox(height: screenHeight * 0.01),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildTrainingButton(
                                          player,
                                          'param1',
                                          player.param1Name,
                                          player.param1,
                                          screenWidth,
                                        ),
                                        _buildTrainingButton(
                                          player,
                                          'param2',
                                          player.param2Name,
                                          player.param2,
                                          screenWidth,
                                        ),
                                        _buildTrainingButton(
                                          player,
                                          'param3',
                                          player.param3Name,
                                          player.param3,
                                          screenWidth,
                                        ),
                                        _buildTrainingButton(
                                          player,
                                          'param4',
                                          player.param4Name,
                                          player.param4,
                                          screenWidth,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingButton(Player player, String paramName,
      String paramLabel, int paramValue, double screenWidth) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$paramLabel: $paramValue',
            style: TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: screenWidth * 0.035, // Skalowanie rozmiaru tekstu
            ),
          ),
          SizedBox(height: screenWidth * 0.02), // Proporcjonalny odstęp
          ElevatedButton(
            onPressed: () => trainPlayer(player, paramName),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.02,
                vertical: screenWidth * 0.02,
              ),
            ),
            child: Text(
              'Trenuj',
              style:
                  TextStyle(fontSize: screenWidth * 0.035), // Skalowanie tekstu
            ),
          ),
        ],
      ),
    );
  }
}
