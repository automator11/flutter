// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hour_automation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HourAutomationModel _$HourAutomationModelFromJson(Map<String, dynamic> json) =>
    HourAutomationModel(
      type: json['type'] as String,
      name: json['name'] as String,
      onDate: json['onDate'] as int,
      offDate: json['offDate'] as int,
      recurrence: json['recurrence'] as int,
      endOfRecurrenceDate: json['endOfRecurrenceDate'] as int,
    );

Map<String, dynamic> _$HourAutomationModelToJson(
        HourAutomationModel instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'onDate': instance.onDate,
      'offDate': instance.offDate,
      'recurrence': instance.recurrence,
      'endOfRecurrenceDate': instance.endOfRecurrenceDate,
    };
