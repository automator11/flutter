part of '../../cubit/change_password_cubit/change_password_cubit.dart';

abstract class ChangePasswordState extends Equatable {
  const ChangePasswordState();
}

class ChangePasswordInitial extends ChangePasswordState {
  @override
  List<Object> get props => [];
}

class ChangePasswordLoading extends ChangePasswordState {
  @override
  List<Object?> get props => [];
}

class ChangePasswordSuccess extends ChangePasswordState {
  @override
  List<Object?> get props => [];
}

class ChangePasswordFailure extends ChangePasswordState {
  final String message;
  final bool isAuthenticated;

  const ChangePasswordFailure(
      {required this.message, this.isAuthenticated = true});

  @override
  List<Object?> get props => [message];
}
