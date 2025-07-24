import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Immutable data model for stadium state
@immutable
class StadiumData {
  final Map<String, int> sectorLevels;
  final int stadiumLevel;
  final double userMoney;

  const StadiumData({
    required this.sectorLevels,
    required this.stadiumLevel,
    required this.userMoney,
  });

  StadiumData copyWith({
    Map<String, int>? sectorLevels,
    int? stadiumLevel,
    double? userMoney,
  }) {
    return StadiumData(
      sectorLevels: sectorLevels ?? this.sectorLevels,
      stadiumLevel: stadiumLevel ?? this.stadiumLevel,
      userMoney: userMoney ?? this.userMoney,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StadiumData &&
          runtimeType == other.runtimeType &&
          stadiumLevel == other.stadiumLevel &&
          userMoney == other.userMoney &&
          _mapsEqual(sectorLevels, other.sectorLevels);

  @override
  int get hashCode =>
      sectorLevels.hashCode ^ stadiumLevel.hashCode ^ userMoney.hashCode;

  static bool _mapsEqual(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

// State management notifier for stadium data
class StadiumNotifier extends ValueNotifier<StadiumData?> {
  static final StadiumNotifier _instance = StadiumNotifier._internal();
  factory StadiumNotifier() => _instance;
  StadiumNotifier._internal() : super(null);

  // Constants for cost calculation
  static const int baseCost = 75000;
  static const int costMultiplier = 75000;

  Future<void> loadStadiumData() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) return;

      final data = userDoc.data()!;
      value = StadiumData(
        sectorLevels: Map<String, int>.from(data['sectorLevel'] ?? {}),
        stadiumLevel: data['stadiumLevel'] ?? 0,
        userMoney: (data['money'] ?? 0).toDouble(),
      );
    } catch (e) {
      debugPrint('Error loading stadium data: $e');
    }
  }

  Future<bool> upgradeSector(int sectorIndex) async {
    final currentData = value;
    if (currentData == null) return false;

    final sectorKey = 'sector$sectorIndex';
    final currentLevel = currentData.sectorLevels[sectorKey] ?? 0;
    final upgradeCost = calculateUpgradeCost(currentLevel);

    if (currentLevel >= currentData.stadiumLevel) {
      debugPrint('Cannot upgrade sector $sectorIndex beyond stadium level');
      return false;
    }

    if (currentData.userMoney < upgradeCost) {
      debugPrint('Insufficient funds for sector $sectorIndex upgrade');
      return false;
    }

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return false;

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final userDocRef =
            FirebaseFirestore.instance.collection('users').doc(userId);

        final userDoc = await transaction.get(userDocRef);
        if (!userDoc.exists) throw Exception("User document does not exist!");

        transaction.update(userDocRef, {
          'sectorLevel.$sectorKey': currentLevel + 1,
          'money': currentData.userMoney - upgradeCost,
        });
      });

      // Update local state
      final newSectorLevels = Map<String, int>.from(currentData.sectorLevels);
      newSectorLevels[sectorKey] = currentLevel + 1;

      value = currentData.copyWith(
        sectorLevels: newSectorLevels,
        userMoney: currentData.userMoney - upgradeCost,
      );

      return true;
    } catch (e) {
      debugPrint('Error upgrading sector $sectorIndex: $e');
      return false;
    }
  }

  static int calculateUpgradeCost(int currentLevel) {
    return baseCost * (currentLevel + 1) + costMultiplier;
  }
}

// Extension for convenient access to stadium data
extension StadiumDataExtensions on StadiumData {
  bool canUpgradeSector(int sectorIndex) {
    final sectorKey = 'sector$sectorIndex';
    final currentLevel = sectorLevels[sectorKey] ?? 0;
    final upgradeCost = StadiumNotifier.calculateUpgradeCost(currentLevel);

    return currentLevel < stadiumLevel && userMoney >= upgradeCost;
  }

  int getSectorLevel(int sectorIndex) {
    return sectorLevels['sector$sectorIndex'] ?? 0;
  }
}
