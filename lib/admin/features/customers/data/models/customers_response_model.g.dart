// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customers_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomersResponseModel _$CustomersResponseModelFromJson(
        Map<String, dynamic> json) =>
    CustomersResponseModel(
      data: (json['data'] as List<dynamic>)
          .map((e) => CustomerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasNext: json['hasNext'] as bool?,
      totalElements: json['totalElements'] as int?,
      totalPages: json['totalPages'] as int?,
    );

Map<String, dynamic> _$CustomersResponseModelToJson(
        CustomersResponseModel instance) =>
    <String, dynamic>{
      'hasNext': instance.hasNext,
      'totalPages': instance.totalPages,
      'totalElements': instance.totalElements,
      'data': instance.data,
    };
