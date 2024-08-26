import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/design/colors.dart';

class ClubStadiumPage extends StatefulWidget {
  final VoidCallback onCurrencyChange;

  const ClubStadiumPage({super.key, required this.onCurrencyChange});

  @override
  State<ClubStadiumPage> createState() => _ClubStadiumPageState();
}

class _ClubStadiumPageState extends State<ClubStadiumPage> {
  late Image _clubStadiumImage;
  int level = 1;
  int stadiumUpgradeCost = 100000;
  double userMoney = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    _clubStadiumImage = Image.asset('assets/background/club_stadion.png');
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Fetch user data and update state
      Map<String, dynamic> userData = await FirebaseFunctions.getUserData();
      userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        level = await FirebaseFunctions.getStadiumLevel(userId!);
        stadiumUpgradeCost =
            FirebaseFunctions.calculateStadiumUpgradeCost(level);
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
        // Fetch the most recent user data
        DocumentSnapshot userDoc =
            await FirebaseFunctions.getUserDocument(userId!);
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        double userMoney = (userData['money'] ?? 0).toDouble();
        int currentLevel = userData['stadiumLevel'] ?? 1;

        if (userMoney >= stadiumUpgradeCost) {
          setState(() {
            level = currentLevel + 1;
            stadiumUpgradeCost =
                FirebaseFunctions.calculateStadiumUpgradeCost(level);
          });

          // Update Firestore
          await FirebaseFunctions.updateStadiumLevel(userId!, level);
          await FirebaseFunctions.updateUserData(
              {'money': userMoney - stadiumUpgradeCost});

          widget.onCurrencyChange();
        } else {
          // Show an error or feedback to the user if they don't have enough money
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Not enough money to upgrade the stadium.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error upgrading stadium: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: ReusableAppBar(appBarHeight: screenHeight * 0.07),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 3 / 2,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: _clubStadiumImage.image,
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
                  _buildStadiumInfo(),
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
                        'The club stadium is the heart of our community, where fans gather '
                        'to cheer for their favorite teams. With a capacity of 50,000 seats, '
                        'it has hosted numerous memorable matches and events.',
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

  Widget _buildStadiumInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stadium',
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
              onPressed: userMoney >= stadiumUpgradeCost ? increaseLevel : null,
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
              'Cost: $stadiumUpgradeCost',
              style: TextStyle(
                color: userMoney >= stadiumUpgradeCost
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
