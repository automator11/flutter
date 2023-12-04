// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeseries_value_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TimeseriesValueModel _$TimeseriesValueModelFromJson(
        Map<String, dynamic> json) =>
    TimeseriesValueModel(
      ts: json['ts'] as int,
      value: json['value'],
    );

Map<String, dynamic> _$TimeseriesValueModelToJson(
        TimeseriesValueModel instance) =>
    <String, dynamic>{
      'ts': instance.ts,
      'value': instance.value,
    };
