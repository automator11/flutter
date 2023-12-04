// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityGroupModel _$EntityGroupModelFromJson(Map<String, dynamic> json) =>
    EntityGroupModel(
      id: EntityId.fromJson(json['id'] as Map<String, dynamic>),
      createdTime: json['createdTime'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      ownerId: EntityId.fromJson(json['ownerId'] as Map<String, dynamic>),
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      configuration: json['configuration'] as Map<String, dynamic>?,
      externalId: json['externalId'] == null
          ? null
          : EntityId.fromJson(json['externalId'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EntityGroupModelToJson(EntityGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdTime': instance.createdTime,
      'type': instance.type,
      'name': instance.name,
      'ownerId': instance.ownerId,
      'additionalInfo': instance.additionalInfo,
      'configuration': instance.configuration,
      'externalId': instance.externalId,
    };
