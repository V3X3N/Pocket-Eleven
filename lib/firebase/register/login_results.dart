import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Sealed result classes for type-safe error handling
@immutable
sealed class LoginResult {
  const LoginResult();
}

class LoginSuccess extends LoginResult {
  final String userId;
  final User user;
  const LoginSuccess(this.userId, this.user);
}

class LoginFailure extends LoginResult {
  final String error;
  final String? code;
  const LoginFailure(this.error, {this.code});
}
