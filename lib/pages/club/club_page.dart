import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/components/list_item.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/managers/user_manager.dart';
import 'package:pocket_eleven/pages/club/club_stadium_page.dart';
import 'package:pocket_eleven/pages/club/club_training_page.dart';
import 'package:pocket_eleven/pages/club/club_medical_page.dart';
import 'package:pocket_eleven/pages/club/club_youth_page.dart';

class ClubPage extends StatefulWidget {
  const ClubPage({super.key});

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  final Image _clubStadiumImage =
      Image.asset('assets/background/club_stadion.png');
  final Image _clubTrainingImage =
      Image.asset('assets/background/club_training.png');
  final Image _clubMedicalImage =
      Image.asset('assets/background/club_medical.png');
  final Image _clubYouthImage = Image.asset('assets/background/club_youth.png');
  late String clubName = '';

  Future<void> _loadUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;
        clubName = await FirebaseFunctions.getClubName(userId);
        await UserManager().loadAllUserData();
        setState(() {});
      }
    } catch (error) {
      debugPrint('Error loading user data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
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
                  vertical: screenHeight * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    clubName,
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  Image.asset(
                    'assets/crests/crest_1.png',
                    height: screenHeight * 0.05,
                    width: screenHeight * 0.05,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            Container(
              height: screenHeight * 0.4,
              color: AppColors.primaryColor,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  ListItem(
                    screenWidth: screenWidth,
                    image: _clubStadiumImage,
                    text: 'Stadium',
                    onTap: () => _navigateToPage(context,
                        ClubStadiumPage(onCurrencyChange: _loadUserData)),
                  ),
                  ListItem(
                    screenWidth: screenWidth,
                    image: _clubTrainingImage,
                    text: 'Training',
                    onTap: () => _navigateToPage(context,
                        ClubTrainingPage(onCurrencyChange: _loadUserData)),
                  ),
                  ListItem(
                    screenWidth: screenWidth,
                    image: _clubMedicalImage,
                    text: 'Medical',
                    onTap: () => _navigateToPage(context,
                        ClubMedicalPage(onCurrencyChange: _loadUserData)),
                  ),
                  ListItem(
                    screenWidth: screenWidth,
                    image: _clubYouthImage,
                    text: 'Youth',
                    onTap: () => _navigateToPage(context,
                        ClubYouthPage(onCurrencyChange: _loadUserData)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                decoration: const BoxDecoration(color: AppColors.primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    ).then((_) {
      _loadUserData();
    });
  }
}
