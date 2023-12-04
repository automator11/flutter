// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'alarm_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AlarmModel _$AlarmModelFromJson(Map<String, dynamic> json) => AlarmModel(
      createdTime: json['createdTime'] as int,
      id: EntityId.fromJson(json['id'] as Map<String, dynamic>),
      name: json['name'] as String,
      type: json['type'] as String?,
      ackTs: json['ackTs'] as int?,
      clearTsl: json['clearTsl'] as int?,
      details: json['details'],
      endTs: json['endTs'] as int,
      originator: EntityId.fromJson(json['originator'] as Map<String, dynamic>),
      originatorName: json['originatorName'] as String?,
      severity: json['severity'] as String,
      startTs: json['startTs'] as int,
      status: json['status'] as String,
    );

Map<String, dynamic> _$AlarmModelToJson(AlarmModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdTime': instance.createdTime,
      'name': instance.name,
      'type': instance.type,
      'originator': instance.originator,
      'severity': instance.severity,
      'status': instance.status,
      'startTs': instance.startTs,
      'endTs': instance.endTs,
      'ackTs': instance.ackTs,
      'clearTsl': instance.clearTsl,
      'details': instance.details,
      'originatorName': instance.originatorName,
    };
