import 'package:shared_preferences/shared_preferences.dart';

class YouthManager {
  static final YouthManager _instance = YouthManager._internal();

  factory YouthManager() {
    return _instance;
  }

  YouthManager._internal();

  static int _youthLevel = 1;
  static int _youthUpgradeCost = 100000;
  static int _youthPoints = 50;

  static int get youthLevel => _youthLevel;
  static set youthLevel(int value) {
    _youthLevel = value;
    _instance.saveYouthLevel();
  }

  static int get youthUpgradeCost => _youthUpgradeCost;
  static set youthUpgradeCost(int value) {
    _youthUpgradeCost = value;
    _instance.saveYouthUpgradeCost();
  }

  static int get youthPoints => _youthPoints;
  static set youthPoints(int value) {
    _youthPoints = value;
    _instance.saveYouthPoints();
  }

  Future<void> loadYouthLevel() async {
    final prefs = await SharedPreferences.getInstance();
    _youthLevel = prefs.getInt('youthLevel') ?? 1;
  }

  Future<void> saveYouthLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('youthLevel', _youthLevel);
  }

  Future<void> loadYouthUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    _youthUpgradeCost = prefs.getInt('youthUpgradeCost') ?? 100000;
  }

  Future<void> saveYouthUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('youthUpgradeCost', _youthUpgradeCost);
  }

  Future<void> loadYouthPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _youthPoints = prefs.getInt('youthPoints') ?? 50;
  }

  Future<void> saveYouthPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('youthPoints', _youthPoints);
  }

  Future<void> loadAllYouthData() async {
    await loadYouthLevel();
    await loadYouthUpgradeCost();
    await loadYouthPoints();
  }
}
