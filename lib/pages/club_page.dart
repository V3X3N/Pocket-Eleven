import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/pages/club_stadium_page.dart';
import 'package:pocket_eleven/pages/club_training_page.dart';
import 'package:pocket_eleven/pages/club_medical_page.dart';

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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.hoverColor,
        toolbarHeight: 50,
        centerTitle: true,
        title: const Text(
          'Club Page',
          style: TextStyle(
            fontSize: 20,
            color: AppColors.textEnabledColor,
          ),
        ),
      ),
      body: Container(
        color: AppColors.primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                    height: 40,
                    width: 40,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            Container(
              height: 350,
              color: AppColors.primaryColor,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildListItem(
                    image: _clubStadiumImage,
                    text: 'Stadium',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClubStadiumPage(),
                        ),
                      );
                    },
                  ),
                  _buildListItem(
                    image: _clubTrainingImage,
                    text: 'Training',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClubTrainingPage(),
                        ),
                      );
                    },
                  ),
                  _buildListItem(
                    image: _clubMedicalImage,
                    text: 'Medical',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ClubMedicalPage(),
                        ),
                      );
                    },
                  ),
                  _buildListItem(
                    image: _clubYouthImage,
                    text: 'Youth',
                    onTap: () {
                      // Dodaj obsługę nawigacji do innych stron tutaj
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

  Widget _buildListItem({
    required Image image,
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8),
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
                padding: const EdgeInsets.all(8),
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
