import 'package:flutter/material.dart';

// Sealed result classes for type-safe error handling
@immutable
sealed class RegisterResult {
  const RegisterResult();
}

class RegisterSuccess extends RegisterResult {
  final String userId;
  const RegisterSuccess(this.userId);
}

class RegisterFailure extends RegisterResult {
  final String error;
  final String? code;
  const RegisterFailure(this.error, {this.code});
}
