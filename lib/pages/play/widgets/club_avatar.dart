import 'package:flutter/material.dart';

/// A club avatar widget displaying team crest with fallback icon.
///
/// This widget provides:
/// - Responsive sizing with cached scaling
/// - Image caching for performance
/// - Hero animation support
/// - Fallback UI for missing images
/// - Rounded corners with shadow
///
/// Usage:
/// ```dart
/// ClubAvatar(
///   imagePath: 'assets/crests/crest_1.png',
///   size: 80,
///   screenWidth: MediaQuery.of(context).size.width,
/// )
/// ```
class ClubAvatar extends StatelessWidget {
  /// Creates a club avatar widget.
  ///
  /// [imagePath] - Path to the club crest image
  /// [size] - Base size for the avatar
  /// [screenWidth] - Screen width for responsive scaling
  /// [heroTag] - Optional hero tag for animations
  const ClubAvatar({
    super.key,
    required this.imagePath,
    required this.size,
    required this.screenWidth,
    this.heroTag,
  });

  final String imagePath;
  final double size;
  final double screenWidth;
  final String? heroTag;

  static final _scaleCache = <String, double>{};

  double _getScaledSize() => _scaleCache.putIfAbsent('${screenWidth}_$size',
      () => size * (screenWidth / 375.0).clamp(0.8, 2.0));

  @override
  Widget build(BuildContext context) {
    final scaledSize = _getScaledSize();

    Widget avatar = Container(
      height: scaledSize,
      width: scaledSize,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Color(0x261A1A2E), // AppColors.primaryColor with 15% opacity
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
          cacheHeight: scaledSize.toInt(),
          cacheWidth: scaledSize.toInt(),
          errorBuilder: (_, __, ___) => Container(
            decoration: const BoxDecoration(
              color:
                  Color(0x4D717483), // AppColors.borderColor with 30% opacity
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Icon(
              Icons.sports_soccer_rounded,
              size: scaledSize * 0.5,
              color: const Color(
                  0x99F8F5FA), // AppColors.textEnabledColor with 60% opacity
            ),
          ),
        ),
      ),
    );

    return heroTag != null ? Hero(tag: heroTag!, child: avatar) : avatar;
  }
}
