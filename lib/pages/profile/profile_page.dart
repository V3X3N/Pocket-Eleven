import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String managerName = '';
  String clubName = '';
  String email = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _loading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;
        managerName = await FirebaseFunctions.getManagerName(userId);
        clubName = await FirebaseFunctions.getClubName(userId);
        email = await FirebaseFunctions.getEmail(userId);
      }
    } catch (error) {
      debugPrint('Error loading user data: $error');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 0.5,
      color: Colors.black,
      progressIndicator: const CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
      ),
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 1,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                margin: const EdgeInsets.all(20.0),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: AppColors.hoverColor,
                ),
                height: 200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildClubInfo(),
                    _buildManagerInfo(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClubInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 90,
          width: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            image: const DecorationImage(
              image: AssetImage('assets/crests/crest_1.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          clubName,
          style: const TextStyle(
            color: AppColors.textDisabledColor,
            fontSize: 18,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildManagerInfo() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          managerName,
          style: const TextStyle(
            color: AppColors.textDisabledColor,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
