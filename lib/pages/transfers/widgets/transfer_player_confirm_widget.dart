import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/components/player_details.dart';
import 'package:pocket_eleven/pages/transfers/widgets/player_transfer_confirmation.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfer_player_card.dart';

class TransferPlayerConfirmWidget extends StatelessWidget {
  final Player player;
  final bool isSelected;
  final void Function(Player) onPlayerSelected;
  final VoidCallback? onPlayerRemoved;

  const TransferPlayerConfirmWidget({
    super.key,
    required this.player,
    required this.isSelected,
    required this.onPlayerSelected,
    this.onPlayerRemoved,
  });

  Future<void> _handleConfirmSelection(BuildContext context) async {
    Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showError(messenger, 'Authentication required');
      return;
    }

    if (!await PlayerTransferConfirmation.show(context, player)) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        _showError(messenger, 'User profile not found');
        return;
      }

      final money = (userDoc.data()?['money'] ?? 0).toDouble();

      if (money >= player.value) {
        await _processTransfer(messenger, user.uid, money);
      } else {
        _showError(messenger, 'Insufficient funds');
      }
    } catch (e) {
      _showError(messenger, 'Transaction failed');
    }
  }

  Future<void> _processTransfer(
      ScaffoldMessengerState messenger, String uid, double money) async {
    final batch = FirebaseFirestore.instance.batch();
    final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final tempRef = FirebaseFirestore.instance
        .collection('temp_transfers')
        .doc(player.playerID);
    final transfersRef =
        FirebaseFirestore.instance.collection('transfers').doc(uid);

    batch.update(userRef, {'money': money - player.value});
    batch.delete(tempRef);
    batch.update(transfersRef, {
      'playerRefs': FieldValue.arrayRemove([tempRef])
    });

    await batch.commit();

    onPlayerRemoved?.call();
    _showSuccess(messenger, '${player.name} signed!');
    HapticFeedback.lightImpact();
  }

  void _handlePlayerTap(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => PlayerDetailsDialog(player: player),
    );
  }

  void _showError(ScaffoldMessengerState messenger, String msg) =>
      _showSnackBar(messenger, msg, AppColors.errorColor);

  void _showSuccess(ScaffoldMessengerState messenger, String msg) =>
      _showSnackBar(messenger, msg, AppColors.successColor);

  void _showSnackBar(
      ScaffoldMessengerState messenger, String msg, Color color) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(color: AppColors.textEnabledColor)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TransferPlayerCard(
      player: player,
      isSelected: isSelected,
      onTap: () => _handlePlayerTap(context),
      onConfirm: () => _handleConfirmSelection(context),
    );
  }
}
