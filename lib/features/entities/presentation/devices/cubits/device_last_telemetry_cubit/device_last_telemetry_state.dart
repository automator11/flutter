part of 'device_last_telemetry_cubit.dart';

abstract class DeviceLastTelemetryState extends Equatable {
  const DeviceLastTelemetryState();

  @override
  List<Object> get props => [];
}

class DeviceLastTelemetryInitial extends DeviceLastTelemetryState {}

class DeviceLastTelemetryRefresh extends DeviceLastTelemetryState {}

class DeviceLastTelemetryLoading extends DeviceLastTelemetryState {}

class DeviceLastTelemetrySuccess extends DeviceLastTelemetryState {
  final Map<String, dynamic> telemetry;
  final List<dynamic> attributes;

  const DeviceLastTelemetrySuccess(
      {required this.telemetry, required this.attributes});

  @override
  List<Object> get props => [telemetry, attributes];
}

class DeviceLastTelemetryFail extends DeviceLastTelemetryState {
  final String message;

  const DeviceLastTelemetryFail({required this.message});

  @override
  List<Object> get props => [message];
}

class DeviceUpdateAttributesSuccess extends DeviceLastTelemetryState {}
