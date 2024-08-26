import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/design/colors.dart';

class YouthView extends StatefulWidget {
  const YouthView({
    super.key,
  });

  @override
  State<YouthView> createState() => _YouthViewState();
}

class _YouthViewState extends State<YouthView> {
  late Image _image;
  int level = 1;
  int upgradeCost = 100000;
  double userMoney = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    _image = Image.asset('assets/background/club_youth.png');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      Map<String, dynamic> userData = await FirebaseFunctions.getUserData();
      userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        level = await FirebaseFunctions.getYouthLevel(userId!);
        upgradeCost = FirebaseFunctions.calculateUpgradeCost(level);
        userMoney = (userData['money'] ?? 0).toDouble();
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

        if (userMoney >= upgradeCost) {
          setState(() {
            level = currentLevel + 1;
            upgradeCost = FirebaseFunctions.calculateUpgradeCost(level);
          });

          await FirebaseFunctions.updateYouthLevel(userId!, level);
          await FirebaseFunctions.updateUserData(
              {'money': userMoney - upgradeCost});
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

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _image.image,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.primaryColor,
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildYouthInfo(),
                  SizedBox(height: screenHeight * 0.04),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  const Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        "Our medical center is an essential part of our commitment to our players' health and fitness. "
                        "With a team of experienced doctors and therapists, we offer comprehensive medical care, "
                        "ensuring optimal conditions for rehabilitation and swift recovery from injuries. "
                        "It’s a place where we prioritize every aspect of our athletes' health, providing safety and support throughout their careers.",
                        style: TextStyle(
                          fontSize: 16.0,
                          color: AppColors.textEnabledColor,
                        ),
                      ),
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

  Widget _buildYouthInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Youth',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textEnabledColor,
                ),
              ),
              Text(
                'Level $level',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textEnabledColor,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            ElevatedButton(
              onPressed: userMoney >= upgradeCost ? increaseLevel : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.blueColor,
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
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
}
