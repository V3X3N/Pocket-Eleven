import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/pages/club_stadium_page.dart';
import 'package:pocket_eleven/pages/club_training_page.dart';
import 'package:pocket_eleven/pages/club_medical_page.dart';
import 'package:pocket_eleven/pages/club_youth_page.dart';
import 'package:pocket_eleven/user_manager.dart';
import 'package:unicons/unicons.dart';

class ClubPage extends StatefulWidget {
  const ClubPage({super.key});

  @override
  State<ClubPage> createState() => _ClubPageState();
}

class _ClubPageState extends State<ClubPage> {
  late Image _clubStadiumImage;
  late Image _clubTrainingImage;
  late Image _clubMedicalImage;
  late Image _clubYouthImage;
  late String clubName = '';

  Future<void> _loadUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;
        clubName = await FirebaseFunctions.getClubName(userId);
        // values
        await UserManager().loadMoney();
        await UserManager().loadTrainingPoints();
        await UserManager().loadMedicalPoints();
        await UserManager().loadYouthPoints();
        // Stadium
        await UserManager().loadStadiumLevel();
        await UserManager().loadStadiumUpgradeCost();
        // Training
        await UserManager().loadTrainingLevel();
        await UserManager().loadTrainingUpgradeCost();
        // Medical
        await UserManager().loadMedicalLevel();
        await UserManager().loadMedicalUpgradeCost();
        // Youth
        await UserManager().loadYouthLevel();
        await UserManager().loadYouthUpgradeCost();

        setState(() {});
      }
    } catch (error) {
      print('Error loading user data: $error');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _clubStadiumImage = Image.asset('assets/background/club_stadion.png');
    _clubTrainingImage = Image.asset('assets/background/club_training.png');
    _clubMedicalImage = Image.asset('assets/background/club_medical.png');
    _clubYouthImage = Image.asset('assets/background/club_youth.png');
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.07),
        child: AppBar(
          backgroundColor: AppColors.hoverColor,
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoRow(UniconsLine.no_entry,
                        UserManager.trainingPoints.toString()),
                    _buildInfoRow(UniconsLine.medkit,
                        UserManager.medicalPoints.toString()),
                    _buildInfoRow(UniconsLine.six_plus,
                        UserManager.youthPoints.toString()),
                    _buildInfoRow(UniconsLine.usd_circle,
                        UserManager.money.toStringAsFixed(0)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
                  _buildListItem(
                    screenWidth: screenWidth,
                    image: _clubStadiumImage,
                    text: 'Stadium',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubStadiumPage(
                            onCurrencyChange: () {
                              _loadUserData();
                            },
                          ),
                        ),
                      ).then((_) {
                        _loadUserData();
                      });
                    },
                  ),
                  _buildListItem(
                    screenWidth: screenWidth,
                    image: _clubTrainingImage,
                    text: 'Training',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubTrainingPage(
                            onCurrencyChange: () {
                              _loadUserData();
                            },
                          ),
                        ),
                      ).then((_) {
                        _loadUserData();
                      });
                    },
                  ),
                  _buildListItem(
                    screenWidth: screenWidth,
                    image: _clubMedicalImage,
                    text: 'Medical',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubMedicalPage(
                            onCurrencyChange: () {
                              _loadUserData();
                            },
                          ),
                        ),
                      ).then((_) {
                        _loadUserData();
                      });
                    },
                  ),
                  _buildListItem(
                    screenWidth: screenWidth,
                    image: _clubYouthImage,
                    text: 'Youth',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ClubYouthPage(
                            onCurrencyChange: () {
                              _loadUserData();
                            },
                          ),
                        ),
                      ).then((_) {
                        _loadUserData();
                      });
                    },
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

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textEnabledColor),
        const SizedBox(width: 5),
        Text(
          text,
          style: const TextStyle(
            fontSize: 20,
            color: AppColors.textEnabledColor,
          ),
        ),
      ],
    );
  }

  Widget _buildListItem({
    required double screenWidth,
    required Image image,
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: screenWidth * 0.5,
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image(
                image: image.image,
                fit: BoxFit.cover,
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  text,
                  style: const TextStyle(color: AppColors.textEnabledColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
