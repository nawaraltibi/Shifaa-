import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Set common headers if needed
    options.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      // 'Accept-Language': 'ar', // Optionally set dynamically from locale
    });

    // You can also log the request
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

    // Optional: log full response if available
    if (err.response != null) {
      print("Error Response Body: ${err.response?.data}");
    }

    super.onError(err, handler);
  }
}
