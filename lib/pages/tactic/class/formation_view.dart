import 'package:flutter/material.dart';
import 'package:pocket_eleven/design/colors.dart';
import 'package:pocket_eleven/models/player.dart';

class FormationView extends StatefulWidget {
  final String selectedFormation;
  final ValueChanged<String> onFormationChanged;

  const FormationView({
    super.key,
    required this.selectedFormation,
    required this.onFormationChanged,
  });

  @override
  State<FormationView> createState() => _FormationViewState();
}

class _FormationViewState extends State<FormationView> {
  late String _currentFormation;
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

  @override
  void initState() {
    super.initState();
    _currentFormation = widget.selectedFormation;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

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
                  _changeFormation(_previousFormation(_currentFormation));
                },
              ),
              Expanded(
                child: Text(
                  _currentFormation,
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
                  _changeFormation(_nextFormation(_currentFormation));
                },
              ),
            ],
          ),
          Expanded(
            flex: 3,
            child: Stack(
              children: _buildFieldPositions(screenWidth, screenHeight),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFieldPositions(double screenWidth, double screenHeight) {
    switch (_currentFormation) {
      case '4-4-2':
        return _buildFieldPositions442(screenWidth, screenHeight);
      case '4-3-3':
        return _buildFieldPositions433(screenWidth, screenHeight);
      case '3-5-2':
        return _buildFieldPositions352(screenWidth, screenHeight);
      default:
        return _buildFieldPositions442(screenWidth, screenHeight);
    }
  }

  // TODO: Fix position placement
  List<Widget> _buildFieldPositions442(
      double screenWidth, double screenHeight) {
    Map<String, Offset> positions = {
      'ST1': Offset(screenWidth * 0.38, screenHeight * 0.05),
      'ST2': Offset(screenWidth * 0.62, screenHeight * 0.05),
      'LM': Offset(screenWidth * 0.15, screenHeight * 0.2),
      'CM1': Offset(screenWidth * 0.38, screenHeight * 0.25),
      'CM2': Offset(screenWidth * 0.62, screenHeight * 0.25),
      'RM': Offset(screenWidth * 0.85, screenHeight * 0.2),
      'LB': Offset(screenWidth * 0.15, screenHeight * 0.38),
      'CB1': Offset(screenWidth * 0.38, screenHeight * 0.4),
      'CB2': Offset(screenWidth * 0.62, screenHeight * 0.4),
      'RB': Offset(screenWidth * 0.85, screenHeight * 0.38),
      'GK': Offset(screenWidth * 0.5, screenHeight * 0.5),
    };

    return _buildFieldWidgets(positions);
  }

  List<Widget> _buildFieldPositions433(
      double screenWidth, double screenHeight) {
    Map<String, Offset> positions = {
      'ST1': Offset(screenWidth * 0.5, screenHeight * 0.05),
      'LW': Offset(screenWidth * 0.2, screenHeight * 0.1),
      'RW': Offset(screenWidth * 0.8, screenHeight * 0.1),
      'CM1': Offset(screenWidth * 0.3, screenHeight * 0.22),
      'CM2': Offset(screenWidth * 0.5, screenHeight * 0.22),
      'CM3': Offset(screenWidth * 0.7, screenHeight * 0.22),
      'LB': Offset(screenWidth * 0.15, screenHeight * 0.38),
      'CB1': Offset(screenWidth * 0.38, screenHeight * 0.4),
      'CB2': Offset(screenWidth * 0.62, screenHeight * 0.4),
      'RB': Offset(screenWidth * 0.85, screenHeight * 0.38),
      'GK': Offset(screenWidth * 0.5, screenHeight * 0.5),
    };

    return _buildFieldWidgets(positions);
  }

  List<Widget> _buildFieldPositions352(
      double screenWidth, double screenHeight) {
    Map<String, Offset> positions = {
      'ST1': Offset(screenWidth * 0.38, screenHeight * 0.05),
      'ST2': Offset(screenWidth * 0.62, screenHeight * 0.05),
      'CAM': Offset(screenWidth * 0.5, screenHeight * 0.2),
      'LM': Offset(screenWidth * 0.15, screenHeight * 0.23),
      'CDM1': Offset(screenWidth * 0.33, screenHeight * 0.25),
      'CDM2': Offset(screenWidth * 0.67, screenHeight * 0.25),
      'RM': Offset(screenWidth * 0.85, screenHeight * 0.23),
      'CB2': Offset(screenWidth * 0.5, screenHeight * 0.4),
      'CB1': Offset(screenWidth * 0.25, screenHeight * 0.4),
      'CB3': Offset(screenWidth * 0.75, screenHeight * 0.4),
      'GK': Offset(screenWidth * 0.5, screenHeight * 0.5),
    };

    return _buildFieldWidgets(positions);
  }

  List<Widget> _buildFieldWidgets(Map<String, Offset> positions) {
    List<Widget> widgets = [];
    const double widgetSize = 60;
    positions.forEach((position, offset) {
      widgets.add(Positioned(
        left: offset.dx - (widgetSize / 2),
        top: offset.dy - (widgetSize / 2),
        child: DragTarget<Player>(
          builder: (context, candidateData, rejectedData) {
            return Container(
              width: widgetSize,
              height: widgetSize,
              decoration: BoxDecoration(
                color: AppColors.hoverColor,
                border: Border.all(
                  color: AppColors.borderColor,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
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
      _currentFormation = newFormation;
      fieldPositions = newFieldPositions;
      widget.onFormationChanged(newFormation);
    });
  }
}
