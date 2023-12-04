import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'entities_response_model.g.dart';

@JsonSerializable()
class EntitiesResponseModel {
  final bool? hasNext;
  final int? totalPages;
  final int? totalElements;
  final List<EntityModel> data;

  EntitiesResponseModel(
      {required this.data, this.hasNext, this.totalElements, this.totalPages});

  factory EntitiesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EntitiesResponseModelFromJson(json);
}
