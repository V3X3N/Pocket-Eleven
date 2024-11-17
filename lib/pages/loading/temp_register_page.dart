import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:pocket_eleven/firebase/firebase_club.dart';
import 'package:pocket_eleven/firebase/firebase_league.dart';
import 'package:pocket_eleven/pages/loading/temp_login_page.dart';
import 'package:pocket_eleven/pages/home_page.dart';

class TempRegisterPage extends StatefulWidget {
  const TempRegisterPage({super.key});

  @override
  State<TempRegisterPage> createState() => _TempRegisterPageState();
}

class _TempRegisterPageState extends State<TempRegisterPage> {
  TextEditingController clubnameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primaryColor,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _page(),
      ),
    );
  }

  Widget _page() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _gameText(),
            const SizedBox(height: 50),
            _inputField("Clubname", clubnameController),
            const SizedBox(height: 20),
            _inputField("Username", usernameController),
            const SizedBox(height: 20),
            _inputField("Email", emailController),
            const SizedBox(height: 20),
            _inputField("Password", passwordController, isPassword: true),
            const SizedBox(height: 20),
            _inputField("Confirm Password", confirmPasswordController,
                isPassword: true),
            const SizedBox(height: 50),
            _registerBtn(),
            const SizedBox(height: 20),
            _extraText(),
          ],
        ),
      ),
    );
  }

  Widget _gameText() {
    return const Column(
      children: [
        Text(
          'POCKET',
          style: TextStyle(
            fontSize: 44.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textEnabledColor,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'ELEVEN',
          style: TextStyle(
            fontSize: 44.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textEnabledColor,
          ),
        ),
      ],
    );
  }

  Widget _inputField(String hintText, TextEditingController controller,
      {isPassword = false}) {
    var border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Colors.white));

    return TextField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white),
        enabledBorder: border,
        focusedBorder: border,
      ),
      obscureText: isPassword,
    );
  }

  Widget _registerBtn() {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return OptionButton(
      index: 0,
      text: 'Sign up',
      onTap: () async {
        if (passwordController.text != confirmPasswordController.text) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passwords do not match')),
          );
          return;
        }

        String email = emailController.text;
        String password = passwordController.text;
        String username = usernameController.text;
        String clubName = clubnameController.text;

        try {
          await AuthServices.signupUser(
            email,
            password,
            username,
            clubName,
            context,
          );

          String userId = FirebaseAuth.instance.currentUser!.uid;
          DocumentReference userRef =
              FirebaseFirestore.instance.collection('users').doc(userId);

          Map<String, dynamic>? userData =
              await ClubFunctions.getUserData(userId);

          if (userData != null) {
            await ClubFunctions.initializeSectorLevels(userRef, userData);
          }

          DocumentSnapshot? availableLeague =
              await LeagueFunctions.findAvailableLeagueWithBot();

          if (availableLeague != null) {
            var leagueData = availableLeague.data() as Map<String, dynamic>;
            var clubs = List<DocumentReference>.from(leagueData['clubs']);

            DocumentReference? botToReplace;
            for (var club in clubs) {
              if (club.id.startsWith('Bot_')) {
                botToReplace = club;
                break;
              }
            }

            if (botToReplace != null) {
              clubs[clubs.indexOf(botToReplace)] = userRef;

              await availableLeague.reference.update({'clubs': clubs});

              await LeagueFunctions.replaceBotInMatches(
                  availableLeague, botToReplace.id, userRef.id);

              await userRef.update({'leagueRef': availableLeague.reference});

              debugPrint(
                  "Replaced bot ${botToReplace.id} with ${userRef.id} in league ${availableLeague.id}");
            }
          } else {
            String newLeagueId =
                await LeagueFunctions.createNewLeagueWithBots();
            debugPrint("Created new league with ID: $newLeagueId");

            DocumentReference newLeagueRef = FirebaseFirestore.instance
                .collection('leagues')
                .doc(newLeagueId);
            await userRef.update({'leagueRef': newLeagueRef});
          }

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } catch (e) {
          debugPrint('Error during signup process: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error during signup')),
          );
        }
      },
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );
  }

  Widget _extraText() {
    return InkWell(
      child: const Text(
        "Already with US? Login here!",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const TempLoginPage()),
        );
      },
    );
  }
}
