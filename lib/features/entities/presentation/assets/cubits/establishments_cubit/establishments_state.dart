part of 'establishments_cubit.dart';

abstract class EstablishmentsState extends Equatable {
  const EstablishmentsState();

  @override
  List<Object> get props => [];
}

class EstablishmentsInitial extends EstablishmentsState {}

class EstablishmentsLoading extends EstablishmentsState {}
class EstablishmentsListLoading extends EstablishmentsState {}

class EstablishmentsSuccess extends EstablishmentsState {
  final String establishmentId;

  const EstablishmentsSuccess({required this.establishmentId});

  @override
  List<Object> get props => [establishmentId];
}

class EstablishmentsNewPage extends EstablishmentsState {
  final String? error;
  final int? pageKey;
  final List<EntityModel> establishments;

  const EstablishmentsNewPage(
      {required this.establishments, this.error, this.pageKey});

  @override
  List<Object> get props => [establishments];
}

class EstablishmentsCreated extends EstablishmentsState {}

class EstablishmentsFail extends EstablishmentsState {
  final String message;

  const EstablishmentsFail({required this.message});

  @override
  List<Object> get props => [message];
}
