import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:shifaa/core/api/end_ponits.dart';
import 'package:shifaa/core/utils/shared_prefs_helper.dart';

class ApiInterceptor extends Interceptor {
  @override
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SharedPrefsHelper.instance.getToken();
    final locale = Intl.getCurrentLocale();

    // Define endpoints that do NOT require token
    final unauthenticatedEndpoints = [
      EndPoint.sendOtp,
      EndPoint.verifyOtp,
      EndPoint.register,
      EndPoint.verifyPassword,
    ];

    // Check if current request matches one of them
    final isUnauthenticated = unauthenticatedEndpoints.any(
      (unauth) => options.path.contains(unauth),
    );

    options.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Accept-Language': locale == 'ar' ? 'ar' : 'en',
      if (!isUnauthenticated && token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    });
    print("📛 Token Used: $token");

    print("➡️ API Request: ${options.method} ${options.uri}");
    print("Headers: ${options.headers}");
    print("Body: ${options.data}");

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      "✅ API Response: ${response.statusCode} ${response.requestOptions.uri}",
    );
    print("Response Body: ${response.data}");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print("❌ API Error: ${err.type} | ${err.message}");

    final response = err.response;
    if (response != null) {
      print("⛔ Status Code: ${response.statusCode}");
      print("⛔ Response Headers: ${response.headers}");

      // Try printing raw data even if it's HTML or string
      try {
        print("⛔ Response Body: ${response.data}");
      } catch (e) {
        print("⚠️ Failed to parse response body: $e");
      }

      // Optional: print response as string if it's not a map
      if (response.data is! Map && response.data is! List) {
        print("⛔ Raw Response Body as String: ${response.data.toString()}");
      }
    } else {
      print("❌ No response from server (might be a network issue).");
    }

    super.onError(err, handler);
  }
}
