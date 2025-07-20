import 'package:flutter/material.dart';
import 'package:pocket_eleven/pages/transfers/widgets/under_development_widget.dart';

class FormationView extends StatelessWidget {
  const FormationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const UnderDevelopmentWidget(
      title: 'Formation under development',
      message:
          'Formation management system is being redesigned.\nAdvanced tactical options coming soon!',
      icon: Icons.sports_soccer_rounded,
    );
  }
}
