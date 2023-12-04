part of 'settings_cubit.dart';

class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsSuccess extends SettingsState {
  final String? message;

  const SettingsSuccess({this.message});
}

class SettingsFail extends SettingsState {
  final String message;

  const SettingsFail(this.message);

  @override
  List<Object> get props => [message];
}
