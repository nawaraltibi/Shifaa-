part of 'send_otp_cubit.dart';

@immutable
abstract class SendOtpState {}

class SendOtpInitial extends SendOtpState {}

class SendOtpLoading extends SendOtpState {}

class SendOtpSuccess extends SendOtpState {
  final String phoneNumber;
  SendOtpSuccess(this.phoneNumber);
}

class SendOtpError extends SendOtpState {
  final String message;

  SendOtpError(this.message);
}
