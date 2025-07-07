import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/components/player_details.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  static final Map<String, ImageProvider> _imageCache = {};

  ImageProvider _getCachedImage(String flagPath) {
    return _imageCache.putIfAbsent(flagPath, () => AssetImage(flagPath));
  }

  Future<void> _confirmPlayerSelection(BuildContext context) async {
    Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showSnackBar(messenger, 'User not logged in', isError: true);
      return;
    }

    final confirmed = await _showConfirmationDialog(context);
    if (confirmed != true) return;

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        _showSnackBar(messenger, 'User document not found', isError: true);
        return;
      }

      final userMoney = (userDoc.data()?['money'] ?? 0).toDouble();

      if (userMoney >= player.value) {
        await _processTransfer(messenger, user.uid, userMoney);
      } else {
        _showSnackBar(messenger, 'Not enough money to add ${player.name}',
            isError: true);
      }
    } catch (e) {
      _showSnackBar(messenger, 'Transaction failed: ${e.toString()}',
          isError: true);
    }
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _ConfirmationDialog(player: player),
    );
  }

  Future<void> _processTransfer(
      ScaffoldMessengerState messenger, String userId, double userMoney) async {
    final batch = FirebaseFirestore.instance.batch();
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final tempTransfersRef = FirebaseFirestore.instance
        .collection('temp_transfers')
        .doc(player.playerID);
    final transfersRef =
        FirebaseFirestore.instance.collection('transfers').doc(userId);

    batch.update(userRef, {'money': userMoney - player.value});
    batch.delete(tempTransfersRef);
    batch.update(transfersRef, {
      'playerRefs': FieldValue.arrayRemove([tempTransfersRef])
    });

    await batch.commit();

    // Note: PlayerFunctions.savePlayerToFirestore might need context - handle separately if needed
    onPlayerRemoved?.call();
    _showSnackBar(messenger, 'Player ${player.name} added to your club!');
  }

  void _showSnackBar(ScaffoldMessengerState messenger, String message,
      {bool isError = false}) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(12.0),
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [Colors.grey[300]!, Colors.grey[200]!]
                : [
                    AppColors.blueColor,
                    AppColors.blueColor.withValues(alpha: 0.8)
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16.0),
            onTap: isSelected ? null : () => _showPlayerDetails(context),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      color: AppColors.textEnabledColor,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            _InfoChip(label: player.position),
                            _InfoChip(label: 'OVR: ${player.ovr}'),
                            _InfoChip(
                                label: '\$${player.value}', isPrice: true),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image(
                        image: _getCachedImage(player.flagPath),
                        width: 28,
                        height: 28,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(Icons.flag,
                              size: 16, color: Colors.grey),
                        ),
                      ),
                      if (!isSelected) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.check_circle,
                              color: Colors.green, size: 28),
                          onPressed: () => _confirmPlayerSelection(context),
                          tooltip: 'Confirm selection',
                          splashRadius: 24,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPlayerDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => PlayerDetailsDialog(player: player),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final bool isPrice;

  const _InfoChip({required this.label, this.isPrice = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPrice
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPrice
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrice ? Colors.green[700] : AppColors.textEnabledColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _ConfirmationDialog extends StatelessWidget {
  final Player player;

  const _ConfirmationDialog({required this.player});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
          maxHeight: MediaQuery.of(context).size.height * 0.4,
        ),
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.hoverColor,
              AppColors.hoverColor.withValues(alpha: 0.9)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.help_outline,
                size: 48, color: AppColors.textEnabledColor),
            const SizedBox(height: 16),
            const Text(
              'Confirm Selection',
              style: TextStyle(
                color: AppColors.textEnabledColor,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to select ${player.name}?',
              style: const TextStyle(
                  color: AppColors.textEnabledColor, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              ),
              child: Text(
                'Cost: \$${player.value}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Confirm',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
