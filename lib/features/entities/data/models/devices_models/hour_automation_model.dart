import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'hour_automation_model.g.dart';

@JsonSerializable()
class HourAutomationModel extends AutomationModel {
  final int onDate;
  final int offDate;
  final int recurrence;
  final int endOfRecurrenceDate;

  const HourAutomationModel(
      {required super.type,
      required super.name,
      required this.onDate,
      required this.offDate,
      required this.recurrence,
      required this.endOfRecurrenceDate});

  @override
  List<Object?> get props => [type, name, onDate, offDate, recurrence, endOfRecurrenceDate];

  factory HourAutomationModel.fromJson(Map<String, dynamic> json) =>
      _$HourAutomationModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$HourAutomationModelToJson(this);
}
