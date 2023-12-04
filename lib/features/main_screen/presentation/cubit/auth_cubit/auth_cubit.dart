import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../../core/exceptions/error_handler.dart';
import '../../../../../core/resources/constants.dart';
import '../../../../../core/utils/data_state.dart';
import '../../../../../core/utils/local_storage_helper.dart';
import '../../../../user/data/models/models.dart';
import '../../../../user/data/repositories/repositories.dart';



part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final UserRepository _userRepository;
  final LocalStorageHelper _storage;

  AuthCubit(this._storage, this._userRepository) : super(AuthInitial());

  UserModel? user;

  Future<void> authenticate() async {
    emit(AuthLoading());
    String? accessToken = await _storage.readString(kAccessTokenKey);
    bool isLoggedIn = accessToken != null ? true : false;
    if (isLoggedIn) {
      DataState data = await _userRepository.getUser();
      if (data is DataSuccess) {
        log('user profile loaded');
        user = UserModel.fromJson(data.data);
        emit(Authenticated(user: user));
        return;
      }
      if (data is DataError) {
        await _userRepository.logout();
        await _storage.clearSaved();
        if (data.error is DioException) {
          final String errorStr =
              ErrorHandler(dioException: (data.error as DioException))
                  .errorMessage;
          emit(Unauthenticated(message: errorStr));
          return;
        }
        emit(const Unauthenticated(message: 'unknownError'));
      }
    } else {
      emit(const Unauthenticated());
    }
  }

  void setAuthenticatedState() {
    emit(const Authenticated());
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _userRepository.logout();
    await _storage.clearSaved();
    emit(const Unauthenticated());
  }
}
