// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alerts_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertsResponseModel _$AlertsResponseModelFromJson(Map<String, dynamic> json) =>
    AlertsResponseModel(
      alerts: (json['alerts'] as List<dynamic>?)
              ?.map((e) => AlertModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );

Map<String, dynamic> _$AlertsResponseModelToJson(
        AlertsResponseModel instance) =>
    <String, dynamic>{
      'alerts': instance.alerts,
    };
