import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/firebase/firebase_stadium.dart';
import 'package:pocket_eleven/pages/club/widget/stadium_build.dart';
import 'package:pocket_eleven/pages/club/widget/stadium_info.dart';

class StadiumView extends StatefulWidget {
  const StadiumView({super.key});

  @override
  StadiumViewState createState() => StadiumViewState();
}

class StadiumViewState extends State<StadiumView> {
  int level = 1;
  int upgradeCost = 100000;
  double userMoney = 0;
  String? userId;
  bool isLoading = true;
  Map<String, int>? sectorLevel;

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
        level = await StadiumFunctions.getStadiumLevel(userId!);
        upgradeCost = FirebaseFunctions.calculateUpgradeCost(level);
        userMoney = (userData['money'] ?? 0).toDouble();

        sectorLevel = userData.containsKey('sectorLevel')
            ? Map<String, int>.from(userData['sectorLevel'])
            : null;

        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> increaseLevel() async {
    if (userMoney >= upgradeCost) {
      try {
        setState(() {
          level += 1;
          userMoney -= upgradeCost;
          upgradeCost = FirebaseFunctions.calculateUpgradeCost(level);
        });

        await StadiumFunctions.updateStadiumLevel(userId!, level);

        await FirebaseFunctions.updateUserData({
          'money': userMoney,
        });

        setState(() {});
      } catch (e) {
        debugPrint('Error upgrading stadium: $e');
      }
    } else {
      const snackBar = SnackBar(
        content: Text('Not enough money to upgrade the stadium.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 1),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
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
                vertical: screenHeight * 0.02,
              ),
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
                    child: StadiumInfo(
                      headerText: 'Stadium',
                      level: level,
                      upgradeCost: upgradeCost,
                      isUpgradeEnabled: userMoney >= upgradeCost,
                      onUpgradePressed: increaseLevel,
                      sectorLevel: sectorLevel,
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  const Expanded(child: StadiumBuild()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
