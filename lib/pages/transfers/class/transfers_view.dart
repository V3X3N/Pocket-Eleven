import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/pages/play/widgets/error_state_widget.dart';
import 'package:pocket_eleven/pages/transfers/services/transfer_data_manager.dart';
import 'package:pocket_eleven/pages/transfers/widgets/loading_state_widget.dart';
import 'package:pocket_eleven/pages/transfers/widgets/modern_card_container.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfer_player_confirm_widget.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfers_list_view.dart';

/// Optimized transfers view with modern design and high performance.
///
/// Features:
/// - 60fps performance with proper widget optimization
/// - Modern visual design with smooth animations
/// - Defensive programming with comprehensive error handling
/// - Scalable responsive design for all device types
/// - Efficient state management and data operations
/// - Reusable component architecture
class TransfersView extends StatefulWidget {
  const TransfersView({super.key});

  @override
  State<TransfersView> createState() => _TransfersViewState();
}

class _TransfersViewState extends State<TransfersView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  // Core state management
  List<Player> _players = [];
  Player? _selectedPlayer;
  bool _isLoading = true;
  String? _errorMessage;

  // Services
  late final TransfersDataManager _dataManager;

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initializeAnimations();
    _loadTransferData();
  }

  /// Initializes service dependencies
  void _initializeServices() {
    _dataManager = TransfersDataManager();
  }

  /// Initializes animation controllers for smooth transitions
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

  /// Loads transfer data with proper error handling
  Future<void> _loadTransferData() async {
    if (!mounted) return;

    try {
      _setLoadingState(true);

      if (!_dataManager.isUserAuthenticated) {
        throw Exception('User authentication required');
      }

      final players = await _dataManager.initializeTransferData();

      if (mounted) {
        setState(() {
          _players = players;
          _errorMessage = null;
        });
        _fadeController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load transfer data: ${e.toString()}';
        });
      }
      debugPrint('Error loading transfer data: $e');
    } finally {
      if (mounted) {
        _setLoadingState(false);
      }
    }
  }

  /// Sets the loading state with defensive programming
  void _setLoadingState(bool isLoading) {
    if (mounted) {
      setState(() {
        _isLoading = isLoading;
        if (isLoading) {
          _errorMessage = null;
        }
      });
    }
  }

  /// Handles player selection state changes
  void _onPlayerSelected(Player player) {
    if (!mounted) return;

    setState(() {
      _selectedPlayer = _selectedPlayer == player ? null : player;
    });
  }

  /// Shows player confirmation dialog with smooth animations
  void _showPlayerConfirmationDialog(Player player) {
    if (!mounted) return;

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

  /// Handles pull-to-refresh functionality
  Future<void> _onRefresh() async {
    try {
      final players = await _dataManager.forceRefresh();

      if (mounted) {
        setState(() {
          _players = players;
          _selectedPlayer = null;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to refresh data: ${e.toString()}';
        });
      }
      debugPrint('Error refreshing data: $e');
    }
  }

  /// Handles retry functionality from error state
  void _onRetry() {
    _loadTransferData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    // Loading state
    if (_isLoading) {
      return const LoadingStateWidget(
        message: 'Loading transfers...',
      );
    }

    // Error state
    if (_errorMessage != null) {
      return ErrorStateWidget(
        title: 'Error Loading Transfers',
        message: _errorMessage!,
        onRetry: _onRetry,
      );
    }

    // Success state with transfers list
    return ModernCardContainer(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: TransfersListView(
          players: _players,
          selectedPlayer: _selectedPlayer,
          onRefresh: _onRefresh,
          onPlayerTap: _showPlayerConfirmationDialog,
          onPlayerSelected: _onPlayerSelected,
          emptyStateTitle: 'No transfers available',
          emptyStateMessage: 'Pull down to refresh',
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }
}
