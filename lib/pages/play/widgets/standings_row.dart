import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A reusable row widget for displaying team standings data
///
/// Features:
/// - Responsive design with proper spacing
/// - Position indicator with color coding
/// - Interactive tap functionality
/// - Goal difference color coding
/// - Optimized rendering with RepaintBoundary
class StandingsRow extends StatelessWidget {
  /// Creates a standings row
  ///
  /// [position] - Team position in the league (1-based)
  /// [teamName] - Name of the team
  /// [matchesPlayed] - Number of matches played
  /// [goalsFor] - Goals scored by the team
  /// [goalsAgainst] - Goals conceded by the team
  /// [points] - Total points earned
  /// [onTap] - Callback when row is tapped
  /// [backgroundColor] - Background color for the row
  const StandingsRow({
    required this.position,
    required this.teamName,
    required this.matchesPlayed,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.points,
    this.onTap,
    this.backgroundColor = AppColors.primaryColor,
    super.key,
  });

  final int position;
  final String teamName;
  final int matchesPlayed;
  final int goalsFor;
  final int goalsAgainst;
  final int points;
  final VoidCallback? onTap;
  final Color backgroundColor;

  int get goalDifference => goalsFor - goalsAgainst;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final positionColor = _getPositionColor();

    return RepaintBoundary(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: screenWidth * 0.01),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: AppColors.borderColor.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(screenWidth * 0.03),
              child: Row(
                children: [
                  _PositionIndicator(
                    position: position,
                    color: positionColor,
                    size: screenWidth * 0.06,
                  ),
                  SizedBox(width: screenWidth * 0.03),
                  Expanded(
                    flex: 3,
                    child: Text(
                      teamName,
                      style: TextStyle(
                        color: AppColors.textEnabledColor,
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.038,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _StatCell(matchesPlayed.toString()),
                  _StatCell(goalsFor.toString()),
                  _StatCell(goalsAgainst.toString()),
                  _StatCell(
                    goalDifference.toString(),
                    color: goalDifference > 0
                        ? AppColors.successColor
                        : goalDifference < 0
                            ? AppColors.errorColor
                            : AppColors.textEnabledColor,
                  ),
                  _StatCell(
                    points.toString(),
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPositionColor() {
    if (position <= 4) return AppColors.successColor;
    if (position <= 6) return AppColors.warningColor;
    if (position >= 18) return AppColors.errorColor;
    return AppColors.borderColor;
  }
}

class _PositionIndicator extends StatelessWidget {
  const _PositionIndicator({
    required this.position,
    required this.color,
    required this.size,
  });

  final int position;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 4,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          position.toString(),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell(
    this.value, {
    this.color = AppColors.textEnabledColor,
    this.fontWeight,
  });

  final String value;
  final Color color;
  final FontWeight? fontWeight;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Expanded(
      child: Center(
        child: Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: fontWeight,
            fontSize: screenWidth * 0.035,
          ),
        ),
      ),
    );
  }
}
