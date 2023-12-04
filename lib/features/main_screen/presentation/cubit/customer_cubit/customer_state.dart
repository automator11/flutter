part of 'customer_cubit.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();
}

class CustomerInitial extends CustomerState {
  @override
  List<Object> get props => [];
}

class CustomerLoading extends CustomerState {
  @override
  List<Object?> get props => [];
}

class CustomerSuccess extends CustomerState {
  final CustomerModel? customer;

  const CustomerSuccess({this.customer});

  @override
  List<Object?> get props => [customer];
}

class CustomerFail extends CustomerState {
  final String message;

  const CustomerFail({required this.message});

  @override
  List<Object?> get props => [message];
}
