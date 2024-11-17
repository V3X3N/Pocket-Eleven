import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_players.dart';
import 'package:pocket_eleven/firebase/firebase_training.dart';
import 'package:pocket_eleven/pages/club/widget/build_info.dart';
import 'package:pocket_eleven/models/player.dart';

class TrainingView extends StatefulWidget {
  const TrainingView({super.key});

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
  int basePlayerTrainingCost = 10000;
  double reductionCost = 0.0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPlayers();
  }

  Future<void> _loadUserData() async {
    try {
      userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Map<String, dynamic> userData = await FirebaseFunctions.getUserData();
        level = await TrainingFunctions.getTrainingLevel(userId!);
        upgradeCost = FirebaseFunctions.calculateUpgradeCost(level);
        userMoney = (userData['money'] ?? 0).toDouble();
        reductionCost = max(0, 100 - level * 5).toDouble();
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> _loadPlayers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final DocumentReference userRef =
          FirebaseFirestore.instance.collection('users').doc(user.uid);

      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('players')
          .where('userRef', isEqualTo: userRef)
          .get();

      final List<Player> loadedPlayers = snapshot.docs.map((doc) {
        return Player.fromDocument(doc);
      }).toList();

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

  Future<void> trainPlayer(Player player, String paramName) async {
    int trainingCost = max(basePlayerTrainingCost - 500 * (level - 1), 0);

    int currentParamValue;
    switch (paramName) {
      case 'param1':
        currentParamValue = player.param1;
        break;
      case 'param2':
        currentParamValue = player.param2;
        break;
      case 'param3':
        currentParamValue = player.param3;
        break;
      case 'param4':
        currentParamValue = player.param4;
        break;
      default:
        return;
    }

    if (userMoney >= trainingCost) {
      int newValue = min(currentParamValue + 1, 99);

      switch (paramName) {
        case 'param1':
          player.param1 = newValue;
          break;
        case 'param2':
          player.param2 = newValue;
          break;
        case 'param3':
          player.param3 = newValue;
          break;
        case 'param4':
          player.param4 = newValue;
          break;
      }

      player.updateDerivedAttributes();

      await PlayerFunctions.updatePlayerData(
          player.playerID, player.toDocument());

      await FirebaseFunctions.updateUserData({
        'money': userMoney - trainingCost,
      });

      setState(() {
        userMoney -= trainingCost;
      });
    } else {
      const snackBar = SnackBar(
        content: Text('Not enough money for training.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    }
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
                    padding: const EdgeInsets.all(16.0),
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
                  isLoading
                      ? Center(
                          child: LoadingAnimationWidget.waveDots(
                            color: AppColors.textEnabledColor,
                            size: 50,
                          ),
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
                                        fontSize: screenWidth * 0.045,
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
    if (level >= 5) {
      const snackBar = SnackBar(
        content: Text('Training is already at the maximum level (5).'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return;
    }

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

          await TrainingFunctions.updateTrainingLevel(userId!, newLevel);

          await FirebaseFunctions.updateUserData({
            'money': userMoney - currentUpgradeCost,
          });

          if (mounted) {
            setState(() {
              level = newLevel;
              upgradeCost = FirebaseFunctions.calculateUpgradeCost(newLevel);
              reductionCost = max(0, 100 - newLevel * 5).toDouble();
            });
          }
        } else {
          const snackBar = SnackBar(
            content: Text('Not enough money to upgrade the training.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 1),
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(snackBar);
          }
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
              fontSize: screenWidth * 0.030,
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          OptionButton(
            onTap: () {
              if (paramValue >= 99) {
                const snackBar = SnackBar(
                  content: Text(
                      'This attribute is already at the maximum level (99).'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                );
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else {
                trainPlayer(player, paramName);
              }
            },
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
