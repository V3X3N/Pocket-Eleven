import 'package:flutter/material.dart';
import 'package:pocket_eleven/models/player.dart';
import 'package:pocket_eleven/design/colors.dart';

class PlayerDetailsDialog extends StatelessWidget {
  final Player player;

  const PlayerDetailsDialog({super.key, required this.player});

  // Cache text styles to avoid recreation
  static const _titleStyle = TextStyle(
    color: AppColors.textEnabledColor,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const _paramLabelStyle = TextStyle(
    color: AppColors.textEnabledColor,
    fontSize: 22,
  );

  static const _infoStyle = TextStyle(
    color: AppColors.textEnabledColor,
    fontSize: 15,
  );

  static const _closeButtonStyle = TextStyle(
    color: AppColors.textEnabledColor,
    fontSize: 18,
  );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: RepaintBoundary(
        child: Container(
          color: AppColors.primaryColor,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                '${player.name} (${player.position})',
                style: _titleStyle,
              ),
              const SizedBox(height: 16),

              // Basic info grid - optimized with fixed dimensions
              SizedBox(
                height: 100, // Fixed height to prevent layout calculations
                child: _buildBasicInfoGrid(),
              ),

              const SizedBox(height: 20),

              // Parameters grid - optimized with fixed dimensions
              SizedBox(
                height: 160, // Fixed height for 4 rows
                child: _buildParametersGrid(),
              ),

              const SizedBox(height: 16),

              // Close button
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close', style: _closeButtonStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoGrid() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Player image with RepaintBoundary for image caching
        RepaintBoundary(
          child: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: AssetImage(player.imagePath),
              ),
            ),
          ),
        ),

        // Overall rating
        Text('OVR: ${player.ovr}', style: _titleStyle),

        // Flag with RepaintBoundary for image caching
        RepaintBoundary(
          child: Image.asset(
            player.flagPath,
            width: 30,
            height: 30,
            // Cache the image to avoid repeated loading
            cacheWidth: 30,
            cacheHeight: 30,
          ),
        ),
      ],
    );
  }

  Widget _buildParametersGrid() {
    // Pre-build parameter widgets to avoid rebuilding
    final parameterWidgets = [
      _buildInfoRow('Age: ${player.age}'),
      _buildInfoRow('Salary: ${player.salary}'),
      _buildInfoRow('Value: ${player.value}'),
      const SizedBox(height: 8), // Spacer
      _buildParamRow(player.param1Name, player.param1.toString()),
      _buildParamRow(player.param2Name, player.param2.toString()),
      _buildParamRow(player.param3Name, player.param3.toString()),
      _buildParamRow(player.param4Name, player.param4.toString()),
    ];

    return Column(
      children: parameterWidgets,
    );
  }

  Widget _buildInfoRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text(text, style: _infoStyle),
    );
  }

  Widget _buildParamRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: _paramLabelStyle,
              textAlign: TextAlign.left,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: _paramLabelStyle,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
