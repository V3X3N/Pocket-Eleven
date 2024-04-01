import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClubCreatePage extends StatefulWidget {
  const ClubCreatePage({Key? key}) : super(key: key);

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
                      // Get the entered club name
                      String clubName = _clubNameController.text;
                      // Check if user is logged in
                      if (AuthServices.isLoggedIn()) {
                        // Get current user email
                        String? email = AuthServices.getCurrentUserEmail();
                        if (email != null) {
                          // Update club name in database
                          await updateClubName(email, clubName);
                          // Navigate to Home Page
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                            (route) => false,
                          );
                        } else {
                          print('User email is null');
                        }
                      } else {
                        // User is not logged in, handle accordingly
                        print('User is not logged in');
                        // Example: Redirect to login page
                        // Navigator.pushReplacementNamed(context, '/login');
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

  Future<void> updateClubName(String email, String clubName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        await documentSnapshot.reference.update({'clubName': clubName});
        // Update successful
      } else {
        print('User not found');
      }
    } catch (e) {
      print('Error updating club name: $e');
      // Handle error
    }
  }

  @override
  void dispose() {
    _clubNameController.dispose();
    super.dispose();
  }
}
