import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/design/colors.dart';

/// A responsive loading animation widget with cached scaling.
///
/// This widget provides a consistent loading animation across the app with:
/// - Cached responsive scaling based on screen width
/// - Three arched circle animation
/// - Consistent color theming
///
/// Usage:
/// ```dart
/// ResponsiveLoadingWidget(
///   screenWidth: MediaQuery.of(context).size.width,
///   size: 40,
/// )
/// ```
class ResponsiveLoadingWidget extends StatelessWidget {
  /// Creates a responsive loading widget.
  ///
  /// [screenWidth] - Current screen width for responsive scaling
  /// [size] - Base size for the loading animation
  const ResponsiveLoadingWidget({
    super.key,
    required this.screenWidth,
    this.size = 40,
  });

  final double screenWidth;
  final double size;

  static final _scaleCache = <String, double>{};

  /// Cached responsive scaling calculation
  double _getScaledSize() => _scaleCache.putIfAbsent('${screenWidth}_$size',
      () => size * (screenWidth / 375.0).clamp(0.8, 2.0));

  @override
  Widget build(BuildContext context) {
    return LoadingAnimationWidget.threeArchedCircle(
      color: AppColors.textEnabledColor,
      size: _getScaledSize(),
    );
  }
}
