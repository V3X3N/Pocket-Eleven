import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/pages/loading/loadingScreen/loading_screen_controller.dart';

class TempLoadingScreen extends StatefulWidget {
  const TempLoadingScreen({super.key});

  @override
  State<TempLoadingScreen> createState() => _TempLoadingScreenState();
}

class _TempLoadingScreenState extends State<TempLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final LoadingScreenController _controller;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // UI constants for 60fps optimization
  static const _animDuration = Duration(milliseconds: 200);
  static const _logoSize = 40.0;
  static const _loadingSize = 45.0;

  @override
  void initState() {
    super.initState();
    _initializeController();
    _initializeAnimation();
    _startLoading();
  }

  void _initializeController() {
    _controller = LoadingScreenController();
    _controller.addListener(_onStateChanged);
  }

  void _initializeAnimation() {
    _fadeController = AnimationController(duration: _animDuration, vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));
    _fadeController.forward();
  }

  void _startLoading() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final page = await _controller.initialize();
      if (page != null && mounted) _navigateToPage(page);
    });
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _navigateToPage(Widget page) {
    HapticFeedback.lightImpact();
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => page,
        transitionDuration: _animDuration,
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    _controller.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primaryColor,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with modern glassmorphism effect
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.1),
                        Colors.white.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Animated logo with gradient text
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [
                            Colors.white,
                            Colors.white70,
                          ],
                        ).createShader(bounds),
                        child: const Text(
                          'POCKET\nELEVEN',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _logoSize,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 2,
                            height: 1.1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Status indicator with smooth transitions
                      SizedBox(
                        height: 60,
                        child: AnimatedSwitcher(
                          duration: _animDuration,
                          child: _buildStatusWidget(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget() {
    if (_controller.isLoading) {
      return LoadingAnimationWidget.threeArchedCircle(
        key: const ValueKey('loading'),
        color: AppColors.textEnabledColor,
        size: _loadingSize,
      );
    }

    if (_controller.errorMessage != null) {
      return _ErrorWidget(
        key: const ValueKey('error'),
        message: _controller.errorMessage!,
        onRetry: _controller.retry,
      );
    }

    return const SizedBox.shrink(key: ValueKey('empty'));
  }
}

// Optimized error widget with modern design
class _ErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorWidget({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
          ),
          child: Icon(
            Icons.error_outline,
            color: Colors.red.shade300,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Connection Error',
          style: TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            onRetry();
          },
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Retry'),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textEnabledColor,
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    );
  }
}
