// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entities_search_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EntitiesSearchResponseModel _$EntitiesSearchResponseModelFromJson(
        Map<String, dynamic> json) =>
    EntitiesSearchResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => EntitySearchModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: json['hasNext'] as bool?,
      totalElements: json['totalElements'] as int?,
      totalPages: json['totalPages'] as int?,
    );

Map<String, dynamic> _$EntitiesSearchResponseModelToJson(
        EntitiesSearchResponseModel instance) =>
    <String, dynamic>{
      'hasNext': instance.hasNext,
      'totalPages': instance.totalPages,
      'totalElements': instance.totalElements,
      'data': instance.data,
    };
