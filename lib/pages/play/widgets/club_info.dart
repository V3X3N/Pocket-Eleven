import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'club_avatar.dart';

/// A club information widget displaying avatar and name.
///
/// This widget provides:
/// - Club avatar with responsive sizing
/// - Club name with proper text styling
/// - Text overflow handling
/// - Optimized with RepaintBoundary
///
/// Usage:
/// ```dart
/// ClubInfo(
///   crestPath: 'assets/crests/crest_1.png',
///   clubName: 'Manchester United',
///   screenWidth: MediaQuery.of(context).size.width,
///   avatarSize: 80,
/// )
/// ```
class ClubInfo extends StatelessWidget {
  /// Creates a club info widget.
  ///
  /// [crestPath] - Path to the club crest image
  /// [clubName] - Name of the club to display
  /// [screenWidth] - Screen width for responsive scaling
  /// [avatarSize] - Size of the club avatar
  const ClubInfo({
    super.key,
    required this.crestPath,
    required this.clubName,
    required this.screenWidth,
    this.avatarSize = 80,
  });

  final String crestPath;
  final String clubName;
  final double screenWidth;
  final double avatarSize;

  static final _scaleCache = <String, double>{};

  double _getScaledFontSize(double size) => _scaleCache.putIfAbsent(
      '${screenWidth}_font_$size',
      () => size * (screenWidth / 375.0).clamp(0.8, 2.0));

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClubAvatar(
            imagePath: crestPath,
            size: avatarSize,
            screenWidth: screenWidth,
            heroTag: crestPath,
          ),
          const SizedBox(height: 12),
          Text(
            clubName,
            style: TextStyle(
              color: AppColors.textEnabledColor,
              fontSize: _getScaledFontSize(14),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
