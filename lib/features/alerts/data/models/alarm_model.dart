import 'package:json_annotation/json_annotation.dart';

import '../../../entities/data/models/models.dart';

part 'alarm_model.g.dart';

@JsonSerializable()
class AlarmModel extends EntityModel {
  final EntityId originator;
  final String severity;
  final String status;
  final int startTs;
  final int endTs;
  final int? ackTs;
  final int? clearTsl;
  final dynamic details;
  final String? originatorName;

  const AlarmModel({
    required super.createdTime,
    required super.id,
    required super.name,
    required super.type,
    required this.ackTs,
    required this.clearTsl,
    required this.details,
    required this.endTs,
    required this.originator,
    required this.originatorName,
    required this.severity,
    required this.startTs,
    required this.status,
  });

  factory AlarmModel.fromJson(Map<String, dynamic> json) =>
      _$AlarmModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AlarmModelToJson(this);

  @override
  String toString() {
    return name;
  }
}
