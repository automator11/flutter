import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'timeseries_value_model.g.dart';

@JsonSerializable()
class TimeseriesValueModel extends Equatable {
  final int ts;
  final dynamic value;

  const TimeseriesValueModel({required this.ts, required this.value});

  @override
  List<Object?> get props => [ts, value];

  factory TimeseriesValueModel.fromJson(Map<String, dynamic> json) =>
      _$TimeseriesValueModelFromJson(json);
}
