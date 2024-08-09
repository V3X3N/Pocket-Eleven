import 'package:shared_preferences/shared_preferences.dart';

class ScoutingManager {
  static final ScoutingManager _instance = ScoutingManager._internal();

  factory ScoutingManager() {
    return _instance;
  }

  ScoutingManager._internal();

  static int _europeScoutingLevel = 1;
  static int _europeScoutingUpgradeCost = 200000;

  static int _asiaScoutingLevel = 1;
  static int _asiaScoutingUpgradeCost = 200000;

  static int _americaScoutingLevel = 1;
  static int _americaScoutingUpgradeCost = 200000;

  static int get europeScoutingLevel => _europeScoutingLevel;
  static set europeScoutingLevel(int value) {
    _europeScoutingLevel = value;
    _instance.saveEuropeScoutingLevel();
  }

  static int get europeScoutingUpgradeCost => _europeScoutingUpgradeCost;
  static set europeScoutingUpgradeCost(int value) {
    _europeScoutingUpgradeCost = value;
    _instance.saveEuropeScoutingUpgradeCost();
  }

  static int get asiaScoutingLevel => _asiaScoutingLevel;
  static set asiaScoutingLevel(int value) {
    _asiaScoutingLevel = value;
    _instance.saveAsiaScoutingLevel();
  }

  static int get asiaScoutingUpgradeCost => _asiaScoutingUpgradeCost;
  static set asiaScoutingUpgradeCost(int value) {
    _asiaScoutingUpgradeCost = value;
    _instance.saveAsiaScoutingUpgradeCost();
  }

  static int get americaScoutingLevel => _americaScoutingLevel;
  static set americaScoutingLevel(int value) {
    _americaScoutingLevel = value;
    _instance.saveAmericaScoutingLevel();
  }

  static int get americaScoutingUpgradeCost => _americaScoutingUpgradeCost;
  static set americaScoutingUpgradeCost(int value) {
    _americaScoutingUpgradeCost = value;
    _instance.saveAmericaScoutingUpgradeCost();
  }

  Future<void> loadEuropeScoutingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    _europeScoutingLevel = prefs.getInt('europeScoutingLevel') ?? 1;
  }

  Future<void> saveEuropeScoutingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('europeScoutingLevel', _europeScoutingLevel);
  }

  Future<void> loadEuropeScoutingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    _europeScoutingUpgradeCost =
        prefs.getInt('europeScoutingUpgradeCost') ?? 200000;
  }

  Future<void> saveEuropeScoutingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('europeScoutingUpgradeCost', _europeScoutingUpgradeCost);
  }

  Future<void> loadAsiaScoutingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    _asiaScoutingLevel = prefs.getInt('asiaScoutingLevel') ?? 1;
  }

  Future<void> saveAsiaScoutingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('asiaScoutingLevel', _asiaScoutingLevel);
  }

  Future<void> loadAsiaScoutingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    _asiaScoutingUpgradeCost =
        prefs.getInt('asiaScoutingUpgradeCost') ?? 200000;
  }

  Future<void> saveAsiaScoutingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('asiaScoutingUpgradeCost', _asiaScoutingUpgradeCost);
  }

  Future<void> loadAmericaScoutingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    _americaScoutingLevel = prefs.getInt('americaScoutingLevel') ?? 1;
  }

  Future<void> saveAmericaScoutingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('americaScoutingLevel', _americaScoutingLevel);
  }

  Future<void> loadAmericaScoutingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    _americaScoutingUpgradeCost =
        prefs.getInt('americaScoutingUpgradeCost') ?? 200000;
  }

  Future<void> saveAmericaScoutingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'americaScoutingUpgradeCost', _americaScoutingUpgradeCost);
  }

  Future<void> loadAllScoutingData() async {
    await loadEuropeScoutingLevel();
    await loadEuropeScoutingUpgradeCost();
    await loadAsiaScoutingLevel();
    await loadAsiaScoutingUpgradeCost();
    await loadAmericaScoutingLevel();
    await loadAmericaScoutingUpgradeCost();
  }
}
