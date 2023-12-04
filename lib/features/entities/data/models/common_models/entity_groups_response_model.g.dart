// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entity_groups_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntityGroupsResponseModel _$EntityGroupsResponseModelFromJson(
        Map<String, dynamic> json) =>
    EntityGroupsResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => EntityGroupModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$EntityGroupsResponseModelToJson(
        EntityGroupsResponseModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
