// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
      createdTime: json['createdTime'] as int?,
      customerId: json['customerId'] == null
          ? null
          : EntityId.fromJson(json['customerId'] as Map<String, dynamic>),
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      id: EntityId.fromJson(json['id'] as Map<String, dynamic>),
      lastName: json['lastName'] as String?,
      name: json['name'] as String?,
      ownerId: EntityId.fromJson(json['ownerId'] as Map<String, dynamic>),
      tenantId: EntityId.fromJson(json['tenantId'] as Map<String, dynamic>),
      authority: json['authority'] as String,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'createdTime': instance.createdTime,
      'tenantId': instance.tenantId,
      'customerId': instance.customerId,
      'email': instance.email,
      'name': instance.name,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'additionalInfo': instance.additionalInfo,
      'ownerId': instance.ownerId,
      'authority': instance.authority,
    };
