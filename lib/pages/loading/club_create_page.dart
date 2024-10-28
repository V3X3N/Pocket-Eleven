import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/design/colors.dart';

class ClubCreatePage extends StatefulWidget {
  const ClubCreatePage({super.key});

  @override
  State<ClubCreatePage> createState() => _ClubCreatePageState();
}

class _ClubCreatePageState extends State<ClubCreatePage> {
  late TextEditingController _clubNameController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _clubNameController = TextEditingController();
    _loadLoadingImage();
  }

  Future<void> _loadLoadingImage() async {
    await precacheImage(
        const AssetImage('assets/background/loading_bg.png'), context);
  }

  Future<void> _createClub() async {
    setState(() {
      _isLoading = true;
    });

    try {
      String clubName = _clubNameController.text;
      String managerEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      await FirebaseFunctions.createClub(clubName, managerEmail);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background/loading_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.38,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  TextField(
                    controller: _clubNameController,
                    decoration: const InputDecoration(
                      hintText: 'Enter your club name here!',
                      filled: true,
                      fillColor: AppColors.textEnabledColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: MaterialButton(
                      color: Colors.blueAccent,
                      onPressed: _isLoading ? null : _createClub,
                      child: _isLoading
                          ? LoadingAnimationWidget.waveDots(
                              color: AppColors.textEnabledColor,
                              size: 50,
                            )
                          : const Text(
                              "Confirm",
                              style:
                                  TextStyle(color: AppColors.textEnabledColor),
                            ),
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
