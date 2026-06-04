import 'package:shared_preferences/shared_preferences.dart';

class Prefs {
  static late SharedPreferences _p;

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
  }

  static String get username => _p.getString('username') ?? '';
  static Future<void> setUsername(String v) => _p.setString('username', v);

  static int get wins => _p.getInt('wins') ?? 0;
  static int get losses => _p.getInt('losses') ?? 0;
  static Future<void> addWin() => _p.setInt('wins', wins + 1);
  static Future<void> addLoss() => _p.setInt('losses', losses + 1);
}
