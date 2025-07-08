import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefsHelper {
  static const String _keyAlreadyLaunched = 'alreadyLaunched';
  static const String _keyToken = 'token';

  // Singleton
  SharedPrefsHelper._();
  static final SharedPrefsHelper instance = SharedPrefsHelper._();

  // ✅ تحقق إنو أول مرة تشغيل
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyLaunched = prefs.getBool(_keyAlreadyLaunched) ?? false;
    return !alreadyLaunched;
  }

  // ✅ تعليم أنه تم تشغيل التطبيق من قبل
  Future<void> setAlreadyLaunched() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyAlreadyLaunched, true);
  }

  // ✅ حفظ التوكين
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  // ✅ استرجاع التوكين
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // ✅ حذف التوكين (مثلاً عند تسجيل الخروج)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
  }
}
