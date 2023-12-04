import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../data/params/params.dart';
import '../../../../../core/exceptions/exception.dart';
import '../../../../../core/utils/data_state.dart';
import '../../../../../core/exceptions/error_handler.dart';
import '../../../data/repositories/repositories.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final UserRepository _userRepository;

  ChangePasswordCubit(this._userRepository) : super(ChangePasswordInitial());

  Future<void> changePassword(UserChangePasswordParams params) async {
    emit(ChangePasswordLoading());
    final data = await _userRepository.changePassword(params);
    if (data is DataSuccess) {
      emit(ChangePasswordSuccess());
    }
    if (data is DataError) {
      if (data.error is UnauthorizedException) {
        emit(const ChangePasswordFailure(
            message: 'sessionExpired', isAuthenticated: false));
        return;
      }
      if (data.error is DioException) {
        final String errorStr =
            ErrorHandler(dioException: (data.error as DioException))
                .errorMessage;
        emit(ChangePasswordFailure(message: errorStr));
        return;
      }
      emit(const ChangePasswordFailure(message: 'unknownError'));
    }
  }
}
