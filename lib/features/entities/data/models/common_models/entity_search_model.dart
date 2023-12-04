import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'entity_search_model.g.dart';

@JsonSerializable()
class EntitySearchModel extends Equatable {
  final EntityId entityId;
  final bool readAttrs;
  final bool readTs;
  @JsonKey(
      fromJson: EntitySearchValue.fromJson, toJson: EntitySearchValue.toJson)
  final EntitySearchValue latest;
  final Map<String, dynamic> timeseries;
  final Map<String, dynamic> aggLatest;

  const EntitySearchModel(
      {required this.entityId,
      required this.aggLatest,
      required this.latest,
      required this.readAttrs,
      required this.readTs,
      required this.timeseries});

  @override
  List<Object?> get props => [entityId];

  factory EntitySearchModel.fromJson(Map<String, dynamic> json) =>
      _$EntitySearchModelFromJson(json);

  @override
  String toString() {
    return latest.label;
  }

  EntityModel toEntityModel() {
    return EntityModel(
        createdTime: latest.createdTime,
        id: entityId,
        name: latest.name,
        type: latest.type,
        additionalInfo: latest.additionalInfo,
        label: latest.label,
        latestValues: latest.latestValues);
  }
}
