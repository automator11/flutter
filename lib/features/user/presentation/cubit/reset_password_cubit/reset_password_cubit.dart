import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/params/params.dart';

part 'reset_password_state.dart';

class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  // final UserRepository _userRepository;

  ResetPasswordCubit() : super(ResetPasswordInitial());

  Future<void> sendResetPasswordEmail(String email) async {
    // emit(ResetPasswordLoading());
    // final data = await _sendResetPasswordEmailUseCase(params: email);
    // if (data is DataSuccess) {
    //   emit(ResetPasswordSuccess());
    // }
    // if (data is DataError) {
    //   if (data.error is DioException) {
    //     final String errorStr =
    //         ErrorHandler(dioException: (data.error as DioException)).errorMessage;
    //     emit(ResetPasswordFailure(message: errorStr));
    //     return;
    //   }
    //   emit(const ResetPasswordFailure(message: 'unknownError'));
    // }
  }

  Future<void> resetPassword(UserResetPasswordParams params) async {
    //   emit(ResetPasswordLoading());
    //   final data = await _resetPasswordUseCase(params: params);
    //   if (data is DataSuccess) {
    //     emit(ResetPasswordSuccess());
    //   }
    //   if (data is DataError) {
    //     if (data.error is DioException) {
    //       final String errorStr =
    //           ErrorHandler(dioException: (data.error as DioException)).errorMessage;
    //       emit(ResetPasswordFailure(message: errorStr));
    //       return;
    //     }
    //     emit(const ResetPasswordFailure(message: 'unknownError'));
    //   }
  }
}
