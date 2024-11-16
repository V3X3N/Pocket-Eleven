import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/club/class/stadium_view.dart';
import 'package:pocket_eleven/pages/club/class/training_view.dart';
import 'package:pocket_eleven/pages/club/class/youth_view.dart';

class ClubPage extends StatefulWidget {
  const ClubPage({super.key});

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  int _selectedIndex = 0;
  String? clubName;
  Map<String, int>? sectorLevel;

  @override
  void initState() {
    super.initState();
    _getClubName();
  }

  Future<void> _getClubName() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        String userId = currentUser.uid;
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentReference userDocRef =
            firestore.collection('users').doc(userId);

        DocumentSnapshot userDoc = await userDocRef.get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          setState(() {
            clubName = userData['clubName'];
          });
          debugPrint('Club name: $clubName');

          if (!userData.containsKey('sectorLevel')) {
            Map<String, int> defaultSectorLevels = {
              'sector1': 1,
              'sector2': 1,
              'sector3': 1,
              'sector4': 1,
              'sector5': 1,
              'sector6': 1,
              'sector7': 1,
              'sector8': 1,
              'sector9': 1,
            };

            await userDocRef.update({
              'sectorLevel': defaultSectorLevels,
            });

            setState(() {
              sectorLevel = defaultSectorLevels;
            });

            debugPrint('Sector levels created with default values');
          } else {
            setState(() {
              sectorLevel = Map<String, int>.from(userData['sectorLevel']);
            });

            debugPrint('Sector levels: $sectorLevel');
          }
        } else {
          debugPrint('User document not found');
        }
      } else {
        debugPrint('No user is logged in');
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  void _onOptionSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: ReusableAppBar(appBarHeight: screenHeight * 0.07),
      body: Container(
        color: AppColors.primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OptionButton(
                    index: 0,
                    text: 'Stadium',
                    onTap: () => _onOptionSelected(0),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    selectedIndex: _selectedIndex,
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  OptionButton(
                    index: 1,
                    text: 'Training',
                    onTap: () => _onOptionSelected(1),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    selectedIndex: _selectedIndex,
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  OptionButton(
                    index: 2,
                    text: 'Youth',
                    onTap: () => _onOptionSelected(2),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    selectedIndex: _selectedIndex,
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: const [StadiumView(), TrainingView(), YouthView()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
