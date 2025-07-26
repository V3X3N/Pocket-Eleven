import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/under_development_widget.dart';

class ScoutingView extends StatelessWidget {
  const ScoutingView({super.key, required this.onCurrencyChange});
  final VoidCallback onCurrencyChange;

  @override
  Widget build(BuildContext context) {
    return const UnderDevelopmentWidget(
      title: 'Scouting under development',
      message:
          'Player scouting features are being enhanced.\nNew advanced scouting system coming soon!',
      icon: Icons.search_rounded,
    );
  }
}
