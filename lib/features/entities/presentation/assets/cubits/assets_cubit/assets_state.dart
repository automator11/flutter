part of 'assets_cubit.dart';

abstract class AssetsState extends Equatable {
  const AssetsState();

  @override
  List<Object> get props => [];
}

class AssetsInitial extends AssetsState {}

class AssetsLoading extends AssetsState {
  final String? message;

  const AssetsLoading({this.message});
}

class AssetsSuccess extends AssetsState {
  final EntityModel? asset;

  const AssetsSuccess({this.asset});
}

class BatchValidationSuccess extends AssetsState {}

class AnimalValidationSuccess extends AssetsState {}

class AssetsFail extends AssetsState {
  final String message;

  const AssetsFail({required this.message});

  @override
  List<Object> get props => [message];
}

class BatchValidationFail extends AssetsState {
  final String message;

  const BatchValidationFail({required this.message});

  @override
  List<Object> get props => [message];
}

class AnimalValidationFail extends AssetsState {
  final String message;
  final EntitySearchModel animal;

  const AnimalValidationFail({required this.message, required this.animal});

  @override
  List<Object> get props => [message, animal];
}
