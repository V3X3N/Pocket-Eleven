import 'package:flutter/material.dart';
import 'package:pocket_eleven/components/custom_appbar.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/models/player.dart';

class TacticPage extends StatefulWidget {
  const TacticPage({super.key});

  @override
  State<TacticPage> createState() => _TacticPageState();
}

class _TacticPageState extends State<TacticPage> {
  int _selectedIndex = 0;
  Map<String, Player?> fieldPositions = {
    'ST1': null,
    'ST2': null,
    'LM': null,
    'RM': null,
    'CM1': null,
    'CM2': null,
    'CM3': null,
    'CAM': null,
    'CDM1': null,
    'CDM2': null,
    'LB': null,
    'CB1': null,
    'CB2': null,
    'CB3': null,
    'RB': null,
    'GK': null,
  };
  String selectedFormation = '4-4-2';
  String? draggedPlayerOriginalPosition;

  final Map<String, List<String>> formations = {
    '4-4-2': [
      'ST1',
      'ST2',
      'LM',
      'CM1',
      'CM2',
      'RM',
      'LB',
      'CB1',
      'CB2',
      'RB',
      'GK'
    ],
    '4-3-3': [
      'ST1',
      'LW',
      'RW',
      'CM1',
      'CM2',
      'CM3',
      'LB',
      'CB1',
      'CB2',
      'RB',
      'GK'
    ],
    '3-5-2': [
      'ST1',
      'ST2',
      'CAM',
      'LM',
      'CDM1',
      'CDM2',
      'RM',
      'CB1',
      'CB2',
      'CB3',
      'GK'
    ],
  };

  final Map<String, String> positionAbbreviations = {
    'LW': 'LW',
    'ST1': 'ST',
    'ST2': 'ST',
    'RW': 'RW',
    'LM': 'LM',
    'RM': 'RM',
    'CM1': 'CM',
    'CM2': 'CM',
    'CM3': 'CM',
    'CAM': 'CAM',
    'CDM1': 'CDM',
    'CDM2': 'CDM',
    'LB': 'LB',
    'CB1': 'CB',
    'CB2': 'CB',
    'CB3': 'CB',
    'RB': 'RB',
    'GK': 'GK',
  };

  final Map<String, Map<String, String>> positionMapping = {
    '4-4-2': {
      'CB3': 'RB',
      'CDM1': 'LB',
      'RW': 'ST2',
      'LW': 'LM',
      'CAM': 'CM1',
      'CDM2': 'CM2',
      'CM3': 'RM',
    },
    '4-3-3': {
      'CB3': 'RB',
      'CDM1': 'LB',
      'ST2': 'RW',
      'LM': 'LW',
      'CAM': 'CM1',
      'CDM2': 'CM2',
      'RM': 'CM3',
    },
    '3-5-2': {
      'RB': 'CB3',
      'LB': 'CDM1',
      'RW': 'ST2',
      'LW': 'LM',
      'CM1': 'CAM',
      'CM2': 'CDM2',
      'CM3': 'RM',
    },
  };

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
                  _buildOptionButton(
                    index: 0,
                    text: 'Formation',
                    onTap: () => _onOptionSelected(0),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                  SizedBox(width: screenWidth * 0.04),
                  _buildOptionButton(
                    index: 1,
                    text: 'Players',
                    onTap: () => _onOptionSelected(1),
                    screenWidth: screenWidth,
                    screenHeight: screenHeight,
                  ),
                ],
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildFormationContainer(screenWidth, screenHeight),
                  _buildPlayersContainer(screenWidth, screenHeight),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required int index,
    required String text,
    required VoidCallback onTap,
    required double screenWidth,
    required double screenHeight,
  }) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(
            vertical: screenHeight * 0.01, horizontal: screenWidth * 0.03),
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: AppColors.borderColor,
          ),
          color: isSelected ? AppColors.blueColor : AppColors.buttonColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 6)
                ]
              : [],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            color: isSelected
                ? AppColors.textEnabledColor
                : AppColors.textEnabledColor,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildFormationContainer(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: screenWidth,
      height: screenHeight,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () {
                  setState(() {
                    selectedFormation = _previousFormation(selectedFormation);
                    _changeFormation(selectedFormation);
                  });
                },
              ),
              Expanded(
                child: Text(
                  selectedFormation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.textEnabledColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () {
                  setState(() {
                    selectedFormation = _nextFormation(selectedFormation);
                    _changeFormation(selectedFormation);
                  });
                },
              ),
            ],
          ),
          Expanded(
            flex: 3,
            child: Stack(
              children: _buildFieldPositions(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFieldPositions() {
    switch (selectedFormation) {
      case '4-4-2':
        return _buildFieldPositions442();
      case '4-3-3':
        return _buildFieldPositions433();
      case '3-5-2':
        return _buildFieldPositions352();
      default:
        return _buildFieldPositions442();
    }
  }

// TODO: Fix positions' placement
  List<Widget> _buildFieldPositions442() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * 0.5;

    Map<String, Offset> positions = {
      'ST1': Offset(width * 0.5 - 100, height * 0.1),
      'ST2': Offset(width * 0.5, height * 0.1),
      'LM': Offset(width * 0.1 - 15, height * 0.33),
      'CM1': Offset(width * 0.5 - 100, height * 0.37),
      'CM2': Offset(width * 0.5, height * 0.37),
      'RM': Offset(width * 0.9 - 75, height * 0.33),
      'LB': Offset(width * 0.1, height * 0.6),
      'CB1': Offset(width * 0.5 - 75, height * 0.65),
      'CB2': Offset(width * 0.5 + 15, height * 0.65),
      'RB': Offset(width * 0.9 - 60, height * 0.6),
      'GK': Offset(width * 0.4, height * 0.9),
    };

    return _buildFieldWidgets(positions);
  }

  List<Widget> _buildFieldPositions433() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * 0.5;

    Map<String, Offset> positions = {
      'ST1': Offset(width * 0.5 - 30, height * 0.1),
      'LW': Offset(width * 0.1, height * 0.15),
      'RW': Offset(width * 0.9 - 60, height * 0.15),
      'CM1': Offset(width * 0.3 - 30, height * 0.37),
      'CM2': Offset(width * 0.5 - 30, height * 0.37),
      'CM3': Offset(width * 0.7 - 30, height * 0.37),
      'LB': Offset(width * 0.1, height * 0.6),
      'CB1': Offset(width * 0.5 - 75, height * 0.65),
      'CB2': Offset(width * 0.5 + 15, height * 0.65),
      'RB': Offset(width * 0.9 - 60, height * 0.6),
      'GK': Offset(width * 0.5 - 30, height * 0.9),
    };

    return _buildFieldWidgets(positions);
  }

  List<Widget> _buildFieldPositions352() {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height * 0.5;

    Map<String, Offset> positions = {
      'ST1': Offset(width * 0.5 - 75, height * 0.1),
      'ST2': Offset(width * 0.5 + 15, height * 0.1),
      'CAM': Offset(width * 0.5 - 30, height * 0.33),
      'LM': Offset(width * 0.1, height * 0.35),
      'CDM1': Offset(width * 0.4 - 60, height * 0.38),
      'CDM2': Offset(width * 0.6, height * 0.38),
      'RM': Offset(width * 0.9 - 60, height * 0.35),
      'CB2': Offset(width * 0.5 - 30, height * 0.65),
      'CB1': Offset(width * 0.25 - 30, height * 0.65),
      'CB3': Offset(width * 0.75 - 30, height * 0.65),
      'GK': Offset(width * 0.5 - 30, height * 0.9),
    };

    return _buildFieldWidgets(positions);
  }

  List<Widget> _buildFieldWidgets(Map<String, Offset> positions) {
    List<Widget> widgets = [];
    positions.forEach((position, offset) {
      widgets.add(Positioned(
        left: offset.dx,
        top: offset.dy,
        width: 60,
        height: 100,
        child: DragTarget<Player>(
          builder: (context, candidateData, rejectedData) {
            return Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.hoverColor,
                    border: Border.all(
                      color: AppColors.borderColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            );
          },
        ),
      ));
    });

    return widgets;
  }

  String _previousFormation(String current) {
    List<String> keys = formations.keys.toList();
    int currentIndex = keys.indexOf(current);
    return keys[(currentIndex - 1 + keys.length) % keys.length];
  }

  String _nextFormation(String current) {
    List<String> keys = formations.keys.toList();
    int currentIndex = keys.indexOf(current);
    return keys[(currentIndex + 1) % keys.length];
  }

  void _changeFormation(String newFormation) {
    Map<String, Player?> newFieldPositions = {};
    Map<String, String> mapping = positionMapping[newFormation] ?? {};

    fieldPositions.forEach((key, value) {
      if (value != null) {
        if (mapping.containsKey(key)) {
          newFieldPositions[mapping[key]!] = value;
        } else {
          newFieldPositions[key] = value;
        }
      }
    });

    setState(() {
      fieldPositions = newFieldPositions;
    });
  }

  Widget _buildPlayersContainer(double screenWidth, double screenHeight) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppColors.hoverColor,
        border: Border.all(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(10.0),
      ),
      width: screenWidth,
      height: screenHeight,
    );
  }
}
