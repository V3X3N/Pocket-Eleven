import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfer_player_confirm_widget.dart';

class TransfersView extends StatefulWidget {
  const TransfersView({super.key});

  @override
  State<TransfersView> createState() => TransfersViewState();
}

class TransfersViewState extends State<TransfersView> {
  List<Player> _players = [];
  Player? _selectedPlayer;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    await _checkAndRefreshData();
    await _fetchPlayersFromTransfers();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkAndRefreshData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('User is not logged in.');
      return;
    }

    final transfersRef = firestore.collection('transfers').doc(user.uid);
    final transferDoc = await transfersRef.get();

    if (transferDoc.exists) {
      final Timestamp? createdAt = transferDoc['createdAt'];
      final Timestamp? deleteAt = transferDoc['deleteAt'];

      if (createdAt != null && deleteAt != null) {
        final DateTime createdTime = createdAt.toDate();
        final DateTime deleteTime = deleteAt.toDate();
        final DateTime now = DateTime.now();

        debugPrint(
            'Created time: $createdTime, Delete time: $deleteTime, Current time: $now');

        if (now.isAfter(deleteTime)) {
          debugPrint(
              'Refreshing data, more than 4 minutes have passed since deleteAt.');
          await _refreshData();
        } else {
          debugPrint(
              'Not refreshing data, less than 4 minutes have passed since deleteAt.');
        }
      } else {
        debugPrint('The createdAt or deleteAt field is still null. Waiting...');
        await Future.delayed(const Duration(seconds: 2));
        await _checkAndRefreshData();
      }
    } else {
      debugPrint('User document does not exist. Generating new data.');
      await _generateAndSavePlayers();
    }
  }

  Future<void> _refreshData() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final transfersRef = firestore.collection('transfers').doc(user.uid);
    final transferDoc = await transfersRef.get();
    final List<dynamic> playerRefs = transferDoc['playerRefs'] ?? [];

    debugPrint('Deleting players from temp_transfers...');
    for (var ref in playerRefs) {
      final docRef = ref as DocumentReference;
      await docRef.delete();
      debugPrint('Deleted player: ${docRef.id}');
    }

    await transfersRef.delete();
    debugPrint('User transfers document deleted.');

    debugPrint('Generating new data...');
    await _generateAndSavePlayers();
  }

  Future<void> _generateAndSavePlayers() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('User is not logged in.');
      return;
    }

    final tempTransfersRef = firestore.collection('temp_transfers');
    final transfersRef = firestore.collection('transfers').doc(user.uid);

    List<DocumentReference> playerRefs = [];

    final DateTime currentLocalTime = DateTime.now();
    final Timestamp createdAt = Timestamp.fromDate(currentLocalTime);

    for (int i = 0; i < 20; i++) {
      final player = await Player.generateRandomFootballer();
      final playerDocRef = tempTransfersRef.doc();
      await playerDocRef.set(player.toDocument());
      playerRefs.add(playerDocRef);
      debugPrint('Saved player: ${playerDocRef.id}');
    }

    await transfersRef.set({
      'playerRefs': playerRefs,
      'createdAt': createdAt,
    });

    debugPrint('New user transfers document created.');

    final DateTime deleteDate = currentLocalTime.add(
        const Duration(minutes: 4)); // TODO: Adjust the time duration if needed
    final Timestamp deleteAt = Timestamp.fromDate(deleteDate);

    await transfersRef.update({
      'deleteAt': deleteAt,
    });

    debugPrint('Delete time set to: $deleteDate');

    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _fetchPlayersFromTransfers() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('User is not logged in.');
      return;
    }

    final transfersRef = firestore.collection('transfers').doc(user.uid);
    final transferDoc = await transfersRef.get();
    final List<dynamic> playerRefs = transferDoc['playerRefs'] ?? [];

    List<Player> players = [];
    for (var ref in playerRefs) {
      final playerDoc = await (ref as DocumentReference).get();
      if (playerDoc.exists) {
        players.add(Player.fromDocument(playerDoc));
        debugPrint('Fetched player: ${playerDoc.id}');
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

  void _onPlayerSelected(Player player) {
    setState(() {
      _selectedPlayer = player;
    });
  }

  void _showPlayerConfirmationDialog(Player player) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return TransferPlayerConfirmWidget(
          player: player,
          isSelected: _selectedPlayer == player,
          onPlayerSelected: _onPlayerSelected,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return _isLoading
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
              border: Border.all(color: AppColors.borderColor, width: 1),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListView(
              padding: EdgeInsets.all(screenWidth * 0.04),
              children: _players.map((player) {
                return GestureDetector(
                  onTap: () {
                    _showPlayerConfirmationDialog(player);
                  },
                  child: TransferPlayerConfirmWidget(
                    player: player,
                    isSelected: _selectedPlayer == player,
                    onPlayerSelected: _onPlayerSelected,
                  ),
                );
              }).toList(),
            ),
          );
  }
}
