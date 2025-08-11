class EndPoint {
  static const String baseUrl = "https://shifaa-backend.onrender.com/api/";

  // ثابتة
  static const String sendOtp = "patient/send-otp";
  static const String verifyOtp = "patient/login";
  static const String register = "patient/register";
  static const String verifyPassword = "patient/verify-password";
  static const String appointment = "appointments";

  // ديناميكية - دكتور
  static String doctorDetails(String doctorId) => "doctors/$doctorId";
  static String doctorSchedules(String doctorId) =>
      "doctors/$doctorId/schedules";

  // 👇👇 روابط الشات
  static const String chat = "chat"; // POST لإنشاء محادثة جديدة

  static String getMessages(int chatId) => "chat/$chatId/messages"; // GET رسائل
  static String sendMessage(int chatId) =>
      "chat/$chatId/messages"; // POST إرسال رسالة
}

class ApiKey {
  static const String status = "status";
  static const String message = "message";
  static const String token = "token";
  static const String data = "data";
  static const String error = "error";
}
