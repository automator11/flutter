part of 'dropdown_cubit.dart';

abstract class DropdownState extends Equatable {
  final String? groupType;

  const DropdownState({this.groupType});

  @override
  List<Object> get props => [];
}

class DropdownInitial extends DropdownState {}

class DropdownLoading extends DropdownState {
  const DropdownLoading({super.groupType});
}

class DropdownSuccess extends DropdownState {
  final List<EntityModel>? items;
  final List<EntitySearchModel>? searchItems;
  final List<CustomerModel>? customersItems;
  final List<String>? textItems;

  const DropdownSuccess(
      {this.items,
      this.searchItems,
      this.textItems,
      this.customersItems,
      super.groupType});

  @override
  List<Object> get props => [items ?? [], searchItems ?? [], textItems ?? []];
}

class DropdownFail extends DropdownState {
  final String message;

  const DropdownFail({required this.message, super.groupType});

  @override
  List<Object> get props => [message];
}

class DropdownSelectedState extends Equatable {
  final bool isLoading;
  final bool error;
  final List<dynamic> items;

  const DropdownSelectedState(
      {required this.isLoading, required this.error, required this.items});

  @override
  List<Object?> get props => [isLoading, error, items];
}
