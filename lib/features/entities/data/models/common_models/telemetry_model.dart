import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'telemetry_model.g.dart';

@JsonSerializable()
class TelemetryModel extends Equatable{
  final int lastUpdateTs;
  final String key;
  final dynamic value;

  const TelemetryModel(
      {required this.lastUpdateTs, required this.key, required this.value});

  @override
  List<Object?> get props => [lastUpdateTs, key, value];

  factory TelemetryModel.fromJson(Map<String, dynamic> json) =>
      _$TelemetryModelFromJson(json);

  Map<String, dynamic> toJson() => _$TelemetryModelToJson(this);

}
