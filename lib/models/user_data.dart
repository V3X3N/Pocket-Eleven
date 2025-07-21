import 'package:flutter/foundation.dart';

/// Immutable data model representing user profile information.
///
/// Contains user's personal information with caching capabilities
/// to optimize data fetching and reduce unnecessary API calls.
///
/// Features:
/// - Immutable design for better state management
/// - Built-in cache staleness detection (5-minute TTL)
/// - Copy-with functionality for partial updates
/// - Timestamp tracking for data freshness
@immutable
class UserData {
  /// User's display name as manager
  final String managerName;

  /// Name of the user's club/team
  final String clubName;

  /// User's email address
  final String email;

  /// Avatar ID (1-10) for profile image
  final int avatar;

  /// Timestamp when data was last fetched
  final DateTime timestamp;

  const UserData({
    required this.managerName,
    required this.clubName,
    required this.email,
    required this.avatar,
    required this.timestamp,
  });

  /// Creates a copy with updated fields and refreshed timestamp
  UserData copyWith({
    String? managerName,
    String? clubName,
    String? email,
    int? avatar,
  }) =>
      UserData(
        managerName: managerName ?? this.managerName,
        clubName: clubName ?? this.clubName,
        email: email ?? this.email,
        avatar: avatar ?? this.avatar,
        timestamp: DateTime.now(),
      );

  /// Checks if data is older than 5 minutes and needs refresh
  bool get isStale => DateTime.now().difference(timestamp).inMinutes > 5;
}
