// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarms_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlarmsResponseModel _$AlarmsResponseModelFromJson(Map<String, dynamic> json) =>
    AlarmsResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => AlarmModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: json['hasNext'] as bool?,
      totalElements: json['totalElements'] as int?,
      totalPages: json['totalPages'] as int?,
    );

Map<String, dynamic> _$AlarmsResponseModelToJson(
        AlarmsResponseModel instance) =>
    <String, dynamic>{
      'hasNext': instance.hasNext,
      'totalPages': instance.totalPages,
      'totalElements': instance.totalElements,
      'data': instance.data,
    };
