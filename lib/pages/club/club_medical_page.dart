import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/club/bloc/medical_bloc.dart';

class ClubMedicalPage extends StatelessWidget {
  final VoidCallback onCurrencyChange;

  const ClubMedicalPage({super.key, required this.onCurrencyChange});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double appBarHeight = screenHeight * 0.07;

    return BlocProvider(
      create: (context) => MedicalBloc()..add(LoadMedicalDataEvent()),
      child: Scaffold(
        appBar: ReusableAppBar(appBarHeight: appBarHeight),
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: BlocBuilder<MedicalBloc, MedicalState>(
                builder: (context, state) {
                  if (state is MedicalLoaded) {
                    return Container(
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image:
                              AssetImage('assets/background/club_medical.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05,
                  vertical: screenHeight * 0.02,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<MedicalBloc, MedicalState>(
                      builder: (context, state) {
                        if (state is MedicalLoaded) {
                          return _buildMedicalInfo(
                            context,
                            state.level,
                            state.upgradeCost,
                            state.canUpgrade,
                            onCurrencyChange,
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textEnabledColor,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    const Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          "Our medical center is an essential part of our commitment to our players' health and fitness. "
                          "With a team of experienced doctors and therapists, we offer comprehensive medical care, "
                          "ensuring optimal conditions for rehabilitation and swift recovery from injuries. "
                          "It’s a place where we prioritize every aspect of our athletes' health, providing safety and support throughout their careers.",
                          style: TextStyle(
                            fontSize: 16.0,
                            color: AppColors.textEnabledColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalInfo(BuildContext context, int level, int upgradeCost,
      bool canUpgrade, VoidCallback onCurrencyChange) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Medical Center',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textEnabledColor,
                ),
              ),
              Text(
                'Level $level',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textEnabledColor,
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            ElevatedButton(
              onPressed: canUpgrade
                  ? () {
                      context.read<MedicalBloc>().add(UpgradeMedicalEvent());
                      onCurrencyChange();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondaryColor,
              ),
              child: const Text(
                'Upgrade',
                style: TextStyle(
                  color: AppColors.textEnabledColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Cost: $upgradeCost',
              style: TextStyle(
                color: canUpgrade ? AppColors.green : Colors.grey,
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
