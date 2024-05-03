import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class Footballer {
  final String name;
  final int ovr;

  Footballer(this.name, this.ovr);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'ovr': ovr,
    };
  }
}

Future<List<Footballer>> generateRandomFootballers() async {
  final footballers = [
    'Cristiano',
    'Lionel',
    'Neymar',
    'Kylian',
    'Mohamed',
    'Robert',
    'Sergio',
    'Kevin',
    'Luka',
    'Karim',
    'Eden',
    'Sadio',
    'Virgil',
    'Paulo',
    'Harry',
    'Raheem',
    'N\'Golo',
    'Manuel',
    'Jan',
    'Thiago',
  ];

  final random = Random();
  List<Footballer> tempList = [];
  for (int i = 0; i < 6; i++) {
    int randomIndex = random.nextInt(footballers.length);
    String selectedFootballer = footballers[randomIndex];
    int randomOvr = random.nextInt(230) + 21; // OVR between 21 and 250
    Footballer newFootballer = Footballer(selectedFootballer, randomOvr);
    tempList.add(newFootballer);
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('selectedFootballers',
      jsonEncode(tempList.map((e) => e.toJson()).toList()));
  return tempList;
}
