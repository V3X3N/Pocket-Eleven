import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/club/widget/stadium_confirm_dialog.dart';
import 'package:pocket_eleven/pages/club/widget/stadium_painter.dart';

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

class StadiumBuild extends StatefulWidget {
  const StadiumBuild({super.key});

  @override
  StadiumBuildState createState() => StadiumBuildState();
}

class StadiumBuildState extends State<StadiumBuild> {
  final StadiumNotifier _stadiumNotifier = StadiumNotifier();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _stadiumNotifier.loadStadiumData();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _onSectorTapped(int index) {
    final data = _stadiumNotifier.value;
    if (data == null) return;

    final sectorKey = 'sector$index';
    final currentLevel = data.sectorLevels[sectorKey] ?? 0;
    final upgradeCost = StadiumNotifier.calculateUpgradeCost(currentLevel);

    showDialog(
      context: context,
      builder: (context) => StadiumConfirmDialog(
        title: 'Upgrade Sector $index',
        message: 'Current Level: $currentLevel\n'
            'Upgrade Cost: \$${upgradeCost.toString()}\n'
            'Do you want to upgrade?',
        onConfirm: () async {
          final success = await _stadiumNotifier.upgradeSector(index);
          if (!success && mounted) {
            _showSnackBar('Failed to upgrade sector $index');
          }
        },
        onCancel: () {
          debugPrint('Upgrade cancelled for sector $index');
        },
      ),
    );
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ValueListenableBuilder<StadiumData?>(
      valueListenable: _stadiumNotifier,
      builder: (context, data, child) {
        if (data == null) {
          return const Center(child: Text('No stadium data available'));
        }

        return _StadiumLayout(
          stadiumData: data,
          onSectorTapped: _onSectorTapped,
        );
      },
    );
  }
}

// Separate stateless widget for stadium layout
class _StadiumLayout extends StatelessWidget {
  final StadiumData stadiumData;
  final Function(int) onSectorTapped;

  const _StadiumLayout({
    required this.stadiumData,
    required this.onSectorTapped,
  });

  // Pre-computed constants for layout
  static const double _containerPadding = 16.0;
  static const double _containerBorderRadius = 16.0;
  static const double _containerBorderWidth = 1.0;
  static const double _sectorSpacing = 10.0;
  static const double _rowSpacing = 10.0;
  static const double _screenWidthRatio = 1.0;
  static const double _centerSquareRatio = 2.0 / 3.0;

  // Pre-computed decoration to avoid recreation
  static const BoxDecoration _containerDecoration = BoxDecoration(
    color: AppColors.hoverColor,
    borderRadius: BorderRadius.all(Radius.circular(_containerBorderRadius)),
    border: Border.fromBorderSide(
      BorderSide(color: AppColors.borderColor, width: _containerBorderWidth),
    ),
    boxShadow: [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.1),
        blurRadius: 8.0,
        spreadRadius: 4.0,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final gridSize = screenWidth * _screenWidthRatio;
    final smallSquareWidth = gridSize / 8;
    final smallSquareHeight = smallSquareWidth;
    final centerSquareWidth = smallSquareWidth * 4;
    final centerSquareHeight = centerSquareWidth;
    final reducedCenterSquareWidth = centerSquareWidth * _centerSquareRatio;

    return RepaintBoundary(
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(_containerPadding),
          decoration: _containerDecoration,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTopRow(
                smallSquareWidth,
                smallSquareHeight,
                reducedCenterSquareWidth,
              ),
              const SizedBox(height: _rowSpacing),
              _buildMiddleRow(
                smallSquareWidth,
                centerSquareHeight,
                reducedCenterSquareWidth,
              ),
              const SizedBox(height: _rowSpacing),
              _buildBottomRow(
                smallSquareWidth,
                smallSquareHeight,
                reducedCenterSquareWidth,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopRow(
      double smallWidth, double smallHeight, double centerWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SectorTile(
          index: 1,
          width: smallWidth,
          height: smallHeight,
          onTap: onSectorTapped,
        ),
        const SizedBox(width: _sectorSpacing),
        _SectorTile(
          index: 2,
          width: centerWidth,
          height: smallHeight,
          onTap: onSectorTapped,
        ),
        const SizedBox(width: _sectorSpacing),
        _SectorTile(
          index: 3,
          width: smallWidth,
          height: smallHeight,
          onTap: onSectorTapped,
        ),
      ],
    );
  }

  Widget _buildMiddleRow(
      double smallWidth, double centerHeight, double centerWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SectorTile(
          index: 4,
          width: smallWidth,
          height: centerHeight,
          onTap: onSectorTapped,
        ),
        const SizedBox(width: _sectorSpacing),
        _SectorTile(
          index: 5,
          width: centerWidth,
          height: centerHeight,
          onTap: onSectorTapped,
          isCenter: true,
        ),
        const SizedBox(width: _sectorSpacing),
        _SectorTile(
          index: 6,
          width: smallWidth,
          height: centerHeight,
          onTap: onSectorTapped,
        ),
      ],
    );
  }

  Widget _buildBottomRow(
      double smallWidth, double smallHeight, double centerWidth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SectorTile(
          index: 7,
          width: smallWidth,
          height: smallHeight,
          onTap: onSectorTapped,
        ),
        const SizedBox(width: _sectorSpacing),
        _SectorTile(
          index: 8,
          width: centerWidth,
          height: smallHeight,
          onTap: onSectorTapped,
        ),
        const SizedBox(width: _sectorSpacing),
        _SectorTile(
          index: 9,
          width: smallWidth,
          height: smallHeight,
          onTap: onSectorTapped,
        ),
      ],
    );
  }
}

// Individual sector tile widget for optimal rebuilding
class _SectorTile extends StatelessWidget {
  final int index;
  final double width;
  final double height;
  final Function(int) onTap;
  final bool isCenter;

  const _SectorTile({
    required this.index,
    required this.width,
    required this.height,
    required this.onTap,
    this.isCenter = false,
  });

  // Pre-computed constants
  static const Duration _animationDuration = Duration(milliseconds: 200);
  static const double _borderRadius = 8.0;
  static const double _borderWidth = 2.0;
  static const Color _shadowColor = Color.fromRGBO(0, 0, 0, 0.2);
  static const double _shadowBlurRadius = 4.0;
  static const double _shadowSpreadRadius = 2.0;

  @override
  Widget build(BuildContext context) {
    final color = isCenter ? Colors.lightGreen.shade400 : AppColors.buttonColor;
    final borderColor = isCenter ? Colors.white : AppColors.borderColor;

    return RepaintBoundary(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: _animationDuration,
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                const BorderRadius.all(Radius.circular(_borderRadius)),
            border: Border.all(
              color: borderColor,
              width: _borderWidth,
            ),
            boxShadow: const [
              BoxShadow(
                color: _shadowColor,
                blurRadius: _shadowBlurRadius,
                spreadRadius: _shadowSpreadRadius,
              ),
            ],
          ),
          child: isCenter
              ? CustomPaint(
                  painter: LinePainter(width: width, height: height),
                  child: Container(),
                )
              : null,
        ),
      ),
    );
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
