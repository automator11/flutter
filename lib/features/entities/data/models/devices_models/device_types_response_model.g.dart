// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_types_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceTypesResponseModel _$DeviceTypesResponseModelFromJson(
        Map<String, dynamic> json) =>
    DeviceTypesResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => DeviceTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DeviceTypesResponseModelToJson(
        DeviceTypesResponseModel instance) =>
    <String, dynamic>{
      'data': instance.data,
    };
