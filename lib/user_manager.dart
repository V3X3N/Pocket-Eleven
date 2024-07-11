import 'package:shared_preferences/shared_preferences.dart';

class UserManager {
  static const String _moneyKey = 'money';
  double _money = 50000.0; // Zmieniona wartość początkowa

  UserManager._privateConstructor();
  static final UserManager _instance = UserManager._privateConstructor();
  factory UserManager() {
    return _instance;
  }

  double get money => _money;

  Future<void> loadMoney() async {
    final prefs = await SharedPreferences.getInstance();
    _money =
        prefs.getDouble(_moneyKey) ?? 50000.0; // Zmieniona wartość początkowa
  }

  Future<void> saveMoney() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_moneyKey, _money);
  }

  void addMoney(double amount) {
    _money += amount;
    saveMoney();
  }

  void subtractMoney(double amount) {
    _money -= amount;
    saveMoney();
  }
}
