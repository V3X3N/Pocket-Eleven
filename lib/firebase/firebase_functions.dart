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
      BuildContext context, Player player) async {
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

    final newPlayerRef = playersCollection.doc();
    final playerId = newPlayerRef.id;

    await newPlayerRef.set({
      'id': playerId,
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
      'isYouth': player.isYouth,
      'club': clubRef,
      'createdAt': FieldValue.serverTimestamp(), // Timestamp for cooldown
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Player added to your club successfully'),
          duration: Duration(seconds: 1)),
    );
  }

  static Future<void> updatePlayerData(
      String playerID, Map<String, dynamic> playerData) async {
    try {
      final DocumentReference playerDoc =
          FirebaseFirestore.instance.collection('players').doc(playerID);
      await playerDoc.update(playerData);
    } catch (e) {
      debugPrint('Error updating player data: $e');
    }
  }

  static Future<void> createClub(String clubName, String managerEmail) async {
    try {
      // Tworzenie nowego klubu w Firestore
      DocumentReference clubRef = await FirebaseFirestore.instance
          .collection('clubs')
          .add({'clubName': clubName});

      // Wyszukiwanie użytkownika po emailu
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: managerEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot userDoc = querySnapshot.docs.first;

        // Aktualizacja informacji o użytkowniku, przypisanie nowego klubu
        await userDoc.reference.update({
          'club': clubRef,
          'money': 3000000,
          'trainingLevel': 1,
          'medicalLevel': 1,
          'youthLevel': 1,
          'stadiumLevel': 1,
          'scoutingLevel': 1,
        });

        // Znajdź ligę, która ma boty do zastąpienia
        DocumentSnapshot? availableLeague = await _findAvailableLeagueWithBot();

        if (availableLeague != null) {
          // Pobranie danych ligi
          var leagueData = availableLeague.data() as Map<String, dynamic>;
          var clubs = List<String>.from(leagueData['clubs']);

          // Znalezienie bota do zamiany
          String? botToReplace;
          for (var club in clubs) {
            if (club.startsWith('Bot_')) {
              botToReplace = club;
              break;
            }
          }

          if (botToReplace != null) {
            // Zamieniamy bota na nowy klub
            clubs[clubs.indexOf(botToReplace)] = clubName;

            // Aktualizujemy listę klubów w lidze
            await availableLeague.reference.update({
              'clubs': clubs,
            });

            // Zastąp bota we wszystkich meczach
            await _replaceBotInMatches(availableLeague, botToReplace, clubName);

            print(
                "Zastąpiono bota $botToReplace klubem $clubName w lidze ${availableLeague.id}");
          } else {
            print("Nie znaleziono bota do zamiany.");
          }
        } else {
          // Jeśli nie ma dostępnej ligi z botami, stwórz nową ligę
          String newLeagueId = await _createNewLeagueWithBots(clubName);
          print("Utworzono nową ligę z ID: $newLeagueId");
        }
      } else {
        debugPrint('User not found');
      }
    } catch (e) {
      debugPrint('Error creating club: $e');
    }
  }

  // Sprawdzamy, czy klub użytkownika jest w lidze
  static Future<bool> isClubInLeague(String email) async {
    // Pobierz klub użytkownika na podstawie emaila
    var clubSnapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .where('managerEmail', isEqualTo: email)
        .limit(1)
        .get();

    if (clubSnapshot.docs.isNotEmpty) {
      var clubData = clubSnapshot.docs.first.data() as Map<String, dynamic>;
      var leagueId = clubData['leagueId'];
      return leagueId != null; // Sprawdzamy, czy klub ma przypisaną ligę
    }
    return false;
  }

  // Znajduje dostępną ligę, która ma boty do zastąpienia
  static Future<DocumentSnapshot?> _findAvailableLeague() async {
    var leagues = await FirebaseFirestore.instance
        .collection('leagues')
        .where('clubs_count', isEqualTo: 10) // Liga pełna, ale może mieć boty
        .get();

    // Sprawdzamy, czy istnieje liga z botami do zastąpienia
    for (var league in leagues.docs) {
      var leagueData = league.data() as Map<String, dynamic>;
      var clubs = List<String>.from(leagueData['clubs']);
      if (clubs.any((club) => club.startsWith('Bot_'))) {
        return league; // Znaleźliśmy ligę z botami
      }
    }

    return null; // Nie znaleziono ligi z botami
  }

  // Przypisuje klub do ligi lub tworzy nową, jeśli nie ma miejsca
  static Future<void> assignClubToLeague(String email) async {
    // Pobieramy klub użytkownika
    var clubSnapshot = await FirebaseFirestore.instance
        .collection('clubs')
        .where('managerEmail', isEqualTo: email)
        .limit(1)
        .get();

    if (clubSnapshot.docs.isNotEmpty) {
      var clubDoc = clubSnapshot.docs.first;
      var clubData = clubDoc.data() as Map<String, dynamic>;
      var clubName = clubData['clubName'];

      // Sprawdź dostępne ligi
      DocumentSnapshot? availableLeague = await _findAvailableLeagueWithBot();

      if (availableLeague != null) {
        var leagueData = availableLeague.data() as Map<String, dynamic>;
        var clubs = List<String>.from(leagueData['clubs']);

        // Znajdź klub, który jest botem
        String? botToReplace;
        for (var club in clubs) {
          if (club.startsWith('Bot_')) {
            botToReplace = club;
            break;
          }
        }

        if (botToReplace != null) {
          // Zamieniamy bota na nowy klub
          clubs[clubs.indexOf(botToReplace)] = clubName;

          // Aktualizujemy listę klubów w lidze
          await availableLeague.reference.update({
            'clubs': clubs,
          });

          // Zastąp bota we wszystkich meczach
          await _replaceBotInMatches(availableLeague, botToReplace, clubName);

          print(
              "Zastąpiono bota $botToReplace klubem $clubName w lidze ${availableLeague.id}");
        } else {
          print("Nie znaleziono bota do zamiany.");
        }
      } else {
        // Jeśli nie ma dostępnej ligi z botami, stwórz nową ligę
        String newLeagueId = await _createNewLeagueWithBots(clubName);
        print("Utworzono nową ligę z ID: $newLeagueId");
      }
    }
  }

  // Znajdź ligę z botami do zamiany
  static Future<DocumentSnapshot?> _findAvailableLeagueWithBot() async {
    var leagues = await FirebaseFirestore.instance
        .collection('leagues')
        .where('clubs_count', isEqualTo: 10) // Liga pełna, ale może mieć boty
        .get();

    // Przeszukujemy ligi, aby znaleźć taką, która zawiera boty
    for (var league in leagues.docs) {
      var leagueData = league.data() as Map<String, dynamic>;
      var clubs = List<String>.from(leagueData['clubs']);

      if (clubs.any((club) => club.startsWith('Bot_'))) {
        return league; // Znaleźliśmy ligę z botami do zastąpienia
      }
    }

    return null; // Nie znaleziono ligi z botami
  }

// Tworzy nową ligę z botami i generuje mecze za pomocą algorytmu Sonneborn-Berger
  static Future<String> _createNewLeagueWithBots(String clubName) async {
    List<String> bots = List.generate(9, (index) => 'Bot_${index + 1}');

    // Generujemy mecze pogrupowane w rundy
    Map<String, dynamic> matchesByRound =
        _generateInitialMatches([clubName, ...bots]);

    DocumentReference leagueRef =
        await FirebaseFirestore.instance.collection('leagues').add({
      'clubs': [clubName, ...bots], // Klub i 9 botów
      'clubs_count': 10,
      'matches': matchesByRound, // Mecze pogrupowane wg rund
    });

    return leagueRef.id;
  }

  static Map<String, dynamic> _generateInitialMatches(List<String> clubs) {
    Map<String, dynamic> matchesByRound = {};

    // Sprawdzenie, czy liczba drużyn jest nieparzysta. Jeśli tak, dodajemy "BYE" (wolny dzień).
    if (clubs.length % 2 != 0) {
      clubs.add('BYE');
    }

    int numTeams = clubs.length;
    int numRounds = numTeams - 1;
    int numMatchesPerDay = numTeams ~/ 2;

    List<String> currentClubs = List.from(clubs); // Kopia listy klubów

    for (int round = 0; round < numRounds; round++) {
      List<Map<String, dynamic>> roundMatches = []; // Mecze dla danej rundy

      // Generujemy mecze dla każdej rundy
      for (int i = 0; i < numMatchesPerDay; i++) {
        String homeTeam = currentClubs[i];
        String awayTeam = currentClubs[numTeams - 1 - i];

        // Tworzymy mecz i dodajemy do listy meczów w tej rundzie
        roundMatches.add({
          'club1': homeTeam,
          'club2': awayTeam,
          'matchTime': null, // Czas meczu zostanie ustalony później
          'score': null, // Wynik pojawi się po meczu
        });
      }

      // Przypisujemy mecze tej rundy do mapy matchesByRound
      matchesByRound['round${round + 1}'] = roundMatches;

      // Przesuwamy drużyny zgodnie z zasadami Sonneborn-Berger
      String lastTeam =
          currentClubs.removeAt(currentClubs.length - 1); // Ostatnia drużyna
      currentClubs.insert(
          1, lastTeam); // Wstawiamy ostatnią drużynę na drugą pozycję
    }

    // Po wygenerowaniu meczów, przypisujemy im czasy rozgrywania
    matchesByRound = _assignMatchTimesByRound(matchesByRound);

    return matchesByRound;
  }

// Przypisuje czas meczów grupując je według rund
  static Map<String, dynamic> _assignMatchTimesByRound(
      Map<String, dynamic> matchesByRound) {
    DateTime now = DateTime.now();
    int numMatchesPerDay = 5;

    DateTime matchTime =
        DateTime(now.year, now.month, now.day, 12); // Pierwszy mecz o 12:00

    // Iterujemy przez rundy
    matchesByRound.forEach((roundKey, roundMatches) {
      for (int i = 0; i < roundMatches.length; i++) {
        roundMatches[i]['matchTime'] = matchTime;

        // Zwiększamy czas o 2 godziny dla każdego kolejnego meczu
        matchTime = matchTime.add(Duration(hours: 2));

        // Po 5 meczach przechodzimy do następnego dnia
        if ((i + 1) % numMatchesPerDay == 0) {
          matchTime =
              matchTime.add(Duration(hours: 18)); // Następny dzień o 12:00
        }
      }
    });

    return matchesByRound;
  }

  // Zastępuje bota we wszystkich meczach
  static Future<void> _replaceBotInMatches(
      DocumentSnapshot leagueSnapshot, String botName, String clubName) async {
    var leagueData = leagueSnapshot.data() as Map<String, dynamic>;
    List<dynamic> matches = leagueData['matches'];

    for (int i = 0; i < matches.length; i++) {
      var match = matches[i] as Map<String, dynamic>;

      // Zastępujemy bota w meczach
      if (match['club1'] == botName) {
        matches[i]['club1'] = clubName;
      } else if (match['club2'] == botName) {
        matches[i]['club2'] = clubName;
      }
    }

    // Aktualizujemy mecze w Firestore
    await leagueSnapshot.reference.update({
      'matches': matches,
    });

    print("Zastąpiono bota $botName klubem $clubName we wszystkich meczach.");
  }
}
