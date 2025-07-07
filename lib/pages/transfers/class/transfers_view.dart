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
  State<TransfersView> createState() => _TransfersViewState();
}

class _TransfersViewState extends State<TransfersView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  // State variables
  List<Player> _players = [];
  Player? _selectedPlayer;
  bool _isLoading = true;
  String? _errorMessage;

  // Cached references for performance
  late final FirebaseFirestore _firestore;
  late final User? _currentUser;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeReferences();
    _initializeAnimations();
    _initializeData();
  }

  void _initializeReferences() {
    _firestore = FirebaseFirestore.instance;
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await _checkAndRefreshData();
      await _fetchPlayersFromTransfers();

      if (mounted) {
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load transfer data: ${e.toString()}';
        });
      }
      debugPrint('Error initializing data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkAndRefreshData() async {
    if (_currentUser == null) {
      throw Exception('User is not logged in');
    }

    final transfersRef =
        _firestore.collection('transfers').doc(_currentUser.uid);

    try {
      final transferDoc = await transfersRef.get();

      if (transferDoc.exists) {
        final data = transferDoc.data();

        if (data == null) {
          await _generateAndSavePlayers();
          return;
        }

        final Timestamp? createdAt = data['createdAt'] as Timestamp?;
        final Timestamp? deleteAt = data['deleteAt'] as Timestamp?;

        if (createdAt != null && deleteAt != null) {
          final DateTime deleteTime = deleteAt.toDate();
          final DateTime now = DateTime.now();

          if (now.isAfter(deleteTime)) {
            debugPrint('Refreshing data - transfer period expired');
            await _refreshData();
          } else {
            debugPrint('Using existing transfer data');
          }
        } else {
          // Wait for background process to complete
          await Future.delayed(const Duration(seconds: 2));
          await _checkAndRefreshData();
        }
      } else {
        debugPrint('Generating new transfer data');
        await _generateAndSavePlayers();
      }
    } catch (e) {
      debugPrint('Error checking transfer data: $e');
      rethrow;
    }
  }

  Future<void> _refreshData() async {
    if (_currentUser == null) return;

    final transfersRef =
        _firestore.collection('transfers').doc(_currentUser.uid);

    try {
      final transferDoc = await transfersRef.get();

      if (transferDoc.exists) {
        final data = transferDoc.data();
        final List<dynamic> playerRefs = data?['playerRefs'] ?? [];

        // Delete old players in batch
        final batch = _firestore.batch();
        for (var ref in playerRefs) {
          if (ref is DocumentReference) {
            batch.delete(ref);
          }
        }
        await batch.commit();

        // Delete transfers document
        await transfersRef.delete();
        debugPrint('Cleaned up old transfer data');
      }

      await _generateAndSavePlayers();
    } catch (e) {
      debugPrint('Error refreshing data: $e');
      rethrow;
    }
  }

  Future<void> _generateAndSavePlayers() async {
    if (_currentUser == null) {
      throw Exception('User is not logged in');
    }

    final tempTransfersRef = _firestore.collection('temp_transfers');
    final transfersRef =
        _firestore.collection('transfers').doc(_currentUser.uid);

    try {
      final List<DocumentReference> playerRefs = [];
      final DateTime currentTime = DateTime.now();

      // Generate players in parallel for better performance
      final List<Future<Player>> playerFutures = List.generate(
        20,
        (_) => Player.generateRandomFootballer(),
      );

      final List<Player> players = await Future.wait(playerFutures);

      // Save players in batch
      final batch = _firestore.batch();
      for (final player in players) {
        final playerDocRef = tempTransfersRef.doc();
        batch.set(playerDocRef, player.toDocument());
        playerRefs.add(playerDocRef);
      }
      await batch.commit();

      // Save transfer document
      await transfersRef.set({
        'playerRefs': playerRefs,
        'createdAt': Timestamp.fromDate(currentTime),
        'deleteAt': Timestamp.fromDate(
          currentTime.add(const Duration(minutes: 4)),
        ),
      });

      debugPrint('Generated ${players.length} new transfer players');

      // Small delay to ensure data consistency
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      debugPrint('Error generating players: $e');
      rethrow;
    }
  }

  Future<void> _fetchPlayersFromTransfers() async {
    if (_currentUser == null) {
      throw Exception('User is not logged in');
    }

    final transfersRef =
        _firestore.collection('transfers').doc(_currentUser.uid);

    try {
      final transferDoc = await transfersRef.get();

      if (!transferDoc.exists) {
        setState(() {
          _players = [];
        });
        return;
      }

      final data = transferDoc.data();
      final List<dynamic> playerRefs = data?['playerRefs'] ?? [];

      // Fetch players in parallel
      final List<Future<DocumentSnapshot>> playerFutures =
          playerRefs.cast<DocumentReference>().map((ref) => ref.get()).toList();

      final List<DocumentSnapshot> playerDocs =
          await Future.wait(playerFutures);

      final List<Player> players = playerDocs
          .where((doc) => doc.exists)
          .map((doc) => Player.fromDocument(doc))
          .toList();

      if (mounted) {
        setState(() {
          _players = players;
        });
      }

      debugPrint('Fetched ${players.length} transfer players');
    } catch (e) {
      debugPrint('Error fetching players: $e');
      rethrow;
    }
  }

  void _onPlayerSelected(Player player) {
    if (!mounted) return;

    setState(() {
      _selectedPlayer = _selectedPlayer == player ? null : player;
    });
  }

  void _showPlayerConfirmationDialog(Player player) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: TransferPlayerConfirmWidget(
              player: player,
              isSelected: _selectedPlayer == player,
              onPlayerSelected: _onPlayerSelected,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onRefresh() async {
    await _initializeData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_errorMessage != null) {
      return _buildErrorWidget();
    }

    return _buildTransfersList();
  }

  Widget _buildLoadingWidget() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.hoverColor.withValues(alpha: 0.1),
            AppColors.hoverColor.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LoadingAnimationWidget.waveDots(
              color: AppColors.textEnabledColor,
              size: 50,
            ),
            const SizedBox(height: 16),
            Text(
              'Loading transfers...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textEnabledColor.withValues(alpha: 0.7),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Transfers',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? 'Unknown error occurred',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade300,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _initializeData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.hoverColor,
              foregroundColor: AppColors.textEnabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransfersList() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.textEnabledColor,
          backgroundColor: AppColors.hoverColor,
          child: _players.isEmpty ? _buildEmptyState() : _buildPlayersList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 400,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sports_soccer,
            size: 64,
            color: AppColors.textEnabledColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No transfers available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.textEnabledColor.withValues(alpha: 0.7),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textEnabledColor.withValues(alpha: 0.5),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _players.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final player = _players[index];
        return RepaintBoundary(
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300 + (index * 50)),
            curve: Curves.easeOutBack,
            child: _OptimizedPlayerCard(
              player: player,
              isSelected: _selectedPlayer == player,
              onTap: () => _showPlayerConfirmationDialog(player),
              onPlayerSelected: _onPlayerSelected,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}

// Optimized stateless widget for player cards
class _OptimizedPlayerCard extends StatelessWidget {
  const _OptimizedPlayerCard({
    required this.player,
    required this.isSelected,
    required this.onTap,
    required this.onPlayerSelected,
  });

  final Player player;
  final bool isSelected;
  final VoidCallback onTap;
  final Function(Player) onPlayerSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.textEnabledColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: AppColors.textEnabledColor, width: 2)
                : null,
          ),
          child: TransferPlayerConfirmWidget(
            player: player,
            isSelected: isSelected,
            onPlayerSelected: onPlayerSelected,
          ),
        ),
      ),
    );
  }
}
