import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shifaa/core/functions/setup_service_locator.dart';
import 'package:shifaa/features/auth/domain/usecases/send_otp_usecase.dart';
import 'package:shifaa/features/auth/presentation/cubits/send_otp_cubit/send_otp_cubit.dart';
import 'package:shifaa/features/auth/presentation/widgets/login_view_body.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});
  static const routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      resizeToAvoidBottomInset: false,
      body: LoginViewBlocProvider(),
    );
  }
}

class LoginViewBlocProvider extends StatelessWidget {
  const LoginViewBlocProvider({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SendOtpCubit(getIt<SendOtpUseCase>()),
      child: const LoginViewBody(),
    );
  }
}
