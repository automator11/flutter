import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/exceptions/error_handler.dart';
import '../../../../../core/utils/data_state.dart';
import '../../../../entities/data/models/models.dart';
import '../../../../user/data/repositories/repositories.dart';


part 'customer_state.dart';

class CustomerCubit extends Cubit<CustomerState> {
  final UserRepository _userRepository;

  CustomerCubit(this._userRepository) : super(CustomerInitial());

  Future<void> getCustomer(String customerId) async {
    emit(CustomerLoading());
    DataState data = await _userRepository.getCustomer(customerId);
    if (data is DataSuccess) {
      CustomerModel customer = CustomerModel.fromJson(data.data);
      emit(CustomerSuccess(customer: customer));
      return;
    }
    if (data is DataError) {
      if (data.error is DioException) {
        final String errorStr =
            ErrorHandler(dioException: (data.error as DioException))
                .errorMessage;
        emit(CustomerFail(message: errorStr));
        return;
      }
      emit(const CustomerFail(message: 'unknownError'));
    }
  }
}
