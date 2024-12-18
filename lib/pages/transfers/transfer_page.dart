import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/option_button.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/pages/transfers/class/scouting_view.dart';
import 'package:pocket_eleven/pages/transfers/class/transfers_view.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key, required this.onCurrencyChange});
  final VoidCallback onCurrencyChange;

  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage> {
  int _selectedIndex = 0;

  void _onOptionSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: ReusableAppBar(appBarHeight: screenHeight * 0.07),
      body: Container(
        color: AppColors.primaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenHeight * 0.02,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OptionButton(
                    index: 0,
                    text: 'Transfers',
                    onTap: () => _onOptionSelected(0),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    selectedIndex: _selectedIndex,
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  OptionButton(
                    index: 1,
                    text: 'Scouting',
                    onTap: () => _onOptionSelected(1),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                    selectedIndex: _selectedIndex,
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  const TransfersView(),
                  ScoutingView(onCurrencyChange: widget.onCurrencyChange),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
