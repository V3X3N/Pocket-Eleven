import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/pages/play/widgets/error_state_widget.dart';
import 'package:pocket_eleven/pages/transfers/services/transfer_data_manager.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfer_player_confirm_widget.dart';
import 'package:pocket_eleven/pages/transfers/widgets/transfers_list_view.dart';

class TransfersView extends StatefulWidget {
  const TransfersView({super.key});

  @override
  State<TransfersView> createState() => _TransfersViewState();
}

class _TransfersViewState extends State<TransfersView>
    with AutomaticKeepAliveClientMixin, SingleTickerProviderStateMixin {
  static const _gradientColors = [
    AppColors.primaryColor,
    AppColors.secondaryColor,
    AppColors.accentColor,
  ];

  List<Player> _players = [];
  Player? _selectedPlayer;
  bool _isLoading = true;
  String? _errorMessage;
  late final TransfersDataManager _dataManager;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _dataManager = TransfersDataManager();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));
    _loadTransferData();
  }

  Widget _buildModernContainer({required Widget child}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: AppColors.hoverColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderColor.withValues(alpha: 0.3)),
        boxShadow: const [
          BoxShadow(
              color: Color(0x40000000), offset: Offset(0, 8), blurRadius: 32),
          BoxShadow(
              color: Color(0x1AFFFFFF), offset: Offset(0, 1), blurRadius: 0),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(24), child: child),
    );
  }

  Future<void> _loadTransferData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

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
        setState(() =>
            _errorMessage = 'Failed to load transfer data: ${e.toString()}');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _onPlayerSelected(Player player) {
    if (mounted) {
      setState(
          () => _selectedPlayer = _selectedPlayer == player ? null : player);
    }
  }

  void _showPlayerConfirmationDialog(Player player) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.hoverColor.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(20),
            border:
                Border.all(color: AppColors.borderColor.withValues(alpha: 0.4)),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x60000000),
                  offset: Offset(0, 12),
                  blurRadius: 40)
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TransferPlayerConfirmWidget(
              player: player,
              isSelected: _selectedPlayer == player,
              onPlayerSelected: _onPlayerSelected,
            ),
          ),
        ),
      ),
    );
  }

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
        setState(
            () => _errorMessage = 'Failed to refresh data: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _gradientColors,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: _buildModernContainer(
            child: _isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.textEnabledColor),
                          strokeWidth: screenWidth * 0.008,
                        ),
                        SizedBox(height: screenWidth * 0.05),
                        Text(
                          'Loading transfers...',
                          style: TextStyle(
                            fontSize: screenWidth * 0.04,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textEnabledColor,
                          ),
                        ),
                      ],
                    ),
                  )
                : _errorMessage != null
                    ? ErrorStateWidget(
                        title: 'Error Loading Transfers',
                        message: _errorMessage!,
                        onRetry: _loadTransferData,
                      )
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                AppColors.hoverColor.withValues(alpha: 0.1)
                              ],
                            ),
                          ),
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
                      ),
          ),
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
