import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'entity_id.g.dart';

@JsonSerializable()
class EntityId extends Equatable {
  final String id;
  final String entityType;

  const EntityId({required this.id, required this.entityType});

  @override
  List<Object?> get props => [id, entityType];

  factory EntityId.fromJson(Map<String, dynamic> json) =>
      _$EntityIdFromJson(json);

  Map<String, dynamic> toJson() => _$EntityIdToJson(this);
}
