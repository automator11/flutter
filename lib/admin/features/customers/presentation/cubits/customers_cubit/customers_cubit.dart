import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../data/params/create_customer_params.dart';
import '../../../data/repositories/customer_repository.dart';

part 'customers_state.dart';

class CustomersCubit extends Cubit<CustomersState> {
  final CustomerRepository _customerRepository;

  CustomersCubit(this._customerRepository) : super(CustomersInitial());

  void createCustomer(CreateCustomerParams params) async {
    emit(CustomersLoading());

    final response = await _customerRepository.createCustomer(params);
    if (response is DataSuccess) {
      emit(const CustomersSuccess());
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
      emit(CustomersFail(
        message: errorMessage,
      ));
    }
  }

  void deleteCustomer(String id) async {
    emit(CustomersLoading());
    final response = await _customerRepository.deleteCustomer(id);
    if (response is DataSuccess) {
      emit(const CustomersSuccess(isDeleted: true));
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
      emit(CustomersFail(
        message: errorMessage,
      ));
    }
  }
}
