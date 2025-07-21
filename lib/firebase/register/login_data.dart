import 'package:flutter/material.dart';

// Immutable data class for login with built-in validation
@immutable
class LoginData {
  final String email;
  final String password;

  const LoginData({
    required this.email,
    required this.password,
  });

  String? validate() {
    final trimmed = this.trimmed;

    // Required field checks
    if (trimmed.email.isEmpty) return 'Email is required';
    if (password.isEmpty) return 'Password is required';

    // Format validation for email
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(trimmed.email)) {
      return 'Invalid email format';
    }

    // Minimum password length
    if (password.length < 6) return 'Password must be at least 6 characters';

    return null;
  }

  LoginData get trimmed => LoginData(
        email: email.trim().toLowerCase(),
        password: password,
      );
}
