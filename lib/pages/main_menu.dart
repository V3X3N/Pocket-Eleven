import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/pages/club_create_page.dart';
import 'package:pocket_eleven/pages/login_page.dart';
import 'package:pocket_eleven/pages/registration_page.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/loading_bg.jpg'),
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
            bottom: MediaQuery.of(context).size.height * 0.25,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                children: [
                  MaterialButton(
                    height: 40,
                    minWidth: 100,
                    color: Colors.white,
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
                            builder: (context) => const RegistrationPage()),
                      );
                    },
                    child: const Text(
                      'Register',
                      style: TextStyle(color: Colors.white),
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
                      'Log In',
                      style: TextStyle(color: Colors.white),
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
                      // TODO: Make sure it's proper way
                      exit(0);
                    },
                    child: const Text(
                      'Exit',
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
}
