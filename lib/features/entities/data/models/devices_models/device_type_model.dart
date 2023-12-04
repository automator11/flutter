import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../models.dart';

part 'device_type_model.g.dart';

@JsonSerializable()
class DeviceTypeModel extends Equatable {
  final EntityId tenantId;
  final String entityType;
  final String type;

  const DeviceTypeModel(
      {required this.tenantId, required this.entityType, required this.type});

  @override
  List<Object?> get props => [tenantId, entityType, type];

  factory DeviceTypeModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceTypeModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceTypeModelToJson(this);
}
