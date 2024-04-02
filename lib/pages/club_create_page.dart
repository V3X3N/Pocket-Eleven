import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/pages/home_page.dart';

class ClubCreatePage extends StatefulWidget {
  const ClubCreatePage({super.key});

  @override
  State<ClubCreatePage> createState() => _ClubCreatePageState();
}

class _ClubCreatePageState extends State<ClubCreatePage> {
  bool _isLoading = true;
  late Image _loadingImage;
  late TextEditingController _clubNameController;

  @override
  void initState() {
    super.initState();
    _loadLoadingImage();
    _clubNameController = TextEditingController();
  }

  void _loadLoadingImage() {
    _loadingImage = Image.asset('assets/background/loading_bg.png');

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
                      image: _loadingImage.image,
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
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'ELEVEN',
                    style: TextStyle(
                      fontSize: 44.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
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
                      fillColor: Colors.white70,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  MaterialButton(
                    height: 40,
                    minWidth: 100,
                    color: Colors.blueAccent,
                    onPressed: () async {
                      String clubName = _clubNameController.text;
                      if (AuthServices.isLoggedIn()) {
                        String? userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId != null) {
                          String? email =
                              await FirebaseFunctions.getEmail(userId);
                          await FirebaseFunctions.updateClubName(
                              email, clubName);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                            (route) => false,
                          );
                        }
                      } else {
                        print('User is not logged in');
                      }
                    },
                    child: const Text(
                      "Confirm",
                      style: TextStyle(color: Colors.white),
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

  @override
  void dispose() {
    _clubNameController.dispose();
    super.dispose();
  }
}
