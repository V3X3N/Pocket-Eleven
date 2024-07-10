import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/pages/club_create_page.dart';
import 'package:pocket_eleven/pages/main_menu.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';

class AuthCheckerPage extends StatelessWidget {
  const AuthCheckerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: FirebaseAuth.instance.authStateChanges().first,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else {
          final User? user = snapshot.data;
          if (user != null) {
            return FutureBuilder<bool>(
              future: AuthServices.userHasClub(user.email!),
              builder: (context, clubSnapshot) {
                if (clubSnapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else {
                  final bool userHasClub = clubSnapshot.data ?? false;
                  if (userHasClub) {
                    return const HomePage();
                  } else {
                    return const ClubCreatePage();
                  }
                }
              },
            );
          } else {
            return const MainMenu();
          }
        }
      },
    );
  }
}
