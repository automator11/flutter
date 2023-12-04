part of 'device_types_cubit.dart';

abstract class DeviceTypesState extends Equatable {
  const DeviceTypesState();

  @override
  List<Object> get props => [];
}

class DeviceTypesInitial extends DeviceTypesState {}

class DeviceTypesLoading extends DeviceTypesState {}

class DeviceTypesSuccess extends DeviceTypesState {
  final List<DeviceTypeModel> types;

  const DeviceTypesSuccess({required this.types});

  @override
  List<Object> get props => [types];
}

class DeviceTypesFail extends DeviceTypesState {
  final String message;

  const DeviceTypesFail({required this.message});

  @override
  List<Object> get props => [message];
}
