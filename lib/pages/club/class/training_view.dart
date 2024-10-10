import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/option_button.dart';
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
    // Zwiększenie wybranego parametru i aktualizacja w Firestore
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

    // Przeliczenie zależnych wartości: OVR, badge, value, salary
    player.updateDerivedAttributes();

    // Aktualizacja zawodnika w Firestore
    await FirebaseFunctions.updatePlayerData(
        player.playerID, player.toDocument());

    // Odświeżenie UI
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
                    padding: EdgeInsets.all(16.0),
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
                      onUpgradePressed: increaseLevel,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.04),

                  // Sekcja: Trening zawodników
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
                                  bottom: screenHeight * 0.01,
                                ),
                                padding: EdgeInsets.all(screenWidth * 0.03),
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
                                          screenHeight,
                                        ),
                                        _buildTrainingButton(
                                          player,
                                          'param2',
                                          player.param2Name,
                                          player.param2,
                                          screenWidth,
                                          screenHeight,
                                        ),
                                        _buildTrainingButton(
                                          player,
                                          'param3',
                                          player.param3Name,
                                          player.param3,
                                          screenWidth,
                                          screenHeight,
                                        ),
                                        _buildTrainingButton(
                                          player,
                                          'param4',
                                          player.param4Name,
                                          player.param4,
                                          screenWidth,
                                          screenHeight,
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

  Future<void> increaseLevel() async {
    if (userId != null) {
      try {
        DocumentSnapshot userDoc =
            await FirebaseFunctions.getUserDocument(userId!);
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        double userMoney = (userData['money'] ?? 0).toDouble();
        int currentLevel = userData['trainingLevel'] ?? 1;

        int currentUpgradeCost =
            FirebaseFunctions.calculateUpgradeCost(currentLevel);

        if (userMoney >= currentUpgradeCost) {
          int newLevel = currentLevel + 1;

          await FirebaseFunctions.updateTrainingLevel(userId!, newLevel);

          await FirebaseFunctions.updateUserData(
              {'money': userMoney - currentUpgradeCost});

          setState(() {
            level = newLevel;
            upgradeCost = FirebaseFunctions.calculateUpgradeCost(newLevel);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not enough money to upgrade the training.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error upgrading training: $e');
      }
    }
  }

  Widget _buildTrainingButton(
      Player player,
      String paramName,
      String paramLabel,
      int paramValue,
      double screenWidth,
      double screenHeight) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$paramLabel: $paramValue',
            style: TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: screenWidth * 0.030, // Skalowanie rozmiaru tekstu
            ),
          ),
          SizedBox(height: screenWidth * 0.02), // Proporcjonalny odstęp
          OptionButton(
            onTap: () => trainPlayer(player, paramName),
            screenWidth: screenWidth,
            screenHeight: screenHeight * 0.7,
            text: 'Train',
            fontSizeMultiplier: 0.7,
          ),
        ],
      ),
    );
  }
}
