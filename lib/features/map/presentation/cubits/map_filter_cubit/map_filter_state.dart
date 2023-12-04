part of 'map_filter_cubit.dart';

abstract class MapFilterState extends Equatable {
  const MapFilterState();

  @override
  List<Object> get props => [];
}

class MapFilterInitial extends MapFilterState {}

class MapFilterItemSelected extends MapFilterState {
  final EntityModel item;

  const MapFilterItemSelected({required this.item});

  @override
  List<Object> get props => [item];
}

class MapFilterRefresh extends MapFilterState {}

class MapFilterLoading extends MapFilterState {}

class MapFilterSuccess extends MapFilterState {
  final List<EntityModel> items;

  const MapFilterSuccess({required this.items});

  @override
  List<Object> get props => [items];
}

class MapFilterFail extends MapFilterState {
  final String message;

  const MapFilterFail({required this.message});

  @override
  List<Object> get props => [message];
}
