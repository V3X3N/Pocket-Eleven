import 'package:flutter/material.dart';
import 'package:pocket_eleven/databases/database_helper.dart';
import 'package:pocket_eleven/pages/home_page.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  TextEditingController clubNameController = TextEditingController();
  bool showError = false;
  bool showLengthError = false;
  bool showSpecialCharacterError = false; // Flag for special characters

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/start_game_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                ElevatedButton(
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

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => const HomePage(),
                          ),
                        );
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
          ),
        ],
      ),
    );
  }
}
