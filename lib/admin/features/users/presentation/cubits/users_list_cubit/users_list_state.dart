part of 'users_list_cubit.dart';

abstract class UsersListState extends Equatable {
  const UsersListState();

  @override
  List<Object> get props => [];
}

class UsersListInitial extends UsersListState {}

class UsersListStateNewPage extends UsersListState {
  final String? error;
  final int? pageKey;
  final List<UserModel> items;
  final int? total;
  final int? pageSize;

  const UsersListStateNewPage(
      {required this.items,
      this.error,
      this.pageKey,
      this.pageSize,
      this.total});

  @override
  List<Object> get props => [items];
}
