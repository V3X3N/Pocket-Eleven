import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/club/widget/stadium_confirm_dialog.dart';

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
      builder: (context) => CustomConfirmDialog(
        title: 'Upgrade ${_getSectorName(index)}',
        message: 'Current Level: $currentLevel\n'
            'Upgrade Cost: \$${upgradeCost.toString()}\n'
            'Do you want to upgrade this sector?',
        onConfirm: () async {
          final success = await _stadiumNotifier.upgradeSector(index);
          if (!success && mounted) {
            _showSnackBar('Failed to upgrade ${_getSectorName(index)}');
          }
        },
        onCancel: () {
          debugPrint('Upgrade cancelled for sector $index');
        },
      ),
    );
  }

  String _getSectorName(int index) {
    switch (index) {
      case 1:
        return 'North Stand';
      case 2:
        return 'North Main';
      case 3:
        return 'Northeast Stand';
      case 4:
        return 'West Stand';
      case 5:
        return 'Main Pitch';
      case 6:
        return 'East Stand';
      case 7:
        return 'Southwest Stand';
      case 8:
        return 'South Main';
      case 9:
        return 'Southeast Stand';
      default:
        return 'Sector $index';
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primaryColor, AppColors.secondaryColor],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blueColor.withValues(alpha: 0.3),
                ),
                child: const Icon(
                  Icons.stadium,
                  color: AppColors.textEnabledColor,
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Loading Stadium...',
                style: TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ValueListenableBuilder<StadiumData?>(
      valueListenable: _stadiumNotifier,
      builder: (context, data, child) {
        if (data == null) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.primaryColor, AppColors.secondaryColor],
              ),
            ),
            child: const Center(
              child: Text(
                'No stadium data available',
                style: TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: 18,
                ),
              ),
            ),
          );
        }

        return _StaticStadiumLayout(
          stadiumData: data,
          onSectorTapped: _onSectorTapped,
        );
      },
    );
  }
}

// Static stadium layout with no animations
class _StaticStadiumLayout extends StatelessWidget {
  final StadiumData stadiumData;
  final Function(int) onSectorTapped;

  const _StaticStadiumLayout({
    required this.stadiumData,
    required this.onSectorTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primaryColor,
      ),
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildStadiumView(),
                  ),
                ),
              ),
            ),
            _buildBottomStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.blueColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.stadium,
              color: AppColors.blueColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stadium Manager',
                  style: TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Level ${stadiumData.stadiumLevel} Stadium',
                  style: TextStyle(
                    color: AppColors.coffeeText,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.green,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '\$${stadiumData.userMoney.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: AppColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStadiumView() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top stands
          _buildStandRow([1, 2, 3], 'North Stands'),
          const SizedBox(height: 20),

          // Middle section with side stands and pitch
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSideStand(4, 'West Stand'),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 4,
                child: _buildPitch(),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 2,
                child: _buildSideStand(6, 'East Stand'),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Bottom stands
          _buildStandRow([7, 8, 9], 'South Stands'),
        ],
      ),
    );
  }

  Widget _buildStandRow(List<int> indices, String rowName) {
    return Column(
      children: [
        Text(
          rowName,
          style: TextStyle(
            color: AppColors.coffeeText,
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: indices.map((index) {
            final isMiddle = index == indices[1];
            return Expanded(
              flex: isMiddle ? 3 : 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isMiddle ? 8 : 4),
                child: _StadiumSector(
                  index: index,
                  data: stadiumData,
                  onTap: onSectorTapped,
                  isMainStand: isMiddle,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSideStand(int index, String name) {
    return Column(
      children: [
        Text(
          name,
          style: TextStyle(
            color: AppColors.coffeeText,
            fontSize: 10,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        _StadiumSector(
          index: index,
          data: stadiumData,
          onTap: onSectorTapped,
          height: 120,
        ),
      ],
    );
  }

  Widget _buildPitch() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.8,
          colors: [
            AppColors.green.withValues(alpha: 0.8),
            AppColors.green.withValues(alpha: 0.4),
            AppColors.green.withValues(alpha: 0.2),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // Pitch lines
          CustomPaint(
            size: Size.infinite,
            painter: _PitchPainter(),
          ),
          // Center logo/text
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.sports_soccer,
                    color: AppColors.textEnabledColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'PITCH',
                    style: TextStyle(
                      color: AppColors.textEnabledColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStats() {
    final totalCapacity = _calculateTotalCapacity();
    final upgradableCount = _getUpgradableSectorCount();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.buttonColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            icon: Icons.people,
            label: 'Capacity',
            value: totalCapacity.toString(),
            color: AppColors.blueColor,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.borderColor.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            icon: Icons.upgrade,
            label: 'Upgradable',
            value: upgradableCount.toString(),
            color: AppColors.playerGold,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.borderColor.withValues(alpha: 0.3),
          ),
          _buildStatItem(
            icon: Icons.star,
            label: 'Level',
            value: stadiumData.stadiumLevel.toString(),
            color: AppColors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textEnabledColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppColors.coffeeText,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  int _calculateTotalCapacity() {
    int total = 0;
    for (int i = 1; i <= 9; i++) {
      if (i != 5) {
        // Exclude pitch
        final level = stadiumData.getSectorLevel(i);
        total += (level * 1000); // Assume 1000 capacity per level
      }
    }
    return total;
  }

  int _getUpgradableSectorCount() {
    int count = 0;
    for (int i = 1; i <= 9; i++) {
      if (i != 5 && stadiumData.canUpgradeSector(i)) {
        count++;
      }
    }
    return count;
  }
}

// Individual stadium sector with original button design
class _StadiumSector extends StatelessWidget {
  final int index;
  final StadiumData data;
  final Function(int) onTap;
  final double? height;
  final bool isMainStand;

  const _StadiumSector({
    required this.index,
    required this.data,
    required this.onTap,
    this.height,
    this.isMainStand = false,
  });

  @override
  Widget build(BuildContext context) {
    final level = data.getSectorLevel(index);
    final canUpgrade = data.canUpgradeSector(index);
    StadiumNotifier.calculateUpgradeCost(level);

    Color getSectorColor() {
      if (level == 0) return AppColors.borderColor.withValues(alpha: 0.3);
      if (level <= 2) return AppColors.playerBronze;
      if (level <= 4) return AppColors.playerSilver;
      if (level <= 6) return AppColors.playerGold;
      return AppColors.playerPurple;
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        height: height ?? (isMainStand ? 60 : 50),
        decoration: BoxDecoration(
          color: AppColors.buttonColor.withValues(alpha: 0.3),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: getSectorColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: canUpgrade
                  ? AppColors.blueColor
                  : AppColors.borderColor.withValues(alpha: 0.5),
              width: canUpgrade ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              // Level indicator
              if (level > 0)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'L$level',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Upgrade indicator
              if (canUpgrade)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: AppColors.blueColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                      size: 10,
                    ),
                  ),
                ),

              // Center content
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chair,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: isMainStand ? 20 : 16,
                    ),
                    if (height != null || isMainStand) ...[
                      const SizedBox(height: 2),
                      Text(
                        '\${cost ~/ 1000}K',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for pitch lines
class _PitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final width = size.width;
    final height = size.height;

    // Outer boundary - no border, just the lines
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(8, 8, width - 16, height - 16),
      const Radius.circular(4),
    );
    canvas.drawRRect(outerRect, paint);

    // Center line
    canvas.drawLine(
      Offset(width / 2, 8),
      Offset(width / 2, height - 8),
      paint,
    );

    // Center circle
    canvas.drawCircle(
      Offset(width / 2, height / 2),
      20,
      paint,
    );

    // Goal areas (simplified)
    final goalWidth = width * 0.15;
    final goalHeight = height * 0.4;

    // Left goal area
    canvas.drawRect(
      Rect.fromLTWH(8, (height - goalHeight) / 2, goalWidth, goalHeight),
      paint,
    );

    // Right goal area
    canvas.drawRect(
      Rect.fromLTWH(width - 8 - goalWidth, (height - goalHeight) / 2, goalWidth,
          goalHeight),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
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
