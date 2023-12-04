import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'alerts_response_model.g.dart';

@JsonSerializable()
class AlertsResponseModel extends Equatable {
  @JsonKey(defaultValue: [])
  final List<AlertModel> alerts;

  const AlertsResponseModel({required this.alerts});

  @override
  List<Object?> get props => [alerts];

  factory AlertsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AlertsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => <String, dynamic>{
        'alerts': alerts.map((e) => e.toJson()).toList(),
      };
}
