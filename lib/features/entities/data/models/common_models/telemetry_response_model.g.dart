// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelemetryResponseModel _$TelemetryResponseModelFromJson(
        Map<String, dynamic> json) =>
    TelemetryResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => TelemetryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$TelemetryResponseModelToJson(
        TelemetryResponseModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
