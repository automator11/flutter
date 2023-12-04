import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'automation_model.g.dart';

@JsonSerializable()
class AutomationModel extends Equatable{
  final String type;
  final String name;

  const AutomationModel({required this.type, required this.name});

  @override
  List<Object?> get props => [type, name];

  factory AutomationModel.fromJson(Map<String, dynamic> json) =>
      _$AutomationModelFromJson(json);

  Map<String, dynamic> toJson() => _$AutomationModelToJson(this);
}