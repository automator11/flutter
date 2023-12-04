import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models.dart';


part 'entity_group_model.g.dart';

@JsonSerializable()
class EntityGroupModel extends Equatable{
  final EntityId id;
  final int createdTime;
  final String type;
  final String name;
  final EntityId ownerId;
  final Map<String, dynamic>? additionalInfo;
  final Map<String, dynamic>? configuration;
  @JsonKey(disallowNullValue: false, includeIfNull: true)
  final EntityId? externalId;


  const EntityGroupModel(
      {required this.id,
      required this.createdTime,
      required this.type,
      required this.name,
      required this.ownerId,
      this.additionalInfo,
      this.configuration,
      this.externalId});

  @override
  List<Object?> get props => [id, name, createdTime, type, ownerId];

  factory EntityGroupModel.fromJson(Map<String, dynamic> json) =>
      _$EntityGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$EntityGroupModelToJson(this);

  @override
  String toString() {
    return name;
  }
}