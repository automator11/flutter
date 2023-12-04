import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../../../features/user/data/models/models.dart';
import '../../../data/params/create_user_params.dart';
import '../../../data/repositories/users_repository.dart';

part 'users_state.dart';

class UsersCubit extends Cubit<UsersState> {
  final UsersRepository _usersRepository;

  UsersCubit(this._usersRepository) : super(UsersInitial());

  void createUser(CreateUserParams params) async {
    emit(UsersLoading());

    final response = await _usersRepository.createUser(params);
    if (response is DataSuccess) {
      UserModel user = UserModel.fromJson(response.data.data);
      emit(UsersSuccess(user: user));
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
      emit(UsersFail(
        message: errorMessage,
      ));
    }
  }

  void deleteUser(String id) async {
    emit(UsersLoading());
    final response = await _usersRepository.deleteUser(id);
    if (response is DataSuccess) {
      emit(const UsersSuccess(isDeleted: true));
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
      emit(UsersFail(
        message: errorMessage,
      ));
    }
  }

  void getActivationLink(String id) async {
    emit(UsersLoading());
    final response = await _usersRepository.getActivationLink(id);
    if (response is DataSuccess) {
      String link = response.data;
      emit(UsersActivationLinkSuccess(link: link));
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
      emit(UsersFail(
        message: errorMessage,
      ));
    }
  }
}
