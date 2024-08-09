import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/components/list_item.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/club/club_stadium_page.dart';
import 'package:pocket_eleven/pages/club/club_training_page.dart';
import 'package:pocket_eleven/pages/club/club_medical_page.dart';
import 'package:pocket_eleven/pages/club/club_youth_page.dart';
import 'package:pocket_eleven/pages/club/bloc/club_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClubPage extends StatelessWidget {
  const ClubPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return BlocProvider(
      create: (context) => ClubBloc()..add(LoadUserDataEvent()),
      child: Scaffold(
        appBar: ReusableAppBar(appBarHeight: screenHeight * 0.07),
        body: Container(
          color: AppColors.primaryColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.04,
                    vertical: screenHeight * 0.02),
                child: BlocBuilder<ClubBloc, ClubState>(
                  builder: (context, state) {
                    if (state is ClubLoading) {
                      return const CircularProgressIndicator();
                    } else if (state is ClubLoaded) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            state.clubName,
                            style: const TextStyle(
                              fontSize: 20,
                              color: AppColors.textEnabledColor,
                            ),
                          ),
                          Image.asset(
                            'assets/crests/crest_1.png',
                            height: screenHeight * 0.05,
                            width: screenHeight * 0.05,
                            fit: BoxFit.contain,
                          ),
                        ],
                      );
                    } else if (state is ClubError) {
                      return Text(
                        'Error: ${state.error}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.red,
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              ),
              Container(
                height: screenHeight * 0.4,
                color: AppColors.primaryColor,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    ListItem(
                      screenWidth: screenWidth,
                      image: Image.asset('assets/background/club_stadion.png'),
                      text: 'Stadium',
                      page: ClubStadiumPage(
                        onCurrencyChange: () =>
                            context.read<ClubBloc>().add(LoadUserDataEvent()),
                      ),
                    ),
                    ListItem(
                      screenWidth: screenWidth,
                      image: Image.asset('assets/background/club_training.png'),
                      text: 'Training',
                      page: ClubTrainingPage(
                        onCurrencyChange: () =>
                            context.read<ClubBloc>().add(LoadUserDataEvent()),
                      ),
                    ),
                    ListItem(
                      screenWidth: screenWidth,
                      image: Image.asset('assets/background/club_medical.png'),
                      text: 'Medical',
                      page: ClubMedicalPage(
                        onCurrencyChange: () =>
                            context.read<ClubBloc>().add(LoadUserDataEvent()),
                      ),
                    ),
                    ListItem(
                      screenWidth: screenWidth,
                      image: Image.asset('assets/background/club_youth.png'),
                      text: 'Youth',
                      page: ClubYouthPage(
                        onCurrencyChange: () =>
                            context.read<ClubBloc>().add(LoadUserDataEvent()),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration:
                      const BoxDecoration(color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
