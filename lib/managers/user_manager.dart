import 'package:shared_preferences/shared_preferences.dart';
import 'training_manager.dart';
import 'youth_manager.dart';
import 'stadium_manager.dart';
import 'medical_manager.dart';
import 'scouting_manager.dart';

class UserManager {
  static final UserManager _instance = UserManager._internal();

  factory UserManager() {
    return _instance;
  }

  UserManager._internal();

  static double _money = 500000.0;

  static double get money => _money;
  static set money(double value) {
    _money = value;
    _instance.saveMoney();
  }

  Future<void> loadMoney() async {
    final prefs = await SharedPreferences.getInstance();
    _money = prefs.getDouble('money') ?? 500000.0;
  }

  Future<void> saveMoney() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('money', _money);
  }

  Future<void> loadAllUserData() async {
    await loadMoney();
    await TrainingManager().loadAllTrainingData();
    await YouthManager().loadAllYouthData();
    await StadiumManager().loadAllStadiumData();
    await MedicalManager().loadAllMedicalData();
    await ScoutingManager().loadAllScoutingData();
  }
}
