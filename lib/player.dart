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

  Player(
      {required this.name,
      required this.position,
      required this.ovr,
      required this.age,
      required this.nationality,
      required this.imagePath,
      required this.flagPath}) {
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
    };
  }

  String _calculateBadge() {
    if (ovr >= 201) {
      return 'purple';
    } else if (ovr >= 151 && ovr < 200) {
      return 'gold';
    } else if (ovr >= 101 && ovr < 150) {
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
    ovr ??= random.nextInt(230) + 21;
    age ??= random.nextInt(14) + 18;
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
    );
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
    return randomNames.manName();
  }

  static String _getRandomPosition(Random random) {
    List<String> positions = [
      'GK',
      'DL',
      'DC',
      'DR',
      'ML',
      'MC',
      'MR',
      'RW',
      'ST',
      'LW',
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
    if (ovr >= 201) {
      return 'assets/players/player_card_purple.png';
    } else if (ovr >= 151 && ovr < 200) {
      return 'assets/players/player_card_gold.png';
    } else if (ovr >= 101 && ovr < 150) {
      return 'assets/players/player_card_silver.png';
    } else {
      return 'assets/players/player_card_bronze.png';
    }
  }
}
