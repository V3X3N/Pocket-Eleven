import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/functions/image_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pocket_eleven/pages/loading/temp_login_page.dart';
import 'package:pocket_eleven/pages/loading/temp_register_page.dart';

class TempLoadingScreen extends StatefulWidget {
  const TempLoadingScreen({super.key});

  @override
  State<TempLoadingScreen> createState() => _TempLoadingScreenState();
}

class _TempLoadingScreenState extends State<TempLoadingScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // Cache expensive computations
  late final double _screenHeight;
  late final double _logoTopPosition;

  // Precalculated constants for better performance
  static const Duration _loadingDelay = Duration(seconds: 2);
  static const Duration _navigationTimeout = Duration(seconds: 10);
  static const double _logoFontSize = 44.0;
  static const double _logoSpacing = 10.0;
  static const double _loadingSpacing = 20.0;
  static const double _loadingSize = 50.0;
  static const double _logoPositionFactor = 0.25;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initializeScreen() {
    // Cache screen dimensions to avoid repeated MediaQuery calls
    _screenHeight = MediaQuery.of(context).size.height;
    _logoTopPosition = _screenHeight * _logoPositionFactor;

    // Start loading process
    _loadResourcesWithErrorHandling();
  }

  Future<void> _loadResourcesWithErrorHandling() async {
    try {
      await _loadResources();
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load resources: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _loadResources() async {
    try {
      // Preload images with error handling
      await _precacheImagesWithTimeout();

      // Minimum loading time for UX
      await Future.delayed(_loadingDelay);

      if (mounted) {
        await _handleAuthenticationWithTimeout();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Loading failed: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _precacheImagesWithTimeout() async {
    try {
      await Future.any([
        ImageLoader.precacheImages(context),
        Future.delayed(const Duration(seconds: 5)) // Timeout for image loading
      ]);
    } catch (e) {
      // Log error but continue - images are not critical for app flow
      debugPrint('Image precaching failed: $e');
    }
  }

  Future<void> _handleAuthenticationWithTimeout() async {
    try {
      await Future.any([
        _handleAuthentication(),
        Future.delayed(_navigationTimeout).then((_) => throw TimeoutException(
            'Authentication timeout', _navigationTimeout))
      ]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication failed: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _handleAuthentication() async {
    try {
      // Use single auth state check instead of stream
      final User? user = FirebaseAuth.instance.currentUser;

      if (!mounted) return;

      if (user != null) {
        final bool userHasClub = await AuthServices.userHasClub(user.email!);

        if (mounted) {
          _navigateToPage(
              userHasClub ? const HomePage() : const TempRegisterPage());
        }
      } else {
        if (mounted) {
          _navigateToPage(const TempLoginPage());
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Authentication error: ${e.toString()}';
        });
      }
    }
  }

  void _navigateToPage(Widget page) {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _retryLoading() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _loadResourcesWithErrorHandling();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: AppColors.primaryColor,
        child: Stack(
          alignment: Alignment.center,
          children: [
            RepaintBoundary(
              child: _LoadingContent(
                topPosition: _logoTopPosition,
                isLoading: _isLoading,
                errorMessage: _errorMessage,
                onRetry: _retryLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Extracted stateless widget for better performance
class _LoadingContent extends StatelessWidget {
  final double topPosition;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;

  const _LoadingContent({
    required this.topPosition,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: topPosition,
      child: Column(
        children: [
          // Logo section with RepaintBoundary for optimization
          RepaintBoundary(
            child: _LogoSection(),
          ),

          const SizedBox(height: _TempLoadingScreenState._loadingSpacing),

          // Loading or error section
          if (isLoading)
            RepaintBoundary(
              child: LoadingAnimationWidget.waveDots(
                color: AppColors.textEnabledColor,
                size: _TempLoadingScreenState._loadingSize,
              ),
            )
          else if (errorMessage != null)
            _ErrorSection(
              errorMessage: errorMessage!,
              onRetry: onRetry,
            ),
        ],
      ),
    );
  }
}

// Separate stateless widget for logo to prevent unnecessary rebuilds
class _LogoSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Text(
          'POCKET',
          style: TextStyle(
            fontSize: _TempLoadingScreenState._logoFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textEnabledColor,
          ),
        ),
        SizedBox(height: _TempLoadingScreenState._logoSpacing),
        Text(
          'ELEVEN',
          style: TextStyle(
            fontSize: _TempLoadingScreenState._logoFontSize,
            fontWeight: FontWeight.bold,
            color: AppColors.textEnabledColor,
          ),
        ),
      ],
    );
  }
}

// Error handling section
class _ErrorSection extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const _ErrorSection({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                style: const TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textEnabledColor,
                  foregroundColor: AppColors.primaryColor,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Custom exception for timeout handling
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;

  TimeoutException(this.message, this.timeout);

  @override
  String toString() => 'TimeoutException: $message (${timeout.inSeconds}s)';
}
