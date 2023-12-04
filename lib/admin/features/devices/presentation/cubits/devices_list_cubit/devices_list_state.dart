part of 'devices_list_cubit.dart';

abstract class DevicesListState extends Equatable {
  const DevicesListState();
}

class DevicesListInitial extends DevicesListState {
  @override
  List<Object> get props => [];
}

class DevicesListNewPage extends DevicesListState {
  final String? error;
  final int? pageKey;
  final List<EntityModel> items;
  final int? total;
  final int? pageSize;

  const DevicesListNewPage(
      {required this.items,
        this.error,
        this.pageKey,
        this.pageSize,
        this.total});

  @override
  List<Object> get props => [items];
}
