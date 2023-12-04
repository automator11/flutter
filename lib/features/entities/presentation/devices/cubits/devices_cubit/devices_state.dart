part of 'devices_cubit.dart';

abstract class DevicesState extends Equatable {
  const DevicesState();

  @override
  List<Object> get props => [];
}

class DevicesInitial extends DevicesState {}

class DevicesLoading extends DevicesState {}

class DevicesSuccess extends DevicesState {}

class GetDeviceSuccess extends DevicesState {
  final EntityModel device;

  const GetDeviceSuccess({required this.device});

  @override
  List<Object> get props => [device];
}

class DevicesFail extends DevicesState {
  final String message;

  const DevicesFail({required this.message});

  @override
  List<Object> get props => [message];
}

class DevicesNewPage extends DevicesState {
  final String? error;
  final int? pageKey;
  final List<EntityModel> devices;
  final List<EntitySearchModel>? searchDevices;
  final int? total;
  final int? pageSize;

  const DevicesNewPage(
      {required this.devices,
      this.error,
      this.pageKey,
      this.searchDevices,
      this.pageSize,
      this.total});

  @override
  List<Object> get props => [devices, searchDevices ?? []];
}

class DeviceValidationSuccess extends DevicesState {
  final List<EntityModel> relatedDevices;

  const DeviceValidationSuccess({required this.relatedDevices});

  @override
  List<Object> get props => [relatedDevices];
}
