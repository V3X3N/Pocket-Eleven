import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/functions/image_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/pages/loading/club_create_page.dart';
import 'package:pocket_eleven/pages/loading/main_menu.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart'; // Import loading_animation_widget

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  bool _isLoading = true;
  late Image _loadingImageAsset;

  @override
  void initState() {
    super.initState();
    _loadResources();
    _loadLoadingImage();
  }

  Future<void> _loadLoadingImage() async {
    _loadingImageAsset = Image.asset('assets/background/loading_bg.png');
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadResources() async {
    await Future.delayed(const Duration(seconds: 2));

    await ImageLoader.precacheImages(context);

    // You can still perform other actions here if needed

    await Future.delayed(const Duration(seconds: 1));

    _handleAuthentication();
  }

  Future<void> _handleAuthentication() async {
    User? user = await FirebaseAuth.instance.authStateChanges().first;

    if (mounted) {
      if (user != null) {
        bool userHasClub = await AuthServices.userHasClub(user.email!);
        if (mounted) {
          if (userHasClub) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ClubCreatePage()),
            );
          }
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainMenu()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _isLoading
              ? Center(
                  child: LoadingAnimationWidget.waveDots(
                    color: AppColors.textEnabledColor,
                    size: 50,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: _loadingImageAsset.image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: Center(
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
                  LoadingAnimationWidget.waveDots(
                    color: AppColors.textEnabledColor,
                    size: 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
