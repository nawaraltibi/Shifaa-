import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:meta/meta.dart';
import 'package:shifaa/core/errors/failure.dart';
import 'package:shifaa/features/auth/domain/usecases/send_otp_usecase.dart';

part 'send_otp_state.dart';

class SendOtpCubit extends Cubit<SendOtpState> {
  final SendOtpUseCase sendOtpUseCase;

  SendOtpCubit(this.sendOtpUseCase) : super(SendOtpInitial());

  Future<void> sendOtp(String phoneNumber) async {
    emit(SendOtpLoading());

    final Either<Failure, void> result = await sendOtpUseCase(phoneNumber);

    result.fold(
      (failure) => emit(SendOtpError(failure.message)),
      (_) => emit(SendOtpSuccess()),
    );
  }
}
