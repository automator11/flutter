import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import '../../../entities/data/models/models.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final EntityId id;
  final int? createdTime;
  final EntityId tenantId;
  final EntityId? customerId;
  final String email;
  final String? name;
  final String firstName;
  final String? lastName;
  final Map<String, dynamic>? additionalInfo;
  final EntityId ownerId;
  final String authority;

  const UserModel(
      {this.additionalInfo,
      this.createdTime,
      this.customerId,
      required this.email,
      required this.firstName,
      required this.id,
      this.lastName,
      this.name,
      required this.ownerId,
      required this.tenantId,
      required this.authority});

  @override
  List<Object?> get props => [id, createdTime, tenantId, customerId, email];

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  String getFieldValueAsString(String field) {
    switch(field){
      case 'firstName':
        return firstName;
      case 'lastName':
        return lastName ?? '';
      case 'email':
        return email;
      case 'authority':
        return authority;
      default:
        return '';
    }
  }
}
