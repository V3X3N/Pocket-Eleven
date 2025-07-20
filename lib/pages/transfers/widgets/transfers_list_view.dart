import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/models/player.dart';
import 'animated_player_card.dart';
import 'empty_state_widget.dart';

/// A high-performance list view widget for displaying transfer players.
///
/// Features:
/// - Optimized ListView with proper separators
/// - Pull-to-refresh functionality
/// - Staggered animations for visual appeal
/// - Empty state handling
/// - Performance optimized with RepaintBoundary
/// - Smooth 60fps scrolling performance
class TransfersListView extends StatelessWidget {
  /// Creates a transfers list view.
  ///
  /// [players] - List of players to display (required)
  /// [selectedPlayer] - Currently selected player (can be null)
  /// [onRefresh] - Callback function for pull-to-refresh (required)
  /// [onPlayerTap] - Callback when a player card is tapped (required)
  /// [onPlayerSelected] - Callback for player selection changes (required)
  /// [emptyStateTitle] - Title for empty state (default: 'No transfers available')
  /// [emptyStateMessage] - Message for empty state (default: 'Pull down to refresh')
  const TransfersListView({
    super.key,
    required this.players,
    required this.selectedPlayer,
    required this.onRefresh,
    required this.onPlayerTap,
    required this.onPlayerSelected,
    this.emptyStateTitle = 'No transfers available',
    this.emptyStateMessage = 'Pull down to refresh',
  });

  /// List of players to display in the list
  final List<Player> players;

  /// Currently selected player (if any)
  final Player? selectedPlayer;

  /// Callback function for pull-to-refresh
  final Future<void> Function() onRefresh;

  /// Callback function when a player card is tapped
  final Function(Player) onPlayerTap;

  /// Callback function for player selection state changes
  final Function(Player) onPlayerSelected;

  /// Title text for empty state
  final String emptyStateTitle;

  /// Message text for empty state
  final String emptyStateMessage;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: AppColors.textEnabledColor,
      backgroundColor: AppColors.hoverColor,
      strokeWidth: 2.5,
      child:
          players.isEmpty ? _buildScrollableEmptyState() : _buildPlayersList(),
    );
  }

  /// Builds a scrollable empty state that supports pull-to-refresh
  Widget _buildScrollableEmptyState() {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          child: EmptyStateWidget(
            icon: Icons.sports_soccer,
            title: emptyStateTitle,
            message: emptyStateMessage,
          ),
        ),
      ],
    );
  }

  /// Builds the optimized players list with staggered animations
  Widget _buildPlayersList() {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: players.length,
      physics: const AlwaysScrollableScrollPhysics(),
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final player = players[index];
        return AnimatedPlayerCard(
          player: player,
          isSelected: selectedPlayer == player,
          onTap: () => onPlayerTap(player),
          onPlayerSelected: onPlayerSelected,
          animationDelay: index * 50, // Staggered animation
        );
      },
    );
  }
}
