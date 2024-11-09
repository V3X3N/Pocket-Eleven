import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';

class AuthServices {
  static bool isLoggedIn() {
    return FirebaseAuth.instance.currentUser != null;
  }

  static String? getCurrentUserID() {
    final User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  static Future<void> signupUser(String email, String password, String name,
      String clubName, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await userCredential.user!.updateDisplayName(name);
      await FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(email);

      await FirebaseFunctions.saveUser(
          name, email, userCredential.user!.uid, clubName);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration Successful')));
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password provided is too weak')));
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Email provided already exists')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  static Future<bool> userHasClub(String email) async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (result.docs.isNotEmpty) {
        final userDoc = result.docs.first;
        final Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;
        return userData.containsKey('clubName') &&
            (userData['clubName'] as String).isNotEmpty;
      }
      return false;
    } catch (error) {
      debugPrint('Error checking if user has club: $error');
      return false;
    }
  }

  static Future<void> signinUser(
      String email, String password, BuildContext context) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('You are logged in')));
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No user found with this email')));
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password did not match')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  static Future<bool> isEmailRegistered(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return result.docs.isNotEmpty;
  }
}
