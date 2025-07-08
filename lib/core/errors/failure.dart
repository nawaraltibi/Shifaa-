import 'package:dio/dio.dart';

abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);

  factory ServerFailure.fromDiorError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return const ServerFailure('Connection timeout with server');
      case DioExceptionType.sendTimeout:
        return const ServerFailure('Send timeout');
      case DioExceptionType.receiveTimeout:
        return const ServerFailure('Receive timeout');
      case DioExceptionType.badCertificate:
        return const ServerFailure('Bad certificate');
      case DioExceptionType.badResponse:
        return ServerFailure.fromResponse(
          e.response?.statusCode ?? 0,
          e.response?.data,
        );
      case DioExceptionType.cancel:
        return const ServerFailure('Request was cancelled');
      case DioExceptionType.connectionError:
        return const ServerFailure('No internet connection');
      case DioExceptionType.unknown:
        return const ServerFailure('Unexpected error occurred');
    }
  }

  factory ServerFailure.fromResponse(int statusCode, dynamic data) {
    const defaultMsg = 'An error occurred. Please try again.';

    if (statusCode == 200 || statusCode == 201) {
      return ServerFailure(data['message'] ?? 'Success');
    }

    if (data is Map && data['message'] is String) {
      final msg = data['message'] as String;

      if (statusCode == 422 && data['errors'] is Map<String, dynamic>) {
        final errors = data['errors'] as Map<String, dynamic>;
        final detailedErrors = errors.entries
            .map((e) => "${e.key}: ${(e.value as List).join(", ")}")
            .join("\n");
        return ServerFailure("$msg\n$detailedErrors");
      }

      if (statusCode == 400 ||
          statusCode == 401 ||
          statusCode == 403 ||
          statusCode == 404) {
        return ServerFailure(msg);
      }

      return ServerFailure(msg);
    }

    switch (statusCode) {
      case 400:
      case 401:
      case 403:
      case 404:
        return ServerFailure(data?['error']?['message'] ?? defaultMsg);
      case 422:
        if (data is Map && data['errors'] is Map<String, dynamic>) {
          final errors = data['errors'] as Map<String, dynamic>;
          final detailedErrors = errors.entries
              .map((e) => "${e.key}: ${(e.value as List).join(", ")}")
              .join("\n");
          return ServerFailure(detailedErrors);
        }
        return ServerFailure(data?['message'] ?? defaultMsg);
      case 500:
        return const ServerFailure('Server error. Try again later.');
      default:
        return const ServerFailure(defaultMsg);
    }
  }
}
