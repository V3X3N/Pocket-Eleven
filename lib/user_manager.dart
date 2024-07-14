import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  // Singleton instance
  static final UserManager _instance = UserManager._internal();

  // Factory constructor
  factory UserManager() {
    return _instance;
  }

  // Private constructor
  UserManager._internal();

  // Private properties
  static double _money = 500000.0;
  static int _trainingPoints = 50;
  static int _medicalPoints = 50;
  static int _youthPoints = 50;

  // Stadium
  static int stadiumLevel = 1;
  static int stadiumUpgradeCost = 100000;

  // Training
  static int trainingLevel = 1;
  static int trainingUpgradeCost = 100000;

  // Medical
  static int medicalLevel = 1;
  static int medicalUpgradeCost = 100000;

  // Youth
  static int youthLevel = 1;
  static int youthUpgradeCost = 100000;

  // Europe Scouting
  static int europeScoutingLevel = 1;
  static int europeScoutingUpgradeCost = 200000;

  // Static getters and setters to access the properties
  static double get money => _money;
  static set money(double value) {
    _money = value;
    _instance.saveMoney();
  }

  static int get trainingPoints => _trainingPoints;
  static set trainingPoints(int value) {
    _trainingPoints = value;
    _instance.saveTrainingPoints();
  }

  static int get medicalPoints => _medicalPoints;
  static set medicalPoints(int value) {
    _medicalPoints = value;
    _instance.saveMedicalPoints();
  }

  static int get youthPoints => _youthPoints;
  static set youthPoints(int value) {
    _youthPoints = value;
    _instance.saveYouthPoints();
  }

  // Nowe metody do ładowania i zapisywania poziomu stadionu i kosztu
  Future<void> loadStadiumLevel() async {
    final prefs = await SharedPreferences.getInstance();
    stadiumLevel = prefs.getInt('stadiumLevel') ?? 1;
  }

  Future<void> saveStadiumLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stadiumLevel', stadiumLevel);
  }

  Future<void> loadStadiumUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    stadiumUpgradeCost = prefs.getInt('stadiumUpgradeCost') ?? 100000;
  }

  Future<void> saveStadiumUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('stadiumUpgradeCost', stadiumUpgradeCost);
  }

  // Nowe metody do ładowania i zapisywania poziomu treningu i kosztu
  Future<void> loadTrainingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    trainingLevel = prefs.getInt('trainingLevel') ?? 1;
  }

  Future<void> saveTrainingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trainingLevel', trainingLevel);
  }

  Future<void> loadTrainingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    trainingUpgradeCost = prefs.getInt('trainingUpgradeCost') ?? 100000;
  }

  Future<void> saveTrainingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trainingUpgradeCost', trainingUpgradeCost);
  }

  // Nowe metody do ładowania i zapisywania poziomu medical i kosztu
  Future<void> loadMedicalLevel() async {
    final prefs = await SharedPreferences.getInstance();
    medicalLevel = prefs.getInt('medicalLevel') ?? 1;
  }

  Future<void> saveMedicalLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('medicalLevel', medicalLevel);
  }

  Future<void> loadMedicalUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    medicalUpgradeCost = prefs.getInt('medicalUpgradeCost') ?? 100000;
  }

  Future<void> saveMedicalUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('medicalUpgradeCost', medicalUpgradeCost);
  }

  // Nowe metody do ładowania i zapisywania poziomu youth i kosztu
  Future<void> loadYouthLevel() async {
    final prefs = await SharedPreferences.getInstance();
    youthLevel = prefs.getInt('youthLevel') ?? 1;
  }

  Future<void> saveYouthLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('youthLevel', youthLevel);
  }

  Future<void> loadYouthUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    youthUpgradeCost = prefs.getInt('youthUpgradeCost') ?? 100000;
  }

  Future<void> saveYouthUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('youthUpgradeCost', youthUpgradeCost);
  }

  // Load and save methods
  Future<void> loadMoney() async {
    final prefs = await SharedPreferences.getInstance();
    _money = prefs.getDouble('money') ?? 500000.0;
  }

  Future<void> saveMoney() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('money', _money);
  }

  Future<void> loadTrainingPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _trainingPoints = prefs.getInt('trainingPoints') ?? 50;
  }

  Future<void> saveTrainingPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('trainingPoints', _trainingPoints);
  }

  Future<void> loadMedicalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _medicalPoints = prefs.getInt('medicalPoints') ?? 50;
  }

  Future<void> saveMedicalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('medicalPoints', _medicalPoints);
  }

  Future<void> loadYouthPoints() async {
    final prefs = await SharedPreferences.getInstance();
    _youthPoints = prefs.getInt('youthPoints') ?? 50;
  }

  Future<void> saveYouthPoints() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('youthPoints', _youthPoints);
  }

  // Nowe metody do ładowania i zapisywania poziomu scoutingu europy i kosztu
  Future<void> loadEuropeScoutingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    europeScoutingLevel = prefs.getInt('europeScoutingLevel') ?? 1;
  }

  Future<void> saveEuropeScoutingLevel() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('europeScoutingLevel', europeScoutingLevel);
  }

  Future<void> loadEuropeScoutingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    europeScoutingUpgradeCost =
        prefs.getInt('europeScoutingUpgradeCost') ?? 200000;
  }

  Future<void> saveEuropeScoutingUpgradeCost() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('europeScoutingUpgradeCost', europeScoutingUpgradeCost);
  }
}
