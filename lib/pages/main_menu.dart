import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pocket_eleven/databases/database_helper.dart';
import 'package:pocket_eleven/pages/home_page.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/loading_bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _signInWithGoogle(context);
                },
                child: const Text('New Game'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Implement Load Game functionality
                  await _loadGame(context);
                },
                child: const Text('Load Game'),
              ),
              ElevatedButton(
                onPressed: () {
                  exit(0);
                },
                child: const Text('Leave Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleSignInAuthentication.idToken,
          accessToken: googleSignInAuthentication.accessToken,
        );

        await firebaseAuth.signInWithCredential(credential);
        // Proceed to the process of creating a new game after logging in
        await _showNewGameDialog(context);
      }
    } catch (error) {
      if (kDebugMode) {
        print("Error signing in with Google: $error");
      }
      // Here you can add code to handle login error
    }
  }

  Future<void> _showNewGameDialog(BuildContext context) async {
    TextEditingController clubNameController = TextEditingController();
    bool showError = false;
    bool showLengthError = false;
    bool showSpecialCharacterError = false; // Flag for special characters

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('New Game'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: clubNameController,
                    decoration: InputDecoration(
                      labelText: 'Club Name',
                      errorText: showError
                          ? 'Please enter a club name'
                          : (showLengthError
                              ? 'Club name is too long (max 20 characters)'
                              : (showSpecialCharacterError
                                  ? 'Club name cannot contain special characters'
                                  : null)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          String clubName = clubNameController.text.trim();

                          // Check if the club name contains special characters
                          RegExp regex = RegExp(r'[!@#%^&*(),.?":{}|<>]');
                          if (regex.hasMatch(clubName)) {
                            setState(() {
                              showSpecialCharacterError = true;
                            });
                            return;
                          }

                          if (clubName.isNotEmpty) {
                            if (clubName.length <= 20) {
                              await DatabaseHelper.instance
                                  .addNewClub(clubName, createdByPlayer: true);

                              if (!context.mounted) return;

                              Navigator.of(context).pop();

                              bool conditionForNavigation = true;
                              if (conditionForNavigation && context.mounted) {
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (context) => const HomePage(),
                                ));
                              }
                            } else {
                              setState(() {
                                showLengthError = true;
                              });
                            }
                          } else {
                            setState(() {
                              showError = true;
                            });
                          }
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _loadGame(BuildContext context) async {
    // Check if a club created by the player exists
    List<Map<String, dynamic>> clubs = await DatabaseHelper.instance.getClubs();
    bool playerClubExists =
        clubs.any((club) => club[DatabaseHelper.columnCreatedByPlayer] == 1);

    if (playerClubExists) {
      // Navigate to the HomePage
      bool conditionForNavigation = true;
      if (conditionForNavigation && context.mounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => const HomePage(),
        ));
      }
    } else {
      // Show a message or handle the case where the player's club doesn't exist
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('No Player Club Found'),
            content:
                const Text('You need to create a new game and a club first.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
