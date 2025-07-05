import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:pocket_eleven/pages/loading/loginPage/temp_login_page.dart';
import 'package:pocket_eleven/pages/profile/widget/avatar_selector.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  String managerName = '';
  String clubName = '';
  String email = '';
  int avatar = 1;
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

        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (!mounted) return;

        if (userDoc.exists) {
          var userData = userDoc.data() as Map<String, dynamic>?;
          if (userData != null && !userData.containsKey('avatar')) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .update({
              'avatar': 1,
            });
          } else if (userData != null) {
            avatar = userData['avatar'] ?? 1;
          }

          managerName = await FirebaseFunctions.getManagerName(userId);
          clubName = await FirebaseFunctions.getClubName(userId);
          email = await FirebaseFunctions.getEmail(userId);
        }
      }
    } catch (error) {
      debugPrint('Error loading user data: $error');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _updateAvatar(int newAvatarIndex) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final String userId = user.uid;

      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'avatar': newAvatarIndex,
        });

        if (!mounted) return;
        setState(() {
          avatar = newAvatarIndex;
        });
      } catch (error) {
        debugPrint('Error updating avatar: $error');
      }
    }
  }

  Future<void> _logout() async {
    setState(() {
      _loading = true;
    });
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TempLoginPage()),
      );
    } catch (error) {
      debugPrint('Error signing out: $error');
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: _loading,
      opacity: 0.5,
      color: Colors.black,
      progressIndicator: LoadingAnimationWidget.waveDots(
        color: AppColors.textEnabledColor,
        size: 50,
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
                  border: Border.all(
                    width: 1,
                    color: AppColors.borderColor,
                  ),
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.hoverColor,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: 18,
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
        GestureDetector(
          onTap: () {
            debugPrint('Avatar container clicked!');
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (BuildContext context) {
                return AvatarSelector(
                  updateAvatar: _updateAvatar,
                );
              },
            );
          },
          child: Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              image: DecorationImage(
                image: AssetImage('assets/crests/crest_$avatar.png'),
                fit: BoxFit.cover,
              ),
              border: Border.all(
                width: 1,
                color: AppColors.borderColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          clubName,
          style: const TextStyle(
            color: AppColors.textEnabledColor,
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
            color: AppColors.textEnabledColor,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
