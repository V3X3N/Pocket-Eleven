import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/firebase/auth_functions.dart';
import 'package:pocket_eleven/pages/home_page.dart';
import 'package:pocket_eleven/pages/loading/loginPage/temp_login_page.dart';
import 'package:pocket_eleven/pages/loading/registerPage/temp_register_page.dart';

// Simplified result class
sealed class LoadingResult {
  const LoadingResult();
}

class LoadingSuccess extends LoadingResult {
  final Widget page;
  const LoadingSuccess(this.page);
}

class LoadingError extends LoadingResult {
  final String message;
  const LoadingError(this.message);
}

// Streamlined controller with essential functionality
class LoadingScreenController extends ChangeNotifier {
  bool _isLoading = true;
  String? _errorMessage;

  // Performance constants
  static const _minLoadTime = Duration(seconds: 1);
  static const _authTimeout = Duration(seconds: 10);
  static const _maxRetries = 2;

  int _retryCount = 0;
  final _stopwatch = Stopwatch();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<Widget?> initialize() async {
    _stopwatch.start();
    return _executeWithRetry();
  }

  Future<Widget?> _executeWithRetry() async {
    while (_retryCount <= _maxRetries) {
      try {
        final result = await _performLoading();
        return switch (result) {
          LoadingSuccess(page: final page) => page,
          LoadingError(message: final msg) => throw Exception(msg),
        };
      } catch (e) {
        if (_retryCount >= _maxRetries) {
          _setError('Failed after $_maxRetries attempts: ${e.toString()}');
          return null;
        }
        _retryCount++;
        await Future.delayed(Duration(milliseconds: 500 * _retryCount));
      }
    }
    return null;
  }

  Future<LoadingResult> _performLoading() async {
    try {
      // Parallel execution for better performance
      final authFuture = _authenticate().timeout(_authTimeout);
      final minTimeFuture = _ensureMinTime();

      final results = await Future.wait([authFuture, minTimeFuture]);
      return results.first as LoadingResult;
    } catch (e) {
      return LoadingError('Authentication failed: ${e.toString()}');
    }
  }

  Future<LoadingResult> _authenticate() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user?.email == null) {
      return const LoadingSuccess(TempLoginPage());
    }

    // Validate session and check club status in parallel
    final futures = await Future.wait([
      _validateSession(user!),
      AuthServices.userHasClub(user.email!),
    ]);

    final hasClub = futures[1] as bool;
    final page = hasClub ? const HomePage() : const TempRegisterPage();

    return LoadingSuccess(page);
  }

  Future<void> _validateSession(User user) async {
    await user.reload();
    if (FirebaseAuth.instance.currentUser == null) {
      throw Exception('Session expired');
    }
  }

  Future<void> _ensureMinTime() async {
    final elapsed = _stopwatch.elapsed;
    final remaining = _minLoadTime - elapsed;
    if (remaining > Duration.zero) {
      await Future.delayed(remaining);
    }
  }

  void retry() {
    _retryCount = 0;
    _errorMessage = null;
    _isLoading = true;
    _stopwatch.reset();
    _stopwatch.start();
    notifyListeners();

    _executeWithRetry().then((page) {
      if (page != null) _setSuccess();
    });
  }

  void _setError(String error) {
    _isLoading = false;
    _errorMessage = error;
    notifyListeners();
  }

  void _setSuccess() {
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }
}
