import 'package:shared_preferences/shared_preferences.dart';

class ScoutingManager {
  static final ScoutingManager _instance = ScoutingManager._internal();

  factory ScoutingManager() {
    return _instance;
  }

  ScoutingManager._internal();

  static int _scoutingLevel = 1;
  static int _scoutingUpgradeCost = 400000;

  static int get scoutingLevel => _scoutingLevel;
  static set scoutingLevel(int value) {
    _scoutingLevel = value;
    _instance.saveScoutingLevel();
  }

  static int get scoutingUpgradeCost => _scoutingUpgradeCost;
  static set scoutingUpgradeCost(int value) {
    _scoutingUpgradeCost = value;
    _instance.saveScoutingUpgradeCost();
  }

  Future<void> loadScoutingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    _scoutingLevel = prefs.getInt('scoutingLevel') ?? 1;
  }

  Future<void> saveScoutingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('scoutingLevel', _scoutingLevel);
  }

  Future<void> loadScoutingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    _scoutingUpgradeCost = prefs.getInt('scoutingUpgradeCost') ?? 200000;
  }

  Future<void> saveScoutingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('scoutingUpgradeCost', _scoutingUpgradeCost);
  }

  Future<void> loadAllScoutingData() async {
    await loadScoutingLevel();
    await loadScoutingUpgradeCost();
  }
}
