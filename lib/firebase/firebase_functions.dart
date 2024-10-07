import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';

class FirebaseFunctions {
  /// Saves a user's data to the Firestore database.
  ///
  /// Parameters:
  ///   managerName (String): The name of the user's manager.
  ///   email (String): The email address of the user.
  ///   uid (String): The unique ID of the user.
  ///
  /// Returns:
  ///   Future<void>: A future that completes when the user's data has been saved.
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

  /// Retrieves the manager name associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to retrieve the manager name for.
  ///
  /// Returns:
  ///   Future<String>: A future that resolves to the manager name as a string, or an empty string if no manager name is found.
  static Future<String> getManagerName(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      return userDoc.get('managerName') ?? '';
    } catch (error) {
      debugPrint('Error loading manager name: $error');
      return '';
    }
  }

  /// Retrieves the club name associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to retrieve the club name for.
  ///
  /// Returns:
  ///   Future<String>: A future that resolves to the club name as a string, or an empty string if no club name is found.
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

  /// Retrieves the email associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to retrieve the email for.
  ///
  /// Returns:
  ///   Future<String>: A future that resolves to the email as a string, or an empty string if no email is found.
  static Future<String> getEmail(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      return userDoc.get('email') ?? '';
    } catch (error) {
      debugPrint('Error loading email: $error');
      return '';
    }
  }

  /// Updates the club name associated with the given user email.
  ///
  /// Parameters:
  ///   email (String): The email of the user to update the club name for.
  ///   clubName (String): The new club name to be updated.
  ///
  /// Returns:
  ///   Future<void>: A future that resolves when the update operation is complete.
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
        await userDoc.reference.update({
          'club': clubRef,
          'money': 3000000,
          'trainingLevel': 1,
          'medicalLevel': 1,
          'youthLevel': 1,
          'stadiumLevel': 1,
          'scoutingLevel': 1,
        });
      } else {
        debugPrint('User not found');
      }
    } catch (e) {
      debugPrint('Error creating club: $e');
    }
  }

  static Future<Map<String, dynamic>> getUserData() async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return {};

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      return querySnapshot.docs.first.data() as Map<String, dynamic>;
    } else {
      throw Exception('User not found');
    }
  }

  static Future<void> updateUserData(Map<String, dynamic> data) async {
    String? email = FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      await querySnapshot.docs.first.reference.update(data);
    } else {
      throw Exception('User not found');
    }
  }

  /// Retrieves the user document associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to retrieve the document for.
  ///
  /// Returns:
  ///   Future<DocumentSnapshot>: A future that resolves to the user document snapshot.
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

  /// Checks if a player can be added to a club.
  ///
  /// @param {String} clubId - The ID of the club.
  /// @return {Future<bool>} A Future that resolves to a boolean indicating if a player can be added.
  /// @throws {Error} If there is an error checking the player limit.
  static Future<bool> canAddPlayer(String clubId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('players')
          .where('club',
              isEqualTo: FirebaseFirestore.instance.doc('/clubs/$clubId'))
          .get();
      return snapshot.docs.length < 30;
    } catch (error) {
      debugPrint('Error checking player limit: $error');
      return false;
    }
  }

  /// Retrieves all players associated with a given club ID.
  ///
  /// Parameters:
  ///   clubId (String): The ID of the club.
  ///
  /// Returns:
  ///   Future<List<Player>>: A future that resolves to a list of Player objects associated with the given club ID.
  /// @throws {Error} If there is an error loading the players.
  static Future<List<Player>> getPlayersForClub(String clubId) async {
    try {
      DocumentReference clubRef =
          FirebaseFirestore.instance.doc('/clubs/$clubId');

      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('players')
          .where('club', isEqualTo: clubRef)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return Player(
          playerID:
              doc.id, // Ustawiamy playerID na doc.id (Firestore document ID)
          name: data['name'] ?? '',
          position: data['position'] ?? '',
          ovr: data['ovr'] ?? 0,
          age: data['age'] ?? 0,
          nationality: data['nationality'] ?? '',
          imagePath: data['imagePath'] ?? '',
          flagPath: data['flagPath'] ?? '',
          value: data['value'] ?? 0,
          salary: data['salary'] ?? 0,
          param1: data['param1'] ?? 0,
          param2: data['param2'] ?? 0,
          param3: data['param3'] ?? 0,
          param4: data['param4'] ?? 0,
          param1Name: data['param1Name'] ?? '',
          param2Name: data['param2Name'] ?? '',
          param3Name: data['param3Name'] ?? '',
          param4Name: data['param4Name'] ?? '',
          matchesPlayed: data['matchesPlayed'] ?? 0,
          goals: data['goals'] ?? 0,
          assists: data['assists'] ?? 0,
          yellowCards: data['yellowCards'] ?? 0,
          redCards: data['redCards'] ?? 0,
        );
      }).toList();
    } catch (error) {
      debugPrint('Error fetching players: $error');
      return [];
    }
  }

  /// Retrieves the club ID associated with the given user ID.
  ///
  /// @param {String} userId - The ID of the user.
  /// @return {Future<String>} A future that resolves to the club ID as a string, or an empty string if no club ID is found.
  /// @throws {Exception} If there is an error loading the club ID.
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

  /// Retrieves the stadium level associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to retrieve the stadium level for.
  ///
  /// Returns:
  ///   Future<int>: A future that resolves to the stadium level as an integer, or 1 if no stadium level is found.
  static Future<int> getStadiumLevel(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      return userDoc.get('stadiumLevel') ?? 1;
    } catch (error) {
      debugPrint('Error loading stadium level: $error');
      return 1;
    }
  }

  /// Updates the stadium level associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to update the stadium level for.
  ///   level (int): The new stadium level.
  ///
  /// Returns:
  ///   Future<void>: A future that resolves when the update operation is complete.
  static Future<void> updateStadiumLevel(String userId, int level) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      await userDoc.reference.update({'stadiumLevel': level});
    } catch (error) {
      debugPrint('Error updating stadium level: $error');
    }
  }

  /// Retrieves the medical level associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to retrieve the medical level for.
  ///
  /// Returns:
  ///   Future<int>: A future that resolves to the medical level as an integer, or 1 if no medical level is found.
  static Future<int> getMedicalLevel(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      return userDoc.get('medicalLevel') ?? 1;
    } catch (error) {
      debugPrint('Error loading medical level: $error');
      return 1;
    }
  }

  /// Updates the medical level associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to update the medical level for.
  ///   level (int): The new medical level.
  ///
  /// Returns:
  ///   Future<void>: A future that resolves when the update operation is complete.
  static Future<void> updateMedicalLevel(String userId, int level) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      await userDoc.reference.update({'medicalLevel': level});
    } catch (error) {
      debugPrint('Error updating medical level: $error');
    }
  }

  /// Retrieves the training level associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to retrieve the training level for.
  ///
  /// Returns:
  ///   Future<int>: A future that resolves to the training level as an training, or 1 if no training level is found.
  static Future<int> getTrainingLevel(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      return userDoc.get('trainingLevel') ?? 1;
    } catch (error) {
      debugPrint('Error loading training level: $error');
      return 1;
    }
  }

  /// Updates the training level associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to update the training level for.
  ///   level (int): The new training level.
  ///
  /// Returns:
  ///   Future<void>: A future that resolves when the update operation is complete.
  static Future<void> updateTrainingLevel(String userId, int level) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      await userDoc.reference.update({'trainingLevel': level});
    } catch (error) {
      debugPrint('Error updating training level: $error');
    }
  }

  /// Retrieves the youth level associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to retrieve the youth level for.
  ///
  /// Returns:
  ///   Future<int>: A future that resolves to the youth level as an integer, or 1 if no youth level is found.
  static Future<int> getYouthLevel(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      return userDoc.get('youthLevel') ?? 1;
    } catch (error) {
      debugPrint('Error loading youth level: $error');
      return 1;
    }
  }

  /// Updates the youth level associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to update the youth level for.
  ///   level (int): The new youth level.
  ///
  /// Returns:
  ///   Future<void>: A future that resolves when the update operation is complete.
  static Future<void> updateYouthLevel(String userId, int level) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      await userDoc.reference.update({'youthLevel': level});
    } catch (error) {
      debugPrint('Error updating youth level: $error');
    }
  }

  /// Retrieves the scouting level associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to retrieve the scouting level for.
  ///
  /// Returns:
  ///   Future<int>: A future that resolves to the scouting level as an integer, or 1 if no scouting level is found.
  static Future<int> getScoutingLevel(String userId) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      return userDoc.get('scoutingLevel') ?? 1;
    } catch (error) {
      debugPrint('Error loading scouting level: $error');
      return 1;
    }
  }

  /// Updates the scouting level associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to update the scouting level for.
  ///   level (int): The new scouting level.
  ///
  /// Returns:
  ///   Future<void>: A future that resolves when the update operation is complete.
  static Future<void> updateScoutingLevel(String userId, int level) async {
    try {
      DocumentSnapshot userDoc = await _getUserDocument(userId);
      await userDoc.reference.update({'scoutingLevel': level});
    } catch (error) {
      debugPrint('Error updating scouting level: $error');
    }
  }

  /// Retrieves the user document associated with the given user ID.
  ///
  /// Parameters:
  ///   userId (String): The ID of the user to retrieve the document for.
  ///
  /// Returns:
  ///   Future<DocumentSnapshot>: A future that resolves to the user document snapshot.
  static Future<DocumentSnapshot> getUserDocument(String userId) async {
    return FirebaseFirestore.instance.collection('users').doc(userId).get();
  }

  static int calculateUpgradeCost(int level) {
    return ((100000 * level) * 2) * 3;
  }

  static Stream<Map<String, dynamic>> getUserDataStream() {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((snapshot) => snapshot.data() ?? {});
    } else {
      return const Stream.empty();
    }
  }

  /// Saves a player to the Firestore database.
  ///
  /// This function takes a BuildContext and a dynamic player object as parameters.
  /// It checks if the user is logged in, and if so, adds the player to the 'players' collection in Firestore.
  /// The player object is expected to have the following properties:
  ///   - name
  ///   - position
  ///   - ovr
  ///   - age
  ///   - nationality
  ///   - imagePath
  ///   - flagPath
  ///   - value
  ///   - salary
  ///   - param1
  ///   - param2
  ///   - param3
  ///   - param4
  ///   - param1Name
  ///   - param2Name
  ///   - param3Name
  ///   - param4Name
  ///   - matchesPlayed
  ///   - goals
  ///   - assists
  ///   - yellowCards
  ///   - redCards
  ///
  /// If the player is added successfully, it displays a snack bar with a success message.
  /// If the user is not logged in, it displays a snack bar with an error message.
  ///
  /// Returns a Future<void> that completes when the operation is finished.
  static Future<void> savePlayerToFirestore(
      BuildContext context, dynamic player) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    final String userId = user.uid;
    final DocumentReference clubRef =
        await FirebaseFunctions.getClubReference(userId);

    final playersCollection = FirebaseFirestore.instance.collection('players');

    // Tworzymy nowy dokument w kolekcji i uzyskujemy jego ID
    final newPlayerRef =
        playersCollection.doc(); // Tworzymy referencję z automatycznym ID
    final playerId = newPlayerRef.id; // Uzyskujemy ID dokumentu

    await newPlayerRef.set({
      'id': playerId, // Dodajemy ID jako pole
      'name': player.name,
      'position': player.position,
      'ovr': player.ovr,
      'age': player.age,
      'nationality': player.nationality,
      'imagePath': player.imagePath,
      'flagPath': player.flagPath,
      'value': player.value,
      'salary': player.salary,
      'param1': player.param1,
      'param2': player.param2,
      'param3': player.param3,
      'param4': player.param4,
      'param1Name': player.param1Name,
      'param2Name': player.param2Name,
      'param3Name': player.param3Name,
      'param4Name': player.param4Name,
      'matchesPlayed': player.matchesPlayed,
      'goals': player.goals,
      'assists': player.assists,
      'yellowCards': player.yellowCards,
      'redCards': player.redCards,
      'club': clubRef,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Player added to your club successfully'),
          duration: Duration(seconds: 1)),
    );
  }
}
