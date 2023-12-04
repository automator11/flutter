// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alert_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlertModel _$AlertModelFromJson(Map<String, dynamic> json) => AlertModel(
      name: json['name'] as String,
      level: json['level'] as String,
      variable: json['variable'] as String,
      condition: json['condition'] as String,
      value: (json['value'] as num).toDouble(),
    );

Map<String, dynamic> _$AlertModelToJson(AlertModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'level': instance.level,
      'variable': instance.variable,
      'condition': instance.condition,
      'value': instance.value,
    };
