import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'entities_search_response_model.g.dart';

@JsonSerializable()
class EntitiesSearchResponseModel {
  final bool? hasNext;
  final int? totalPages;
  final int? totalElements;
  final List<EntitySearchModel> data;

  EntitiesSearchResponseModel(
      {required this.data, this.hasNext, this.totalElements, this.totalPages});

  factory EntitiesSearchResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EntitiesSearchResponseModelFromJson(json);
}
