part of 'users_cubit.dart';

abstract class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersSuccess extends UsersState {
  final bool isDeleted;
  final UserModel? user;

  const UsersSuccess({this.isDeleted = false, this.user});

  @override
  List<Object> get props => [isDeleted];
}

class UsersFail extends UsersState {
  final String message;

  const UsersFail({required this.message});

  @override
  List<Object> get props => [message];
}

class UsersActivationLinkSuccess extends UsersState {
  final String link;

  const UsersActivationLinkSuccess({required this.link});

  @override
  List<Object> get props => [link];
}
