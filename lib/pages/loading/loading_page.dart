import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/functions/image_loader.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/pages/loading/club_create_page.dart';
import 'package:pocket_eleven/pages/loading/main_menu.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  double _progress = 0.0;
  double _oldProgress = 0.0; // Track the old progress value
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
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadResources() async {
    await Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _updateProgress(0.3);
      });
    });

    await ImageLoader.precacheImages(context);

    setState(() {
      _updateProgress(0.9);
    });

    await Future.delayed(const Duration(seconds: 1));

    Future<void> checkAuthentication() async {
      User? user = await FirebaseAuth.instance.authStateChanges().first;
      if (user != null) {
        bool userHasClub = await AuthServices.userHasClub(user.email!);
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
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainMenu()),
        );
      }
    }

    await checkAuthentication();

    setState(() {
      _updateProgress(1.0);
    });

    await Future.delayed(const Duration(seconds: 3));
  }

  void _updateProgress(double newProgress) {
    _oldProgress = _progress;
    _progress = newProgress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
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
            child: const Center(
              child: Column(
                children: [
                  Text(
                    'POCKET',
                    style: TextStyle(
                      fontSize: 44.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                  Text(
                    'ELEVEN',
                    style: TextStyle(
                      fontSize: 44.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textEnabledColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: Center(
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: _oldProgress, end: _progress),
                duration: const Duration(seconds: 1),
                builder: (context, value, child) {
                  return CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 15.0,
                    percent: value,
                    center: Text(
                      '${(value * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    backgroundColor: AppColors.textEnabledColor,
                    progressColor: AppColors.secondaryColor,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
