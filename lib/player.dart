import 'dart:math';

import 'package:random_name_generator/random_name_generator.dart';

class Player {
  final String name;
  final String position;
  final int ovr;
  final int age;
  final String nationality;
  final String imagePath;
  final String flagPath;
  late final String badge;

  final int param1;
  final int param2;
  final int param3;
  final int param4;
  final String param1Name;
  final String param2Name;
  final String param3Name;
  final String param4Name;

  Player({
    required this.name,
    required this.position,
    required this.ovr,
    required this.age,
    required this.nationality,
    required this.imagePath,
    required this.flagPath,
    required this.param1,
    required this.param2,
    required this.param3,
    required this.param4,
    required this.param1Name,
    required this.param2Name,
    required this.param3Name,
    required this.param4Name,
  }) {
    badge = _calculateBadge();
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      position: json['position'],
      ovr: json['ovr'],
      age: json['age'],
      nationality: json['nationality'],
      imagePath: json['imagePath'],
      flagPath: json['flagPath'],
      param1: json['param1'],
      param2: json['param2'],
      param3: json['param3'],
      param4: json['param4'],
      param1Name: json['param1Name'],
      param2Name: json['param2Name'],
      param3Name: json['param3Name'],
      param4Name: json['param4Name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'position': position,
      'ovr': ovr,
      'age': age,
      'nationality': nationality,
      'imagePath': imagePath,
      'flagPath': flagPath,
      'param1': param1,
      'param2': param2,
      'param3': param3,
      'param4': param4,
      'param1Name': param1Name,
      'param2Name': param2Name,
      'param3Name': param3Name,
      'param4Name': param4Name,
    };
  }

  String _calculateBadge() {
    if (ovr >= 80) {
      return 'purple';
    } else if (ovr >= 60 && ovr < 79) {
      return 'gold';
    } else if (ovr >= 40 && ovr < 59) {
      return 'silver';
    } else {
      return 'bronze';
    }
  }

  static Future<Player> generateRandomFootballer({
    String? nationality,
    String? position,
    int? ovr,
    int? age,
  }) async {
    final random = Random();
    nationality ??= await _getRandomNationality(random);
    position ??= _getRandomPosition(random);
    age ??= random.nextInt(14) + 18;

    // Generate the parameters based on the position
    List<int> parameters = _generateParameters(random);
    int param1 = parameters[0];
    int param2 = parameters[1];
    int param3 = parameters[2];
    int param4 = parameters[3];

    // Set parameter names based on the position
    Map<String, String> paramNames = _getParameterNames(position);

    // Calculate OVR as the average of the four parameters
    ovr = ((param1 + param2 + param3 + param4) / 4).round();

    String name = _getSelectedFootballerName(nationality);
    String imagePath = _getImagePath(ovr);
    String flagPath = 'assets/flags/flag_$nationality.png';

    return Player(
      name: name,
      position: position,
      ovr: ovr,
      age: age,
      nationality: nationality,
      imagePath: imagePath,
      flagPath: flagPath,
      param1: param1,
      param2: param2,
      param3: param3,
      param4: param4,
      param1Name: paramNames['param1Name']!,
      param2Name: paramNames['param2Name']!,
      param3Name: paramNames['param3Name']!,
      param4Name: paramNames['param4Name']!,
    );
  }

  static Map<String, String> _getParameterNames(String position) {
    switch (position) {
      case 'GK':
        return {
          'param1Name': 'Catching',
          'param2Name': 'Reflex',
          'param3Name': 'Positioning',
          'param4Name': 'Throwing',
        };
      case 'LB':
      case 'CB':
      case 'RB':
        return {
          'param1Name': 'Blocking',
          'param2Name': 'Tackling',
          'param3Name': 'Positioning',
          'param4Name': 'Passing',
        };
      case 'LM':
      case 'CDM':
      case 'CM':
      case 'CAM':
      case 'RM':
        return {
          'param1Name': 'Passing',
          'param2Name': 'Movement',
          'param3Name': 'Dribbling',
          'param4Name': 'Tackling',
        };
      case 'LW':
      case 'ST':
      case 'RW':
        return {
          'param1Name': 'Shooting',
          'param2Name': 'Finishing',
          'param3Name': 'Dribbling',
          'param4Name': 'Movement',
        };
      default:
        throw Exception('Unknown position: $position');
    }
  }

  static List<int> _generateParameters(Random random) {
    return List.generate(4, (_) => _generateParameter(random));
  }

  static int _generateParameter(Random random) {
    // Generate a value from 30 to 80 with a quadratic distribution
    int baseValue = random.nextInt(51) + 30;
    return (baseValue * sqrt(random.nextDouble())).round();
  }

  static Future<String> _getRandomNationality(Random random) async {
    List<String> nationalities = [
      'AUT',
      'BEL',
      'BRA',
      'ENG',
      'FRA',
      'GER',
      'ITA',
      'JPN',
      'POL',
      'ESP',
      'USA',
      'TUR'
    ];

    return nationalities[random.nextInt(nationalities.length)];
  }

  static String _getSelectedFootballerName(String nationality) {
    var randomNames = RandomNames(_getZone(nationality));
    return randomNames.manFullName();
  }

  static String _getRandomPosition(Random random) {
    List<String> positions = [
      'GK',
      'LB',
      'CB',
      'RB',
      'CDM',
      'LM',
      'CM',
      'RM',
      'CAM',
      'LW',
      'RW',
      'ST',
    ];
    return positions[random.nextInt(positions.length)];
  }

  static Zone _getZone(String nationality) {
    switch (nationality) {
      case 'AUT':
        return Zone.austria;
      case 'BEL':
        return Zone.belgium;
      case 'BRA':
        return Zone.brazil;
      case 'ENG':
        return Zone.uk;
      case 'ESP':
        return Zone.spain;
      case 'FRA':
        return Zone.france;
      case 'GER':
        return Zone.germany;
      case 'ITA':
        return Zone.italy;
      case 'JPN':
        return Zone.japan;
      case 'POL':
        return Zone.poland;
      case 'TUR':
        return Zone.turkey;
      default:
        return Zone.us;
    }
  }

  static String _getImagePath(int ovr) {
    if (ovr >= 80) {
      return 'assets/players/player_card_purple.png';
    } else if (ovr >= 60 && ovr < 79) {
      return 'assets/players/player_card_gold.png';
    } else if (ovr >= 40 && ovr < 59) {
      return 'assets/players/player_card_silver.png';
    } else {
      return 'assets/players/player_card_bronze.png';
    }
  }
}
