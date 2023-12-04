// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityModel _$EntityModelFromJson(Map<String, dynamic> json) => EntityModel(
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      deviceData: json['deviceData'] as Map<String, dynamic>?,
      assetProfileId: json['assetProfileId'] == null
          ? null
          : EntityId.fromJson(json['assetProfileId'] as Map<String, dynamic>),
      deviceProfileId: json['deviceProfileId'] == null
          ? null
          : EntityId.fromJson(json['deviceProfileId'] as Map<String, dynamic>),
      createdTime: json['createdTime'] as int,
      customerId: json['customerId'] == null
          ? null
          : EntityId.fromJson(json['customerId'] as Map<String, dynamic>),
      id: EntityId.fromJson(json['id'] as Map<String, dynamic>),
      label: json['label'] as String?,
      name: json['name'] as String,
      ownerId: json['ownerId'] == null
          ? null
          : EntityId.fromJson(json['ownerId'] as Map<String, dynamic>),
      tenantId: json['tenantId'] == null
          ? null
          : EntityId.fromJson(json['tenantId'] as Map<String, dynamic>),
      type: json['type'] as String?,
      latestValues: (json['latestValues'] as List<dynamic>?)
          ?.map((e) => TelemetryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EntityModelToJson(EntityModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdTime': instance.createdTime,
      'tenantId': instance.tenantId,
      'customerId': instance.customerId,
      'name': instance.name,
      'type': instance.type,
      'label': instance.label,
      'assetProfileId': instance.assetProfileId,
      'deviceProfileId': instance.deviceProfileId,
      'additionalInfo': instance.additionalInfo,
      'latestValues': instance.latestValues,
      'deviceData': instance.deviceData,
      'ownerId': instance.ownerId,
    };
