import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A match tile widget for displaying match information.
///
/// This widget provides:
/// - Interactive tile with ripple effect
/// - Opponent name and match time display
/// - Time formatting (days, hours, minutes)
/// - Responsive sizing and styling
/// - Haptic feedback on tap
///
/// Usage:
/// ```dart
/// MatchTile(
///   opponentName: 'Liverpool FC',
///   matchTime: DateTime.now().add(Duration(days: 2)),
///   screenWidth: MediaQuery.of(context).size.width,
///   onTap: () => handleMatchTap(),
/// )
/// ```
class MatchTile extends StatelessWidget {
  /// Creates a match tile widget.
  ///
  /// [opponentName] - Name of the opponent team
  /// [matchTime] - DateTime when the match is scheduled
  /// [screenWidth] - Screen width for responsive scaling
  /// [onTap] - Optional callback when tile is tapped
  const MatchTile({
    super.key,
    required this.opponentName,
    required this.matchTime,
    required this.screenWidth,
    this.onTap,
  });

  final String opponentName;
  final DateTime matchTime;
  final double screenWidth;
  final VoidCallback? onTap;

  static final _scaleCache = <String, double>{};

  double _getScaledFontSize(double size, String type) =>
      _scaleCache.putIfAbsent('${screenWidth}_${type}_$size',
          () => size * (screenWidth / 375.0).clamp(0.8, 2.0));

  /// Formats match time to display relative time (days, hours, minutes)
  String _formatMatchTime() {
    final difference = matchTime.difference(DateTime.now());

    if (difference.inDays > 0) return '${difference.inDays}d';
    if (difference.inHours > 0) return '${difference.inHours}h';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m';
    return 'Now';
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          onTap: onTap != null
              ? () {
                  HapticFeedback.lightImpact();
                  onTap!();
                }
              : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color:
                  Color(0xCC333645), // AppColors.buttonColor with 80% opacity
              borderRadius: BorderRadius.all(Radius.circular(16)),
              border: Border.fromBorderSide(
                BorderSide(
                  color: Color(
                      0x4D717483), // AppColors.borderColor with 30% opacity
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    opponentName,
                    style: TextStyle(
                      fontSize: _getScaledFontSize(16, 'title'),
                      color: AppColors.textEnabledColor,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: const BoxDecoration(
                    color: Color(
                        0xB3212332), // AppColors.hoverColor with 70% opacity
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Text(
                    _formatMatchTime(),
                    style: TextStyle(
                      fontSize: _getScaledFontSize(12, 'time'),
                      color: AppColors.textEnabledColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
