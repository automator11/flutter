import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'automation_condition_model.g.dart';

@JsonSerializable()
class AutomationConditionModel extends Equatable {
  final String sensorId;
  final String sensorName;
  final String operator;
  final String variable;
  final String condition;
  final dynamic value;

  const AutomationConditionModel(
      {required this.sensorId,
      required this.sensorName,
      required this.operator,
      required this.variable,
      required this.condition,
      required this.value});

  @override
  List<Object?> get props =>
      [sensorId, sensorName, operator, variable, condition, value];

  factory AutomationConditionModel.fromJson(Map<String, dynamic> json) =>
      _$AutomationConditionModelFromJson(json);

  Map<String, dynamic> toJson() => _$AutomationConditionModelToJson(this);
}
