part of 'customers_cubit.dart';

abstract class CustomersState extends Equatable {
  const CustomersState();

  @override
  List<Object> get props => [];
}

class CustomersInitial extends CustomersState {}

class CustomersLoading extends CustomersState {}

class CustomersSuccess extends CustomersState {
  final bool isDeleted;

  const CustomersSuccess({this.isDeleted = false});

  @override
  List<Object> get props => [isDeleted];
}

class CustomersFail extends CustomersState {
  final String message;

  const CustomersFail({required this.message});

  @override
  List<Object> get props => [message];
}
