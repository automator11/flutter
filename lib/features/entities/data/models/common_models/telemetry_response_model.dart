import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'telemetry_response_model.g.dart';

@JsonSerializable()
class TelemetryResponseModel {
  final List<TelemetryModel> data;

  TelemetryResponseModel(
      {required this.data});

  factory TelemetryResponseModel.fromJson(Map<String, dynamic> json) =>
      _$TelemetryResponseModelFromJson(json);
}