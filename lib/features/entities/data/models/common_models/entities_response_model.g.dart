// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entities_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitiesResponseModel _$EntitiesResponseModelFromJson(
        Map<String, dynamic> json) =>
    EntitiesResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => EntityModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: json['hasNext'] as bool?,
      totalElements: json['totalElements'] as int?,
      totalPages: json['totalPages'] as int?,
    );

Map<String, dynamic> _$EntitiesResponseModelToJson(
        EntitiesResponseModel instance) =>
    <String, dynamic>{
      'hasNext': instance.hasNext,
      'totalPages': instance.totalPages,
      'totalElements': instance.totalElements,
      'data': instance.data,
    };
