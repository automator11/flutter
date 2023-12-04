// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CustomerModel _$CustomerModelFromJson(Map<String, dynamic> json) =>
    CustomerModel(
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      createdTime: json['createdTime'] as int,
      id: EntityId.fromJson(json['id'] as Map<String, dynamic>),
      name: json['name'] as String,
      tenantId: json['tenantId'] == null
          ? null
          : EntityId.fromJson(json['tenantId'] as Map<String, dynamic>),
      title: json['title'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      parentCustomerId: json['parentCustomerId'] == null
          ? null
          : EntityId.fromJson(json['parentCustomerId'] as Map<String, dynamic>),
      state: json['state'] as String?,
      country: json['country'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      address2: json['address2'] as String?,
      zip: json['zip'] as String?,
    );

Map<String, dynamic> _$CustomerModelToJson(CustomerModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'createdTime': instance.createdTime,
      'tenantId': instance.tenantId,
      'name': instance.name,
      'title': instance.title,
      'email': instance.email,
      'phone': instance.phone,
      'country': instance.country,
      'state': instance.state,
      'city': instance.city,
      'address': instance.address,
      'address2': instance.address2,
      'zip': instance.zip,
      'additionalInfo': instance.additionalInfo,
      'parentCustomerId': instance.parentCustomerId,
    };
