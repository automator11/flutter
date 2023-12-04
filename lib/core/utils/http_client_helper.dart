import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../resources/constants.dart';

class HttpClientHelper {
  late Dio dio;
  late bool _isRefreshingToken;

  final List<String> _publicPaths;

  HttpClientHelper(String baseUrl, this._publicPaths) {
    BaseOptions baseOptions = BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(milliseconds: 10000),
        receiveTimeout: const Duration(milliseconds: 10000));
    dio = Dio(baseOptions);
    _addInterceptors();
    _isRefreshingToken = false;
  }

  void _addInterceptors() async {
    dio.interceptors.add(QueuedInterceptorsWrapper(
      onRequest: (RequestOptions options, RequestInterceptorHandler handler) =>
          _requestInterceptor(options, handler),
      onError: (DioException error, ErrorInterceptorHandler handler) =>
          _errorInterceptor(error, handler),
    ));
  }

  Future<dynamic> _requestInterceptor(
      RequestOptions options, RequestInterceptorHandler handler) async {
    String path = options.path;
    if (!_publicPaths.contains(path)) {
      var storage = const FlutterSecureStorage();
      String token = await storage.read(key: kAccessTokenKey) ?? '';
      options.headers.addAll({'Authorization': 'Bearer $token'});
    } else {
      options.headers.remove('Authorization');
    }
    handler.next(options);
  }

  Future<dynamic> _errorInterceptor(
      DioException error, ErrorInterceptorHandler handler) async {
    //    Token has expired or login has failed.
    if (error.response != null) {
      if (error.response?.statusCode == 401) {
        bool newTokenRetrieved = false;
        RequestOptions options = error.requestOptions;
//      If path is different to login needs a token and token has expired.
        if (options.path != kObtainTokenService) {
          if (!_isRefreshingToken) {
            _isRefreshingToken = true;
//          Create new dio instance for retrieve new access token
            Dio tokenDio = Dio();
            tokenDio.options.baseUrl = options.baseUrl;
            tokenDio.options.connectTimeout =
                const Duration(milliseconds: 10000);
            tokenDio.options.receiveTimeout =
                const Duration(milliseconds: 10000);
            tokenDio.options.headers = options.headers;
            var secureStorage = const FlutterSecureStorage();
            String? refreshToken =
                await secureStorage.read(key: kRefreshTokenKey);
            try {
              //            Refresh access token
              Response tokenResponse = await tokenDio.post(kRefreshTokenService,
                  data: {kRefreshTokenKey: refreshToken});
              if (tokenResponse.statusCode == 200) {
                newTokenRetrieved = true;
                //              Persist access token
                await secureStorage.write(
                    key: kAccessTokenKey,
                    value: tokenResponse.data[kAccessTokenKey]);
                //              Persist refreshToken
                await secureStorage.write(
                    key: kRefreshTokenKey,
                    value: tokenResponse.data[kRefreshTokenKey]);

                options.headers['Authorization'] =
                    'Bearer ${tokenResponse.data[kAccessTokenKey]}';
              }
            } on DioException catch (e) {
              error = e;
              newTokenRetrieved = false;
            }
            _isRefreshingToken = false;
//          Repeat request with new token
            if (newTokenRetrieved) {
              dio.fetch(options).then(
                (r) => handler.resolve(r),
                onError: (e) {
                  handler.reject(e);
                },
              );
              return;
            }
          } else {
            dio.fetch(options).then(
              (r) => handler.resolve(r),
              onError: (e) {
                handler.reject(e);
              },
            );
            return;
          }
        }
      }
    }
    return handler.next(error);
  }
}
