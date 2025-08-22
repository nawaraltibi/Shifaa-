// device_cache_repo.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shifaa/features/chat/data/models/chat.dart';
import '../models/device_model.dart';

class DeviceCacheRepo {
  static String _userDevicesKey(int userId) => 'devices_by_user_$userId';

  /// ادمجي/حدّثي أجهزة مستخدم واحد
  static Future<void> upsertDevicesForUser(
    int userId,
    List<DeviceModel> devices,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _userDevicesKey(userId);
    final existing = prefs.getString(key);

    Map<String, String> map = existing != null
        ? Map<String, String>.from(jsonDecode(existing))
        : {};

    for (final d in devices) {
      map['${d.id}'] = d.publicKey;
    }
    await prefs.setString(key, jsonEncode(map));
  }

  /// استرجاع خريطة الأجهزة لمستخدم معيّن (deviceId -> publicKey)
  static Future<Map<int, String>> getDevicesForUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _userDevicesKey(userId);
    final str = prefs.getString(key);
    if (str == null) return {};
    final raw = Map<String, dynamic>.from(jsonDecode(str));
    return raw.map((k, v) => MapEntry(int.parse(k), v.toString()));
  }

  /// فحص وجود جهاز معيّن ضمن كاش مستخدم
  static Future<bool> hasDevice(int userId, int deviceId) async {
    final map = await getDevicesForUser(userId);
    return map.containsKey(deviceId);
  }

  /// تحديث الكاش مباشرة من ChatModel (يطال الطبيب والمريض)
  // device_cache_repo.dart
  static Future<void> updateFromChat(Chat chat) async {
    print("DEBUG: updating cache from chat...");

    // الخطوة 1: امسح الكاش القديم لضمان عدم وجود بيانات ملوثة
    if (chat.doctor != null) {
      await clearCacheForUser(chat.doctor!.id);
    }
    if (chat.patient != null) {
      await clearCacheForUser(chat.patient!.id);
    }

    // الخطوة 2: احفظ فقط الأجهزة التي تأتي من كائن `Chat` الكامل
    // هذا هو الكود الذي لديك بالفعل وهو صحيح
    if (chat.doctor != null) {
      await upsertDevicesForUser(chat.doctor!.id, chat.doctor!.devices);
      print("DEBUG: Doctor devices updated for user ${chat.doctor!.id}");
    }
    if (chat.patient != null) {
      await upsertDevicesForUser(chat.patient!.id, chat.patient!.devices);
      print("DEBUG: Patient devices updated for user ${chat.patient!.id}");
    }
  }

  /// الحصول على كل أجهزة طبيب + (اختياري) أجهزتي الأخرى لإرسال الرسالة
  static Future<Map<int, String>> getTargetsForSending({
    required int doctorUserId,
    bool includeMyOtherDevices = true,
    int? myUserId,
    int? myDeviceId, // لنتجنب تضمين نفس الجهاز مرتين
  }) async {
    final doctorDevices = await getDevicesForUser(doctorUserId);

    if (!includeMyOtherDevices || myUserId == null) {
      return doctorDevices;
    }

    final myDevices = await getDevicesForUser(myUserId);
    if (myDeviceId != null) {
      myDevices.remove(myDeviceId); // ما نضيف جهازي الحالي كـ target
    }

    // اندماج: أولوية لاشيء—مجرد دمج
    final merged = <int, String>{};
    merged.addAll(doctorDevices);
    merged.addAll(myDevices);
    return merged;
  }

  static Future<void> clearCacheForUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _userDevicesKey(userId);
    await prefs.remove(key);
    print("DEBUG: Cache cleared for user $userId");
  }
}
