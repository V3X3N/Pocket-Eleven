import 'dart:math';
import 'package:random_name_generator/random_name_generator.dart';

class Player {
  String id;

  final String name;
  final String position;
  final String nationality;
  final String flagPath;

  int ovr;
  int age;
  int matchesPlayed = 0;
  int goals = 0;
  int assists = 0;
  int yellowCards = 0;
  int redCards = 0;
  String imagePath;
  late String badge;
  late int value;
  late int salary;

  int param1;
  int param2;
  int param3;
  int param4;
  String param1Name;
  String param2Name;
  String param3Name;
  String param4Name;

  Player({
    this.id = '',
    required this.name,
    required this.position,
    required this.ovr,
    required this.age,
    required this.nationality,
    required this.imagePath,
    required this.flagPath,
    required this.value,
    required this.salary,
    required this.param1,
    required this.param2,
    required this.param3,
    required this.param4,
    required this.param1Name,
    required this.param2Name,
    required this.param3Name,
    required this.param4Name,
    this.matchesPlayed = 0,
    this.goals = 0,
    this.assists = 0,
    this.yellowCards = 0,
    this.redCards = 0,
  }) {
    badge = _calculateBadge();
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? '',
      name: json['name'],
      position: json['position'],
      ovr: json['ovr'],
      age: json['age'],
      nationality: json['nationality'],
      imagePath: json['imagePath'],
      flagPath: json['flagPath'],
      value: json['value'],
      salary: json['salary'],
      param1: json['param1'],
      param2: json['param2'],
      param3: json['param3'],
      param4: json['param4'],
      param1Name: json['param1Name'],
      param2Name: json['param2Name'],
      param3Name: json['param3Name'],
      param4Name: json['param4Name'],
      matchesPlayed: json['matchesPlayed'] ?? 0,
      goals: json['goals'] ?? 0,
      assists: json['assists'] ?? 0,
      yellowCards: json['yellowCards'] ?? 0,
      redCards: json['redCards'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'ovr': ovr,
      'age': age,
      'nationality': nationality,
      'imagePath': imagePath,
      'flagPath': flagPath,
      'value': value,
      'salary': salary,
      'param1': param1,
      'param2': param2,
      'param3': param3,
      'param4': param4,
      'param1Name': param1Name,
      'param2Name': param2Name,
      'param3Name': param3Name,
      'param4Name': param4Name,
      'matchesPlayed': matchesPlayed,
      'goals': goals,
      'assists': assists,
      'yellowCards': yellowCards,
      'redCards': redCards,
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

    // Generate the parameters based on the position with a limit of 99
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

    // Calculate value and salary based on the new OVR and age
    int value = ((ovr * 450000 / age) / 10000).round() * 10000;
    int salary = ((age * ovr) / 10).round() * 10;

    return Player(
      id: '',
      name: name,
      position: position,
      ovr: ovr,
      age: age,
      nationality: nationality,
      imagePath: imagePath,
      flagPath: flagPath,
      value: value,
      salary: salary,
      param1: param1,
      param2: param2,
      param3: param3,
      param4: param4,
      param1Name: paramNames['param1Name']!,
      param2Name: paramNames['param2Name']!,
      param3Name: paramNames['param3Name']!,
      param4Name: paramNames['param4Name']!,
      matchesPlayed: 0,
      goals: 0,
      assists: 0,
      yellowCards: 0,
      redCards: 0,
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
    // Generate a value from 30 to 99 with a quadratic distribution
    int baseValue = random.nextInt(70) + 30; // Generate a value from 30 to 99
    return min((baseValue * sqrt(random.nextDouble())).round(), 99);
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
