import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _keyAlreadyLaunched = 'alreadyLaunched';

  // منع إنشاء نسخة خارجية (Singleton)
  SharedPrefsHelper._();

  static final SharedPrefsHelper instance = SharedPrefsHelper._();

  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyLaunched = prefs.getBool(_keyAlreadyLaunched) ?? false;
    return !alreadyLaunched;
  }

  Future<void> setAlreadyLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlreadyLaunched, true);
  }
}
