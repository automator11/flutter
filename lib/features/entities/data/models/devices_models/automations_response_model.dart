import 'package:equatable/equatable.dart';

import 'models.dart';

class AutomationsResponseModel extends Equatable {
  final List<AutomationModel> automations;

  const AutomationsResponseModel({required this.automations});

  @override
  List<Object?> get props => [automations];

  factory AutomationsResponseModel.fromJson(Map<String, dynamic> json) =>
      AutomationsResponseModel(
        automations: ((json['automations'] ?? []) as List<dynamic>).map((e) {
          if (e['type'] == 'hour') {
            return HourAutomationModel.fromJson(e as Map<String, dynamic>);
          }
          if (e['type'] == 'sensor') {
            return SensorAutomationModel.fromJson(e as Map<String, dynamic>);
          }
          return AutomationModel.fromJson(e as Map<String, dynamic>);
        }).toList(),
      );

  Map<String, dynamic> toJson() => <String, dynamic>{
        'automations': automations.map((e) {
          if (e.type == 'hour') {
            return (e as HourAutomationModel).toJson();
          }
          if (e.type == 'sensor') {
            return (e as SensorAutomationModel).toJson();
          }
          return e.toJson();
        }).toList(),
      };
}
