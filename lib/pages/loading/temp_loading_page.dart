import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/functions/image_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/pages/loading/temp_login_page.dart';
import 'package:pocket_eleven/pages/loading/temp_register_page.dart';

class TempLoadingScreen extends StatefulWidget {
  const TempLoadingScreen({super.key});

  @override
  State<TempLoadingScreen> createState() => _TempLoadingScreenState();
}

class _TempLoadingScreenState extends State<TempLoadingScreen> {
  final bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    ImageLoader.precacheImages(context);

    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      _handleAuthentication();
    }
  }

  Future<void> _handleAuthentication() async {
    User? user = await FirebaseAuth.instance.authStateChanges().first;

    if (mounted) {
      if (user != null) {
        bool userHasClub = await AuthServices.userHasClub(user.email!);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  userHasClub ? const HomePage() : const TempRegisterPage(),
            ),
          );
        }
      } else {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const TempLoginPage()),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primaryColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: screenHeight * 0.25,
              child: Column(
                children: [
                  const Text(
                    'POCKET',
                    style: TextStyle(
                      fontSize: 44.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ELEVEN',
                    style: TextStyle(
                      fontSize: 44.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  if (_isLoading) const SizedBox(height: 20),
                  if (_isLoading)
                    LoadingAnimationWidget.waveDots(
                      color: AppColors.textEnabledColor,
                      size: 50,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
