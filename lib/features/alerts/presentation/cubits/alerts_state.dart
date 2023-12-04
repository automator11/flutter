part of 'alerts_cubit.dart';

abstract class AlertsState extends Equatable {
  const AlertsState();

  @override
  List<Object> get props => [];
}

class AlertsInitial extends AlertsState {}

class AlertsNewPage extends AlertsState {
  final String? error;
  final int? pageKey;
  final List<AlarmModel> items;

  const AlertsNewPage({required this.items, this.error, this.pageKey});

  @override
  List<Object> get props => [items];
}

class AlertsLoading extends AlertsState {}

class AlertsFail extends AlertsState {
  final String message;

  const AlertsFail({required this.message});

  @override
  List<Object> get props => [message];
}

class AlertsSuccess extends AlertsState {
  final List<AlarmModel> items;

  const AlertsSuccess({required this.items});

  @override
  List<Object> get props => [items];
}

class AlertsAck extends AlertsState {}

class AlertsDeleted extends AlertsState {}
