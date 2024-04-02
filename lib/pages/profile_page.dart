import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String managerName = '';
  late String clubName = '';
  late String email = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final String userId = user.uid;
        managerName = await FirebaseFunctions.getManagerName(userId);
        clubName = await FirebaseFunctions.getClubName(userId);
        email = await FirebaseFunctions.getEmail(userId);

        setState(() {});
      }
    } catch (error) {
      print('Error loading user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Manager Name: $managerName'),
            Text('Club Name: $clubName'),
            Text('Email: $email'),
          ],
        ),
      ),
    );
  }
}
