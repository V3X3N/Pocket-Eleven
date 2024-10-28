import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_youth.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/transfers/widgets/nationality_selector.dart';
import 'package:pocket_eleven/pages/transfers/widgets/position_selector.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfer_player_confirm_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';

class ScoutingView extends StatefulWidget {
  const ScoutingView({super.key, required this.onCurrencyChange});
  final VoidCallback onCurrencyChange;

  @override
  State<ScoutingView> createState() => _ScoutingViewState();
}

class _ScoutingViewState extends State<ScoutingView> {
  int level = 1;
  int upgradeCost = 200000;
  double userMoney = 0;
  String? userId;
  String selectedPosition = 'LW';
  String selectedNationality = 'AUT';
  bool canScout = true;
  List<Player> scoutedPlayers = [];
  Player? _selectedPlayer;

  double get scoutingTimeReductionPercentage {
    if (level > 1) {
      return 7 * (level - 1);
    }
    return 0;
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSelectedPositionAndNationality();
    _loadScoutedPlayers();
  }

  Future<void> _loadUserData() async {
    try {
      userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Map<String, dynamic> userData = await FirebaseFunctions.getUserData();
        level = await YouthFunctions.getScoutingLevel(userId!);
        upgradeCost = FirebaseFunctions.calculateUpgradeCost(level);
        userMoney = (userData['money'] ?? 0).toDouble();
        setState(() {});
      }
    } catch (error) {
      debugPrint('Error loading user data: $error');
    }
  }

  Future<void> _loadSelectedPositionAndNationality() async {
    if (userId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId!)
            .get();
        Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>? ?? {};

        setState(() {
          selectedPosition = userData['selectedPosition'] ?? 'LW';
          selectedNationality = userData['selectedNationality'] ?? 'AUT';
        });
      } catch (error) {
        debugPrint('Error loading selected position and nationality: $error');
      }
    }
  }

  Future<void> _loadScoutedPlayers() async {
    if (userId != null) {
      try {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('scouting')
            .doc(userId!)
            .collection('players')
            .get();

        setState(() {
          scoutedPlayers =
              snapshot.docs.map((doc) => Player.fromDocument(doc)).toList();
        });
      } catch (error) {
        debugPrint('Error loading scouted players: $error');
      }
    }
  }

  Future<void> _saveScoutedPlayers() async {
    if (userId != null) {
      try {
        CollectionReference playersCollection = FirebaseFirestore.instance
            .collection('scouting')
            .doc(userId!)
            .collection('players');

        final batch = FirebaseFirestore.instance.batch();
        var snapshots = await playersCollection.get();
        for (var doc in snapshots.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();

        for (Player player in scoutedPlayers) {
          await playersCollection.add(player.toDocument());
        }
      } catch (error) {
        debugPrint('Error saving scouted players: $error');
      }
    }
  }

  Future<void> increaseLevel() async {
    if (userId != null) {
      try {
        DocumentSnapshot userDoc =
            await FirebaseFunctions.getUserDocument(userId!);
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        double userMoney = (userData['money'] ?? 0).toDouble();
        int currentLevel = userData['scoutingLevel'] ?? 1;

        int currentUpgradeCost =
            FirebaseFunctions.calculateUpgradeCost(currentLevel);

        if (userMoney >= currentUpgradeCost) {
          int newLevel = currentLevel + 1;

          await YouthFunctions.updateScoutingLevel(userId!, newLevel);
          await FirebaseFunctions.updateUserData(
              {'money': userMoney - currentUpgradeCost});

          setState(() {
            level = newLevel;
            upgradeCost = FirebaseFunctions.calculateUpgradeCost(newLevel);
          });

          widget.onCurrencyChange();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not enough money to upgrade scouting level.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (error) {
        debugPrint('Error upgrading scouting level: $error');
      }
    }
  }

  Future<void> generatePlayersAfterCooldown() async {
    List<Player> newPlayers = [];
    for (int i = 0; i < 3; i++) {
      Player player = await Player.generateRandomFootballer(
        nationality: selectedNationality,
        position: selectedPosition,
      );
      newPlayers.add(player);
    }
    setState(() {
      scoutedPlayers = newPlayers;
    });
    await _saveScoutedPlayers();
  }

  Future<void> _saveSelectedPosition(String position) async {
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId!)
          .update({'selectedPosition': position});
    }
  }

  Future<void> _saveSelectedNationality(String nationality) async {
    if (userId != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId!)
          .update({'selectedNationality': nationality});
    }
  }

  Widget _buildScoutInfo(double screenWidth, double screenHeight) {
    final reductionPercentage = scoutingTimeReductionPercentage;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Scouting',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textEnabledColor,
                ),
              ),
              Tooltip(
                waitDuration: const Duration(seconds: 1),
                message: 'Current time reduction: $reductionPercentage%',
                decoration: BoxDecoration(
                  color: AppColors.hoverColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Text(
                  'Level $level',
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textEnabledColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            GestureDetector(
              onTap: userMoney >= upgradeCost ? increaseLevel : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(
                  vertical: screenHeight * 0.01,
                  horizontal: screenWidth * 0.05,
                ),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: AppColors.borderColor),
                  color: userMoney >= upgradeCost
                      ? AppColors.blueColor
                      : AppColors.buttonColor,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: userMoney >= upgradeCost
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 6,
                          )
                        ]
                      : [],
                ),
                child: const Center(
                  child: Text(
                    'Upgrade',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: AppColors.textEnabledColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Cost: $upgradeCost',
              style: TextStyle(
                color: userMoney >= upgradeCost
                    ? AppColors.green
                    : AppColors.textEnabledColor,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    final List<String> nationalities = [
      'AUT',
      'BEL',
      'ENG',
      'ESP',
      'FRA',
      'GER',
      'ITA',
      'POL',
      'TUR',
      'USA',
      'BRA',
      'JPN',
    ];

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: AppColors.hoverColor,
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildScoutInfo(screenWidth, screenHeight),
                  SizedBox(height: screenHeight * 0.04),
                  const Text(
                    'Select Position',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  PositionSelector(
                    selectedPosition: selectedPosition,
                    canScout: canScout,
                    onPositionChange: (position) {
                      setState(() {
                        selectedPosition = position;
                      });
                      _saveSelectedPosition(position);
                    },
                  ),
                  SizedBox(height: screenHeight * 0.04),
                  const Text(
                    'Select Nationality',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  NationalitySelector(
                    selectedNationality: selectedNationality,
                    canScout: canScout,
                    onNationalityChange: (nationality) {
                      setState(() {
                        selectedNationality = nationality;
                      });
                      _saveSelectedNationality(nationality);
                    },
                    nationalities: nationalities,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  if (scoutedPlayers.isNotEmpty)
                    Column(
                      children: scoutedPlayers
                          .map((player) => TransferPlayerConfirmWidget(
                                player: player,
                                isSelected: _selectedPlayer == player,
                                onPlayerSelected: (selectedPlayer) {
                                  setState(() {
                                    _selectedPlayer = selectedPlayer;
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  SizedBox(height: screenHeight * 0.02),
                  GestureDetector(
                    onTap: generatePlayersAfterCooldown,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                        horizontal: screenWidth * 0.2,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          width: 1,
                          color: AppColors.textEnabledColor,
                        ),
                        color: canScout
                            ? AppColors.blueColor
                            : AppColors.buttonColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: canScout
                            ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 4),
                                  blurRadius: 6,
                                )
                              ]
                            : [],
                      ),
                      child: const Center(
                        child: Text(
                          'Scout',
                          style: TextStyle(
                            fontSize: 20.0,
                            color: AppColors.textEnabledColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
