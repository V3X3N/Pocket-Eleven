import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/pages/club_create_page.dart';

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
                  SizedBox(
                    height: 40,
                    width: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement Google auth.
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ClubCreatePage()),
                        );
                      },
                      child: const Text('Google'),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      height: 40,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Implement Email Register/Login Page
                        },
                        child: const Text('Email'),
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  SizedBox(
                      height: 40,
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Make sure it's proper way
                          exit(0);
                        },
                        child: const Text('Exit'),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
