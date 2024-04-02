import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/pages/club_create_page.dart';
import 'package:pocket_eleven/pages/main_menu.dart';
import 'firebase/firebase_options.dart';
import 'image_loader.dart';
import 'firebase/auth_functions.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(Builder(
    builder: (context) {
      print('preloading images...');
      ImageLoader.precacheImages(context);
      print('all assets loaded, launching the app...');

      return const MyApp();
    },
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<User?>(
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
      ),
    );
  }
}
