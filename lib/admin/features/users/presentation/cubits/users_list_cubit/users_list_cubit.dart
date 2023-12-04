import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../../../../../core/exceptions/error_handler.dart';
import '../../../../../../core/exceptions/exception.dart';
import '../../../../../../core/utils/data_state.dart';
import '../../../../../../features/entities/data/params/params.dart';
import '../../../../../../features/user/data/models/models.dart';
import '../../../data/models/models.dart';
import '../../../data/repositories/users_repository.dart';

part 'users_list_state.dart';

class UsersListCubit extends Cubit<UsersListState> {
  final UsersRepository _usersRepository;

  UsersListCubit(this._usersRepository) : super(UsersListInitial());

  int? _pageKey;
  List<UserModel> _items = [];

  void getPagedUsers(SearchEntityParams params) async {
    emit(UsersListInitial());
    final response = await _usersRepository.getPagedUsers(params);
    if (response is DataSuccess) {
      UsersResponseModel usersResponseModel =
          UsersResponseModel.fromJson(response.data);
      final newItems = usersResponseModel.data;
      final totalCount = usersResponseModel.totalElements;
      if (params.page == 0) {
        _items = [];
      }
      _items.addAll(newItems);
      final isLastPage = _items.length == totalCount!;
      _pageKey = isLastPage ? null : (_pageKey ?? 0) + 1;
      emit(UsersListStateNewPage(
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
      emit(UsersListStateNewPage(
          error: errorMessage,
          pageKey: _pageKey,
          items: _items,
          total: _items.length));
    }
  }
}
