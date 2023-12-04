import 'package:equatable/equatable.dart';

import 'models.dart';

class TimeseriesResponseModel extends Equatable {
  final String key;
  final List<TimeseriesValueModel> values;

  const TimeseriesResponseModel({required this.key, required this.values});

  @override
  List<Object?> get props => [key, values];

  factory TimeseriesResponseModel.fromJson(
          Map<String, dynamic> json, String key) =>
      TimeseriesResponseModel(
          key: key,
          values: (json[key] as List)
              .map((e) => TimeseriesValueModel.fromJson(e))
              .toList());
}
