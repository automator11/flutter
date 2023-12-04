import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'device_types_response_model.g.dart';

@JsonSerializable()
class DeviceTypesResponseModel {
  final List<DeviceTypeModel> data;

  DeviceTypesResponseModel(
      {required this.data});

  factory DeviceTypesResponseModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceTypesResponseModelFromJson(json);
}