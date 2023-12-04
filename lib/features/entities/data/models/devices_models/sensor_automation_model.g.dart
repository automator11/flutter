// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sensor_automation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SensorAutomationModel _$SensorAutomationModelFromJson(
        Map<String, dynamic> json) =>
    SensorAutomationModel(
      type: json['type'] as String,
      name: json['name'] as String,
      action: json['action'] as String,
      conditions: (json['conditions'] as List<dynamic>)
          .map((e) =>
              AutomationConditionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$SensorAutomationModelToJson(
        SensorAutomationModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'action': instance.action,
      'conditions': instance.conditions,
    };
