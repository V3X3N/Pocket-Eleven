import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/pages/loading/club_create_page.dart';
import 'package:pocket_eleven/pages/loading/login_page.dart';
import 'package:pocket_eleven/design/colors.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool _isLoading = true;
  late AssetImage _loadingImageAsset;

  @override
  void initState() {
    super.initState();
    _loadLoadingImage();
  }

  void _loadLoadingImage() {
    _loadingImageAsset = const AssetImage('assets/background/loading_bg.png');

    setState(() {
      _isLoading = false;
    });
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
                      image: _loadingImageAsset,
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
              child: Column(
                children: [
                  MaterialButton(
                    height: 40,
                    minWidth: 100,
                    color: AppColors.textEnabledColor,
                    onPressed: () {
                      // TODO: Implement Google auth.
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ClubCreatePage()),
                      );
                    },
                    child: const Text(
                      "Google",
                      style: TextStyle(color: Colors.blueAccent),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    height: 40,
                    minWidth: 100,
                    color: Colors.blueAccent,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      'Email',
                      style: TextStyle(color: AppColors.textEnabledColor),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    height: 40,
                    minWidth: 100,
                    color: Colors.red,
                    onPressed: () {
                      exit(0);
                    },
                    child: const Text(
                      'Exit',
                      style: TextStyle(color: AppColors.textEnabledColor),
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
}
