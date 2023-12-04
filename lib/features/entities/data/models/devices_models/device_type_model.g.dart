// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_type_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceTypeModel _$DeviceTypeModelFromJson(Map<String, dynamic> json) =>
    DeviceTypeModel(
      tenantId: EntityId.fromJson(json['tenantId'] as Map<String, dynamic>),
      entityType: json['entityType'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$DeviceTypeModelToJson(DeviceTypeModel instance) =>
    <String, dynamic>{
      'tenantId': instance.tenantId,
      'entityType': instance.entityType,
      'type': instance.type,
    };
