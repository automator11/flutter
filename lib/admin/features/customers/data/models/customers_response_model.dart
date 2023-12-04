import 'package:json_annotation/json_annotation.dart';

import '../../../../../features/entities/data/models/models.dart';

part 'customers_response_model.g.dart';

@JsonSerializable()
class CustomersResponseModel {
  final bool? hasNext;
  final int? totalPages;
  final int? totalElements;
  final List<CustomerModel> data;

  CustomersResponseModel(
      {required this.data, this.hasNext, this.totalElements, this.totalPages});

  factory CustomersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$CustomersResponseModelFromJson(json);
}
