// import 'package:bloc/bloc.dart';
// import 'package:dio/dio.dart';
// import 'package:equatable/equatable.dart';

// import '../../../../../core/exceptions/error_handler.dart';
// import '../../../../../core/params/params.dart';
// import '../../../../../core/utils/data_state.dart';
// import '../../../domain/use_cases/use_cases.dart';

// part 'register_state.dart';

// class RegisterCubit extends Cubit<RegisterState> {
//   final RegisterUseCase _registerUseCase;

//   RegisterCubit(this._registerUseCase) : super(RegisterInitial());

//   Future<void> register(UserRegisterParams params) async {
//     emit(RegisterLoading());

//     final data = await _registerUseCase(params: params);
//     if (data is DataSuccess) {
//       emit(RegisterSuccess());
//     }
//     if (data is DataError) {
//       if (data.error is DioException) {
//         String registerError =
//             ErrorHandler(dioException: (data.error as DioException)).errorMessage;
//         emit(RegisterFailure(message: registerError));
//         return;
//       }
//       emit(const RegisterFailure(message: 'unknownError'));
//     }
//   }
// }
