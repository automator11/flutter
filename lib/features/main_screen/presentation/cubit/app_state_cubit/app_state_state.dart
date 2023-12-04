part of 'app_state_cubit.dart';

abstract class AppState extends Equatable {
  const AppState();

  @override
  List<Object> get props => [];
}

class AppInitial extends AppState {}
class AppStateChangingEstablishment extends AppState {}

class AppStateRestored extends AppState {
  final UserModel? user;

  const AppStateRestored({this.user});

  @override
  List<Object> get props => [user ?? false];
}

class AppStateUpdatedCurrentEstablishment extends AppState {
  final EntityModel establishment;

  const AppStateUpdatedCurrentEstablishment({required this.establishment});

  @override
  List<Object> get props => [establishment];
}

class AppStateAssetCreated extends AppState {
  final String type;

  const AppStateAssetCreated({required this.type});

  @override
  List<Object> get props => [type];
}

class AppStateDeviceClaimed extends AppState {}
