import 'package:shifaa/core/api/api_consumer.dart';
import 'package:shifaa/core/api/end_ponits.dart';
import 'auth_remote_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiConsumer api;

  AuthRemoteDataSourceImpl(this.api);

  @override
  Future<void> sendOtp(String phoneNumber) async {
    await api.post(EndPoint.sendOtp, data: {"phone_number": phoneNumber});
  }

  @override
  Future<String> verifyOtp(String phoneNumber, String otp) async {
    final response = await api.post(
      EndPoint.verifyOtp,
      data: {"phone_number": phoneNumber, "otp": otp},
    );

    final token = response['data']['token'];
    print('VerifyOtp response: $response');

    return token;
  }
}
