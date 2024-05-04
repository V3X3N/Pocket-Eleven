import 'dart:math';

import 'package:random_name_generator/random_name_generator.dart';

Future<String> getRandomNationality(Random random) async {
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

String getSelectedFootballerName(String nationality) {
  var randomNames = RandomNames(_getZone(nationality));
  return randomNames.manName();
}

String getRandomPosition(Random random) {
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

Zone _getZone(String nationality) {
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

String getImagePath(int ovr) {
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
