part of 'password_cubit.dart';

abstract class PasswordState {
  const PasswordState();

  @override
  List<Object?> get props => [];
}

class PasswordInitial extends PasswordState {}

class PasswordLoading extends PasswordState {}

class PasswordSuccess extends PasswordState {
  final UserAuthModel user;

  const PasswordSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class PasswordFailure extends PasswordState {
  final String message;

  const PasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}
