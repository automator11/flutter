import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'entity_groups_response_model.g.dart';

@JsonSerializable()
class EntityGroupsResponseModel {
  final List<EntityGroupModel> data;

  EntityGroupsResponseModel(
      {required this.data});

  factory EntityGroupsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EntityGroupsResponseModelFromJson(json);
}
