import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'alarms_response_model.g.dart';

@JsonSerializable()
class AlarmsResponseModel {
  final bool? hasNext;
  final int? totalPages;
  final int? totalElements;
  final List<AlarmModel> data;

  AlarmsResponseModel(
      {required this.data, this.hasNext, this.totalElements, this.totalPages});

  factory AlarmsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AlarmsResponseModelFromJson(json);
}