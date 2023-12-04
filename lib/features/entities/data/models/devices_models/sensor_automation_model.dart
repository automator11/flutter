import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'sensor_automation_model.g.dart';

@JsonSerializable()
class SensorAutomationModel extends AutomationModel {
  final String action;
  final List<AutomationConditionModel> conditions;

  const SensorAutomationModel({
    required super.type,
    required super.name,
    required this.action,
    required this.conditions,
  });

  @override
  List<Object?> get props => [type, name, action, conditions];

  factory SensorAutomationModel.fromJson(Map<String, dynamic> json) =>
      _$SensorAutomationModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'type': type,
        'name': name,
        'action': action,
        'conditions': conditions.map((e) => e.toJson()).toList(),
      };
}
