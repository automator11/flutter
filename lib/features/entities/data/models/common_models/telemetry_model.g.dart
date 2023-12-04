// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'telemetry_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TelemetryModel _$TelemetryModelFromJson(Map<String, dynamic> json) =>
    TelemetryModel(
      lastUpdateTs: json['lastUpdateTs'] as int,
      key: json['key'] as String,
      value: json['value'],
    );

Map<String, dynamic> _$TelemetryModelToJson(TelemetryModel instance) =>
    <String, dynamic>{
      'lastUpdateTs': instance.lastUpdateTs,
      'key': instance.key,
      'value': instance.value,
    };
