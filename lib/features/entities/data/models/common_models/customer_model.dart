import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

import 'models.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel extends Equatable {
  final EntityId id;
  final int createdTime;
  @JsonKey(disallowNullValue: false, includeIfNull: true)
  final EntityId? tenantId;
  final String name;
  final String title;
  final String? email;
  final String? phone;
  final String? country;
  final String? state;
  final String? city;
  final String? address;
  final String? address2;
  final String? zip;
  final Map<String, dynamic>? additionalInfo;
  @JsonKey(disallowNullValue: false, includeIfNull: true)
  final EntityId? parentCustomerId;

  const CustomerModel(
      {this.additionalInfo,
      required this.createdTime,
      required this.id,
      required this.name,
      this.tenantId,
      required this.title,
      this.email,
      this.phone,
      this.parentCustomerId,
      this.state,
      this.country,
      this.city,
      this.address,
      this.address2,
      this.zip});

  @override
  List<Object?> get props => [id, name, title];

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  @override
  String toString() => title;

  String getFieldValueAsString(String field) {
    switch(field){
      case 'name':
        return name;
      case 'title':
        return title;
      case 'email':
        return email ?? '';
      case 'phone':
        return phone ?? '';
      case 'state':
        return state ?? '';
      case 'country':
        return country ?? '';
      default:
        return '';
    }
  }
}
