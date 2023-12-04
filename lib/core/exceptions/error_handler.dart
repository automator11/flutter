import 'dart:io';

import 'package:dio/dio.dart';

class ErrorHandler {
  DioException? dioException;
  late String errorMessage;

  ErrorHandler({this.dioException}) {
    buildErrorMessage();
  }

  buildErrorMessage() {
    errorMessage = '';
    try {
      if (dioException != null) {
        switch (dioException!.type) {
          case DioExceptionType.unknown:
            if (dioException!.error.runtimeType == SocketException) {
              errorMessage = 'noConnectionError';
            } else {
              errorMessage = dioException?.message ?? 'unknownError';
            }
            break;
          case DioExceptionType.connectionTimeout:
            errorMessage = 'connectionTimeOutError';
            break;
          case DioExceptionType.badResponse:
            errorMessage = '';
            if (dioException!.response?.statusCode == 401) {
              errorMessage = 'authError';
            } else if (dioException!.response?.statusCode == 403) {
              errorMessage = 'permissionError';
            } else {
              if ((dioException!.response?.data as Map)
                  .containsKey('message')) {
                errorMessage += '${dioException!.response?.data['message']}\n';
              } else {
                errorMessage = dioException?.response?.data?.toString() ??
                    dioException?.message ??
                    'unknownError';
              }
            }
            break;
          default:
            errorMessage = dioException?.message ?? 'unknownError';
            break;
        }
      }
    } catch (e) {
      errorMessage = 'unknownError';
    }
  }
}
