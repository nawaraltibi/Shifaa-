abstract class AuthRemoteDataSource {
  Future<void> sendOtp(String phoneNumber);
  Future<String> verifyOtp(String phoneNumber, String otp);
}
