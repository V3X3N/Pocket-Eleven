import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/club/bloc/youth_bloc.dart';

class ClubYouthPage extends StatelessWidget {
  final VoidCallback onCurrencyChange;

  const ClubYouthPage({super.key, required this.onCurrencyChange});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (context) => YouthBloc()..add(LoadYouthDataEvent()),
      child: Scaffold(
        appBar: ReusableAppBar(appBarHeight: screenHeight * 0.07),
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: 3 / 2,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/background/club_youth.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    BlocBuilder<YouthBloc, YouthState>(
                      builder: (context, state) {
                        if (state is YouthLoaded) {
                          return _buildYouthInfo(
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
                          "Our youth academies are where future football stars develop their skills under the guidance of experienced coaches. "
                          "We provide an inspiring environment for learning and nurturing a passion for soccer, "
                          "shaping not just athletic abilities but also teamwork and determination.",
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

  Widget _buildYouthInfo(
    BuildContext context,
    int level,
    int upgradeCost,
    bool canUpgrade,
    VoidCallback onCurrencyChange,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Youth Academy',
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
                      context.read<YouthBloc>().add(UpgradeYouthEvent());
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
