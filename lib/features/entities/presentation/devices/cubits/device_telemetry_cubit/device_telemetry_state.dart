part of 'device_telemetry_cubit.dart';

abstract class DeviceTelemetryState extends Equatable {
  const DeviceTelemetryState();

  @override
  List<Object> get props => [];
}

class DeviceTelemetryInitial extends DeviceTelemetryState {}

class DeviceTelemetryRefresh extends DeviceTelemetryState {}

class DeviceTelemetryLoading extends DeviceTelemetryState {}

class DeviceTelemetrySuccess extends DeviceTelemetryState {
  final Map<String, dynamic> telemetry;

  const DeviceTelemetrySuccess({required this.telemetry});

  @override
  List<Object> get props => [telemetry];
}

class DeviceTelemetryFail extends DeviceTelemetryState {
  final String message;

  const DeviceTelemetryFail({required this.message});

  @override
  List<Object> get props => [message];
}
