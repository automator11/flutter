import 'package:json_annotation/json_annotation.dart';

import '../../../../../features/user/data/models/models.dart';

part 'users_response_model.g.dart';

@JsonSerializable()
class UsersResponseModel {
  final bool? hasNext;
  final int? totalPages;
  final int? totalElements;
  final List<UserModel> data;

  UsersResponseModel(
      {required this.data, this.hasNext, this.totalElements, this.totalPages});

  factory UsersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UsersResponseModelFromJson(json);
}