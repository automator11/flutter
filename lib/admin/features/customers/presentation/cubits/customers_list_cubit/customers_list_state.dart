part of 'customers_list_cubit.dart';

abstract class CustomersListState extends Equatable {
  const CustomersListState();

  @override
  List<Object?> get props => [];
}

class CustomersListStateInitial extends CustomersListState {}

class CustomersListStateNewPage extends CustomersListState {
  final String? error;
  final int? pageKey;
  final List<CustomerModel> items;
  final int? total;
  final int? pageSize;

  const CustomersListStateNewPage(
      {required this.items,
        this.error,
        this.pageKey,
        this.pageSize,
        this.total});

  @override
  List<Object> get props => [items];
}
