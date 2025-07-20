import 'package:flutter/material.dart';

// Immutable data class with built-in validation
@immutable
class RegisterData {
  final String email;
  final String password;
  final String username;
  final String clubName;
  final String money;

  const RegisterData({
    required this.email,
    required this.password,
    required this.username,
    required this.clubName,
    this.money = '1000000', // Base value of 1,000,000
  });

  String? validate() {
    final trimmed = this.trimmed;

    // Required field checks
    if (trimmed.email.isEmpty) return 'Email is required';
    if (trimmed.username.isEmpty) return 'Username is required';
    if (trimmed.clubName.isEmpty) return 'Club name is required';
    if (password.isEmpty) return 'Password is required';

    // Length validations
    if (trimmed.username.length < 3 || trimmed.username.length > 20) {
      return 'Username must be 3-20 characters';
    }
    if (trimmed.clubName.length < 3 || trimmed.clubName.length > 30) {
      return 'Club name must be 3-30 characters';
    }
    if (password.length < 8) return 'Password must be at least 8 characters';

    // Format validations
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(trimmed.email)) {
      return 'Invalid email format';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(trimmed.username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }

    return null;
  }

  RegisterData get trimmed => RegisterData(
        email: email.trim(),
        password: password,
        username: username.trim(),
        clubName: clubName.trim(),
        money: money,
      );
}
