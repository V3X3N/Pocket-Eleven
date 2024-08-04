import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';

class NationalitySelector extends StatelessWidget {
  final String selectedNationality;
  final bool canScout;
  final ValueChanged<String> onNationalityChange;
  final List<String> nationalities;

  const NationalitySelector({
    super.key,
    required this.selectedNationality,
    required this.canScout,
    required this.onNationalityChange,
    required this.nationalities,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: nationalities.map((countryCode) {
          return GestureDetector(
            onTap: () {
              if (canScout) {
                onNationalityChange(countryCode);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 10.0),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: selectedNationality == countryCode
                    ? AppColors.secondaryColor
                    : AppColors.hoverColor,
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Center(
                child: Image.asset(
                  'assets/flags/flag_$countryCode.png',
                  width: 30,
                  height: 20,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
