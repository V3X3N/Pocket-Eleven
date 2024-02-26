import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_eleven/databases/database_helper.dart';
import 'package:permission_handler/permission_handler.dart';
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
                  // Capture the context before the async operation
                  BuildContext currentContext = context;

                  await _requestStoragePermission(currentContext);

                  // Check if the context is still mounted before showing the dialog
                  if (!currentContext.mounted) return;

                  _showNewGameDialog(currentContext);
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

  Future<void> _requestStoragePermission(BuildContext context) async {
    var status = await Permission.storage.status;

    if (status == PermissionStatus.granted || status.isDenied) {
      var result = await Permission.storage.request();

      if (result.isDenied) {
        // Capture the context before the asynchronous operation
        BuildContext currentContext = context;

        // Check if the context is still mounted before showing the dialog
        if (!currentContext.mounted) return;

        await showDialog(
          context: currentContext,
          builder: (BuildContext context) {
            // Check if the context is still mounted before building the dialog
            if (!currentContext.mounted) return const SizedBox.shrink();

            return AlertDialog(
              title: const Text('Permission Required'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                      'Storage permission is required to save game data.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(currentContext).pop();
                      openAppSettings();
                    },
                    child: const Text('Open Settings'),
                  ),
                ],
              ),
            );
          },
        );
      }
    }
  }

  Future<void> _showNewGameDialog(BuildContext context) async {
    TextEditingController clubNameController = TextEditingController();
    bool showError = false;
    bool showLengthError = false;
    bool showSpecialCharacterError = false; // Flaga dla znaków specjalnych

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

                          // Sprawdzenie, czy nazwa klubu zawiera znaki specjalne
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
