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

  static Future<void> signupUser(
      String email, String password, String name, BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await FirebaseAuth.instance.currentUser!.updateDisplayName(name);
      await FirebaseAuth.instance.currentUser!.verifyBeforeUpdateEmail(email);
      await FirebaseFunctions.saveUser(name, email, userCredential.user!.uid);
      if (context.mounted) {
        scaffoldMessenger.showSnackBar(
            const SnackBar(content: Text('Registration Successful')));
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'weak-password') {
          scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Password Provided is too weak')));
        } else if (e.code == 'email-already-in-use') {
          scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Email Provided already Exists')));
        }
      }
    } catch (e) {
      if (context.mounted) {
        scaffoldMessenger
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    }
  }

  static Future<void> signinUser(
      String email, String password, BuildContext context) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      if (context.mounted) {
        scaffoldMessenger
            .showSnackBar(const SnackBar(content: Text('You are Logged in')));
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        if (e.code == 'user-not-found') {
          scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('No user Found with this Email')));
        } else if (e.code == 'wrong-password') {
          scaffoldMessenger.showSnackBar(
              const SnackBar(content: Text('Password did not match')));
        }
      }
    }
  }

  static Future<bool> userHasClub(String email) async {
    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      final List<DocumentSnapshot> documents = result.docs;
      if (documents.isNotEmpty) {
        final clubRef = documents.first.get('club');
        if (clubRef != null) {
          final clubSnapshot = await clubRef.get();
          return clubSnapshot.exists;
        }
      }
      return false;
    } catch (error) {
      debugPrint('Error checking if user has club: $error');
      return false;
    }
  }

  static Future<bool> isEmailRegistered(String email) async {
    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    final List<DocumentSnapshot> documents = result.docs;
    return documents.isNotEmpty;
  }
}
