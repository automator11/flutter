// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'automation_condition_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AutomationConditionModel _$AutomationConditionModelFromJson(
        Map<String, dynamic> json) =>
    AutomationConditionModel(
      sensorId: json['sensorId'] as String,
      sensorName: json['sensorName'] as String,
      operator: json['operator'] as String,
      variable: json['variable'] as String,
      condition: json['condition'] as String,
      value: json['value'],
    );

Map<String, dynamic> _$AutomationConditionModelToJson(
        AutomationConditionModel instance) =>
    <String, dynamic>{
      'sensorId': instance.sensorId,
      'sensorName': instance.sensorName,
      'operator': instance.operator,
      'variable': instance.variable,
      'condition': instance.condition,
      'value': instance.value,
    };
