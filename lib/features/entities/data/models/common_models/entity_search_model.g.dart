// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_search_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitySearchModel _$EntitySearchModelFromJson(Map<String, dynamic> json) =>
    EntitySearchModel(
      entityId: EntityId.fromJson(json['entityId'] as Map<String, dynamic>),
      aggLatest: json['aggLatest'] as Map<String, dynamic>,
      latest:
          EntitySearchValue.fromJson(json['latest'] as Map<String, dynamic>),
      readAttrs: json['readAttrs'] as bool,
      readTs: json['readTs'] as bool,
      timeseries: json['timeseries'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$EntitySearchModelToJson(EntitySearchModel instance) =>
    <String, dynamic>{
      'entityId': instance.entityId,
      'readAttrs': instance.readAttrs,
      'readTs': instance.readTs,
      'latest': EntitySearchValue.toJson(instance.latest),
      'timeseries': instance.timeseries,
      'aggLatest': instance.aggLatest,
    };
