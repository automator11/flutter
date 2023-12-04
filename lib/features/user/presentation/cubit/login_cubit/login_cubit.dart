import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../data/params/params.dart';
import '../../../../../core/exceptions/error_handler.dart';
import '../../../../../core/exceptions/exception.dart';

import '../../../../../core/resources/constants.dart';
import '../../../../../core/utils/data_state.dart';
import '../../../../../core/utils/local_storage_helper.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/repositories.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final UserRepository _userRepository;
  final LocalStorageHelper _storage;

  LoginCubit(this._storage, this._userRepository) : super(LoginInitial());

  Future<void> login(UserLoginParams params) async {
    emit(LoginLoading());

    DataState data = await _userRepository.login(params);
    if (data is DataSuccess) {
      if (data.data?.containsKey(kAccessTokenKey) ?? false) {
        await _storage.writeString(
            kAccessTokenKey, data.data?[kAccessTokenKey]);
        await _storage.writeString(
            kRefreshTokenKey, data.data?[kRefreshTokenKey]);
        data = await _userRepository.getUser();
        if (data is DataSuccess) {
          final user = UserModel.fromJson(data.data);
          emit(LoginSuccess(user: user));
        }
      } else {
        String loginError = 'unknownError';
        emit(LoginFailure(message: loginError));
      }
    }
    if (data is DataError) {
      if (data.error is UnauthorizedException) {
        emit(const LoginFailure(message: 'invalidCredentials'));
        return;
      }
      if (data.error is DioException) {
        String loginError =
            ErrorHandler(dioException: (data.error as DioException))
                .errorMessage;
        emit(LoginFailure(message: loginError));
        return;
      }
      emit(const LoginFailure(message: 'unknownError'));
    }
  }
}
