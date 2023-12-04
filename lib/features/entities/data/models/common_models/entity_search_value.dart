import 'dart:convert';

import 'models.dart';

class EntitySearchValue {
  final int createdTime;
  final String name;
  final String? type;
  final String label;
  final String? assetProfileId;
  final Map<String, dynamic>? additionalInfo;
  final List<TelemetryModel>? latestValues;

  EntitySearchValue(
      {required this.createdTime,
      required this.name,
      required this.label,
      required this.additionalInfo,
      required this.type,
      required this.assetProfileId,
      this.latestValues});

  factory EntitySearchValue.fromJson(Map<String, dynamic> jsonMap) {
    late String name;
    late String label;
    Map<String, dynamic>? additionalInfo;
    String? type;
    late int createdTime;
    String? assetProfileId;
    List<TelemetryModel>? latestValues;
    for (var fieldType in jsonMap.keys) {
      if (fieldType == 'ENTITY_FIELD') {
        name = jsonMap[fieldType]['name']['value'];
        label = jsonMap[fieldType]['label']['value'];
        additionalInfo =
            jsonDecode(jsonMap[fieldType]['additionalInfo']['value']);
        type = jsonMap[fieldType]['type']['value'];
        createdTime = int.parse(jsonMap[fieldType]['createdTime']['value']);
        assetProfileId = jsonMap[fieldType]['assetProfileId']['value'];
      }
      if (fieldType == 'TIME_SERIES') {
        latestValues = [];
        for (var key in (jsonMap[fieldType] as Map).keys) {
          if (jsonMap[fieldType][key]['value'].toString().isNotEmpty) {
            latestValues.add(TelemetryModel(
                lastUpdateTs: jsonMap[fieldType][key]['ts'],
                key: key,
                value: jsonMap[fieldType][key]['value']));
          }
        }
      }
    }

    return EntitySearchValue(
        name: name,
        label: label,
        additionalInfo: additionalInfo,
        type: type,
        assetProfileId: assetProfileId,
        createdTime: createdTime,
        latestValues: latestValues);
  }

  static Map<String, dynamic> toJson(EntitySearchValue instance) {
    return {};
  }
}
