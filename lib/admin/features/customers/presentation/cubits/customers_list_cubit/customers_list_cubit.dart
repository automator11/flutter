import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../../../features/entities/data/models/models.dart';
import '../../../../../../features/entities/data/params/params.dart';
import '../../../../../../features/user/data/models/models.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/customer_repository.dart';

part 'customers_list_state.dart';

class CustomersListCubit extends Cubit<CustomersListState> {
  final CustomerRepository _customerRepository;

  CustomersListCubit(this._customerRepository)
      : super(CustomersListStateInitial());

  int? _pageKey;
  List<CustomerModel> _items = [];

  void getPagedCustomers(SearchEntityParams params) async {
    emit(CustomersListStateInitial());
    final response = await _customerRepository.getPagedCustomers(
       params);
    if (response is DataSuccess) {
      CustomersResponseModel customersResponseModel =
      CustomersResponseModel.fromJson(response.data);
      final newItems = customersResponseModel.data;
      final totalCount = customersResponseModel.totalElements;
      if (params.page == 0) {
        _items = [];
      }
      _items.addAll(newItems);
      final isLastPage = _items.length == totalCount!;
      _pageKey = isLastPage ? null : (_pageKey ?? 0) + 1;
      emit(CustomersListStateNewPage(
        error: null,
        pageKey: _pageKey,
        items: _items,
        total: totalCount,
        pageSize: params.pageSize,
      ));
      return;
    }
    if (response is DataError) {
      String errorMessage = 'unknownError';
      if (response.error is UnauthorizedException) {
        errorMessage = 'sessionExpired';
      } else if (response.error is DioException) {
        errorMessage =
            ErrorHandler(dioException: (response.error as DioException))
                .errorMessage;
      }
      emit(CustomersListStateNewPage(
          error: errorMessage,
          pageKey: _pageKey,
          items: _items,
          total: _items.length));
    }
  }
}
