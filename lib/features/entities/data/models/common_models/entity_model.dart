import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'entity_model.g.dart';

@JsonSerializable()
class EntityModel extends Equatable {
  final EntityId id;
  final int createdTime;
  @JsonKey(disallowNullValue: false, includeIfNull: true)
  final EntityId? tenantId;
  @JsonKey(disallowNullValue: false, includeIfNull: true)
  final EntityId? customerId;
  final String name;
  final String? type;
  final String? label;
  @JsonKey(disallowNullValue: false, includeIfNull: true)
  final EntityId? assetProfileId;
  @JsonKey(disallowNullValue: false, includeIfNull: true)
  final EntityId? deviceProfileId;
  final Map<String, dynamic>? additionalInfo;
  final List<TelemetryModel>? latestValues;
  final Map<String, dynamic>? deviceData;
  final EntityId? ownerId;

  const EntityModel(
      {this.additionalInfo,
      this.deviceData,
      this.assetProfileId,
      this.deviceProfileId,
      required this.createdTime,
      this.customerId,
      required this.id,
      this.label,
      required this.name,
      this.ownerId,
      this.tenantId,
      this.type,
      this.latestValues});

  @override
  List<Object?> get props => [id.id, name, type];

  factory EntityModel.fromJson(Map<String, dynamic> json) =>
      _$EntityModelFromJson(json);

  Map<String, dynamic> toJson() => _$EntityModelToJson(this);

  @override
  String toString() {
    return label ?? name;
  }
  String getFieldValueAsString(String field) {
    switch(field){
      case 'name':
        return name;
      case 'label':
        return label ?? '';
      case 'type':
        return type ?? '';
      default:
        return '';
    }
  }

}
