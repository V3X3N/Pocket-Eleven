import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/firebase/firebase_functions.dart';
import 'package:pocket_eleven/firebase/firebase_youth.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/pages/club/widget/build_info.dart';
import 'package:pocket_eleven/pages/club/widget/youth_player_confirm_widget.dart';

class YouthView extends StatefulWidget {
  const YouthView({super.key});

  @override
  State<YouthView> createState() => YouthViewState();
}

class YouthViewState extends State<YouthView> {
  List<Player> _players = [];
  Player? _selectedPlayer;
  bool _isLoading = true;
  DateTime? lastGeneratedTime;
  int level = 1;
  int upgradeCost = 100000;
  double userMoney = 0;
  String? userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        Map<String, dynamic> userData = await FirebaseFunctions.getUserData();
        level = await YouthFunctions.getYouthLevel(userId!);
        upgradeCost = FirebaseFunctions.calculateUpgradeCost(level);
        userMoney = (userData['money'] ?? 0).toDouble();
        lastGeneratedTime = userData['lastGeneratedTime']?.toDate();
        _initializeData();
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> increaseLevel() async {
    if (level >= 5) {
      const snackBar = SnackBar(
        content: Text('Youth Academy is already at the maximum level (5).'),
        backgroundColor: Colors.orange,
        duration: Duration(seconds: 2),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
      return;
    }

    if (userId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        double userMoney = (userData['money'] ?? 0).toDouble();
        int currentLevel = userData['youthLevel'] ?? 1;

        int currentUpgradeCost =
            FirebaseFunctions.calculateUpgradeCost(currentLevel);

        if (userMoney >= currentUpgradeCost) {
          int newLevel = currentLevel + 1;

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({
            'youthLevel': newLevel,
            'money': userMoney - currentUpgradeCost,
          });

          setState(() {
            level = newLevel;
            upgradeCost = FirebaseFunctions.calculateUpgradeCost(newLevel);
            this.userMoney = userMoney - currentUpgradeCost;
          });

          const snackBar = SnackBar(
            content: Text('Youth Academy upgraded successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        } else {
          const snackBar = SnackBar(
            content: Text('Not enough money to upgrade the youth academy.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          );

          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      } catch (e) {
        debugPrint('Error upgrading youth academy: $e');
      }
    }
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    await _checkAndRefreshYouthData();
    await _fetchPlayersFromYouth();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkAndRefreshYouthData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('User is not logged in.');
      return;
    }

    final youthRef = firestore.collection('youth').doc(user.uid);
    final youthDoc = await youthRef.get();

    if (youthDoc.exists) {
      final Timestamp? createdAt = youthDoc['createdAt'];
      final Timestamp? deleteAt = youthDoc['deleteAt'];

      if (createdAt != null && deleteAt != null) {
        final DateTime createdTime = createdAt.toDate();
        final DateTime deleteTime = deleteAt.toDate();
        final DateTime now = DateTime.now();

        debugPrint(
            'Youth created at: $createdTime, delete at: $deleteTime, current time: $now');

        if (now.isAfter(deleteTime)) {
          debugPrint(
              'Refreshing youth data, more than 4 hours have passed since last generation.');
          await _refreshYouthData();
        } else {
          lastGeneratedTime = createdTime;
          debugPrint(
              'Youth data is fresh, less than 4 hours since last generation.');
        }
      } else {
        debugPrint('Youth document missing timestamps, generating new data.');
        await _generateAndSaveYouthPlayers();
      }
    } else {
      debugPrint('Youth document does not exist. Generating new data.');
      await _generateAndSaveYouthPlayers();
    }
  }

  Future<void> _refreshYouthData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final youthRef = firestore.collection('youth').doc(user.uid);
    final youthDoc = await youthRef.get();
    final List<dynamic> playerRefs = youthDoc['playerRefs'] ?? [];

    debugPrint('Deleting players from temp_youth...');
    for (var ref in playerRefs) {
      final docRef = ref as DocumentReference;
      await docRef.delete();
      debugPrint('Deleted youth player: ${docRef.id}');
    }

    await youthRef.delete();
    debugPrint('Youth document deleted.');

    debugPrint('Generating new youth data...');
    await _generateAndSaveYouthPlayers();
  }

  Future<void> _generateAndSaveYouthPlayers() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('User is not logged in.');
      return;
    }

    final tempYouthRef = firestore.collection('temp_youth');
    final youthRef = firestore.collection('youth').doc(user.uid);

    List<DocumentReference> playerRefs = [];

    final DateTime currentLocalTime = DateTime.now();
    final Timestamp createdAt = Timestamp.fromDate(currentLocalTime);

    for (int i = 0; i < 5; i++) {
      final player = await Player.generateRandomFootballer(
        minAge: 16,
        maxAge: 19,
        minOvr: 20,
        maxOvr: 40,
        isYouth: true,
      );
      final playerDocRef = tempYouthRef.doc();
      await playerDocRef.set(player.toDocument());
      playerRefs.add(playerDocRef);
      debugPrint('Saved youth player: ${playerDocRef.id}');
    }

    await youthRef.set({
      'playerRefs': playerRefs,
      'createdAt': createdAt,
    });

    debugPrint('New youth document created.');

    final DateTime deleteDate = currentLocalTime
        .add(const Duration(minutes: 4)); //TODO: Balance the deletion time
    final Timestamp deleteAt = Timestamp.fromDate(deleteDate);

    await youthRef.update({
      'deleteAt': deleteAt,
    });

    debugPrint('Delete time set to: $deleteDate');
    lastGeneratedTime = currentLocalTime;
  }

  Future<void> _fetchPlayersFromYouth() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('User is not logged in.');
      return;
    }

    final youthRef = firestore.collection('youth').doc(user.uid);
    final youthDoc = await youthRef.get();
    final List<dynamic> playerRefs = youthDoc['playerRefs'] ?? [];

    List<Player> players = [];
    for (var ref in playerRefs) {
      final playerDoc = await (ref as DocumentReference).get();
      if (playerDoc.exists) {
        players.add(Player.fromDocument(playerDoc));
        debugPrint('Fetched youth player: ${playerDoc.id}');
      }
    }

    setState(() {
      _players = players;
    });
  }

  void removePlayerFromList(Player player) {
    setState(() {
      _players.removeWhere((p) => p.playerID == player.playerID);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Column(
        children: [
          Container(
            color: AppColors.primaryColor,
            padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05, vertical: screenHeight * 0.02),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.hoverColor,
                    border: Border.all(color: AppColors.borderColor, width: 1),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: BuildInfo(
                    headerText: 'Youth Academy',
                    level: level,
                    upgradeCost: upgradeCost,
                    isUpgradeEnabled: userMoney >= upgradeCost,
                    onUpgradePressed: increaseLevel,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(
                    child: LoadingAnimationWidget.waveDots(
                      color: AppColors.textEnabledColor,
                      size: 50,
                    ),
                  )
                : Container(
                    margin: EdgeInsets.all(screenWidth * 0.04),
                    decoration: BoxDecoration(
                      color: AppColors.hoverColor,
                      border:
                          Border.all(color: AppColors.borderColor, width: 1),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: ListView.builder(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      itemCount: _players.length,
                      itemBuilder: (context, index) {
                        final player = _players[index];
                        return YouthPlayerConfirmWidget(
                          player: player,
                          isSelected: _selectedPlayer == player,
                          onPlayerSelected: (selectedPlayer) {
                            setState(() {
                              _selectedPlayer = selectedPlayer;
                            });
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
