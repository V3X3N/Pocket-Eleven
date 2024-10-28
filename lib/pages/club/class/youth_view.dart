import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_players.dart';
import 'package:pocket_eleven/firebase/firebase_youth.dart';
import 'package:pocket_eleven/pages/club/widget/build_info.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfer_player_confirm_widget.dart';

class YouthView extends StatefulWidget {
  const YouthView({
    super.key,
  });

  @override
  State<YouthView> createState() => _YouthViewState();
}

class _YouthViewState extends State<YouthView> {
  int level = 1;
  int upgradeCost = 100000;
  double userMoney = 0;
  String? userId;
  DateTime? lastGeneratedTime;
  List<Player> _players = [];
  Player? _selectedPlayer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Map<String, dynamic> userData = await FirebaseFunctions.getUserData();
        level = await YouthFunctions.getYouthLevel(userId!);
        upgradeCost = FirebaseFunctions.calculateUpgradeCost(level);
        userMoney = (userData['money'] ?? 0).toDouble();
        lastGeneratedTime = userData['lastGeneratedTime']?.toDate();
        _generatePlayers();
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> increaseLevel() async {
    if (userId != null) {
      try {
        DocumentSnapshot userDoc =
            await FirebaseFunctions.getUserDocument(userId!);
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        double userMoney = (userData['money'] ?? 0).toDouble();
        int currentLevel = userData['youthLevel'] ?? 1;

        int currentUpgradeCost =
            FirebaseFunctions.calculateUpgradeCost(currentLevel);

        if (userMoney >= currentUpgradeCost) {
          int newLevel = currentLevel + 1;

          await YouthFunctions.updateYouthLevel(userId!, newLevel);

          await FirebaseFunctions.updateUserData(
              {'money': userMoney - currentUpgradeCost});

          setState(() {
            level = newLevel;
            upgradeCost = FirebaseFunctions.calculateUpgradeCost(newLevel);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Not enough money to upgrade the youth.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
            ),
          );
        }
      } catch (e) {
        debugPrint('Error upgrading youth: $e');
      }
    }
  }

  Future<void> _generatePlayers() async {
    if (lastGeneratedTime != null &&
        DateTime.now().difference(lastGeneratedTime!).inHours < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You can generate new players every 4 hours.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    List<Player> players = [];
    for (int i = 0; i < 5; i++) {
      Player player = await Player.generateRandomFootballer(
        minAge: 16,
        maxAge: 19,
        minOvr: 20,
        maxOvr: 40,
        isYouth: true,
      );
      players.add(player);
    }

    setState(() {
      _players = players;
      lastGeneratedTime = DateTime.now();
    });
  }

  void _onPlayerSelected(Player player) async {
    await PlayerFunctions.savePlayerToFirestore(context, player);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Player added to your club successfully'),
        duration: Duration(seconds: 1),
      ),
    );

    setState(() {
      _players.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Column(
        children: [
          Container(
            color: AppColors.primaryColor,
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.hoverColor,
                    border: Border.all(color: AppColors.borderColor, width: 1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: BuildInfo(
                    headerText: 'Youth Academy',
                    level: level,
                    upgradeCost: upgradeCost,
                    isUpgradeEnabled: userMoney >= upgradeCost,
                    onUpgradePressed: increaseLevel,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
          Expanded(
            child: _players.isNotEmpty
                ? Container(
                    margin: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: AppColors.hoverColor,
                      border:
                          Border.all(color: AppColors.borderColor, width: 1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        return TransferPlayerConfirmWidget(
                          player: player,
                          isSelected: _selectedPlayer == player,
                          onPlayerSelected: _onPlayerSelected,
                        );
                      },
                    ),
                  )
                : const Center(
                    child: Text(
                      'No players available at the moment.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
