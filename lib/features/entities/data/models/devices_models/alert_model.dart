import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'alert_model.g.dart';

@JsonSerializable()
class AlertModel extends Equatable {
  final String name;
  final String level;
  final String variable;
  final String condition;
  final double value;

  const AlertModel(
      {required this.name,
      required this.level,
      required this.variable,
      required this.condition,
      required this.value});

  @override
  List<Object?> get props => [name, level, variable, condition, value];

  factory AlertModel.fromJson(Map<String, dynamic> json) =>
      _$AlertModelFromJson(json);

  Map<String, dynamic> toJson() => _$AlertModelToJson(this);
}
