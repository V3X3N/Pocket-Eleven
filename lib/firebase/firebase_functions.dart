import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';

class FirebaseFunctions {
  static Future<void> saveUser(
      String managerName, String email, String uid) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'email': email, 'managerName': managerName});
    } catch (error) {
      debugPrint('Error saving user data: $error');
    }
  }

  static Future<String> getManagerName(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      return userDoc.get('managerName') ?? '';
    } catch (error) {
      debugPrint('Error loading manager name: $error');
      return '';
    }
  }

  static Future<String> getClubName(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('club')) {
        DocumentReference clubRef = userData['club'];
        DocumentSnapshot clubDoc = await clubRef.get();
        return clubDoc.get('clubName') ?? '';
      }
      return '';
    } catch (error) {
      debugPrint('Error loading club name: $error');
      return '';
    }
  }

  static Future<String> getEmail(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      return userDoc.get('email') ?? '';
    } catch (error) {
      debugPrint('Error loading email: $error');
      return '';
    }
  }

  static Future<void> updateClubName(String email, String clubName) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        Map<String, dynamic>? userData =
            documentSnapshot.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('club')) {
          DocumentReference clubRef = userData['club'];
          await clubRef.update({'clubName': clubName});
        }
      } else {
        debugPrint('User not found');
      }
    } catch (e) {
      debugPrint('Error updating club name: $e');
    }
  }

  static Future<void> createClub(String clubName, String managerEmail) async {
    try {
      DocumentReference clubRef = await FirebaseFirestore.instance
          .collection('clubs')
          .add({'clubName': clubName});

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: managerEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;
        await userDoc.reference.update({'club': clubRef});
      } else {
        debugPrint('User not found');
      }
    } catch (e) {
      debugPrint('Error creating club: $e');
    }
  }

  static Future<DocumentSnapshot> _getUserDocument(String userId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc;
  }

  static Future<DocumentReference> getClubReference(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('club')) {
        return userData['club'];
      }
      throw 'Club reference not found';
    } catch (error) {
      debugPrint('Error loading club reference: $error');
      rethrow;
    }
  }

  static Future<bool> canAddPlayer(String clubId) async {
    try {
      // Pobieranie ilości zawodników dla danego klubu
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('players')
          .where('club',
              isEqualTo: FirebaseFirestore.instance.doc('/clubs/$clubId'))
          .get();

      // Sprawdzenie, czy liczba zawodników nie przekracza 30
      return snapshot.docs.length < 30;
    } catch (error) {
      debugPrint('Error checking player limit: $error');
      return false;
    }
  }

  static Future<List<Player>> getPlayersForClub(String clubId) async {
    try {
      // Pobieranie dokumentu klubu
      DocumentReference clubRef =
          FirebaseFirestore.instance.doc('/clubs/$clubId');

      // Pobieranie zawodników, którzy należą do tego klubu
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('players')
          .where('club', isEqualTo: clubRef)
          .get();

      // Mapowanie wyników na listę obiektów Player
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Player(
          name: data['name'],
          position: data['position'],
          ovr: data['ovr'],
          age: data['age'],
          nationality: data['nationality'],
          imagePath: data['imagePath'],
          flagPath: data['flagPath'],
          value: data['value'],
          salary: data['salary'],
          param1: data['param1'],
          param2: data['param2'],
          param3: data['param3'],
          param4: data['param4'],
          param1Name: data['param1Name'],
          param2Name: data['param2Name'],
          param3Name: data['param3Name'],
          param4Name: data['param4Name'],
          matchesPlayed: data['matchesPlayed'],
          goals: data['goals'],
          assists: data['assists'],
          yellowCards: data['yellowCards'],
          redCards: data['redCards'],
        );
      }).toList();
    } catch (error) {
      debugPrint('Error fetching players: $error');
      return [];
    }
  }

  static Future<String> getClubId(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;

      if (userData != null && userData.containsKey('club')) {
        DocumentReference clubRef = userData['club'];
        return clubRef.id;
      }
      return '';
    } catch (error) {
      debugPrint('Error loading club id: $error');
      return '';
    }
  }
}
