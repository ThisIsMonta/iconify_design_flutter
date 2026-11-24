import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:iconify_design/src/shared/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IconifyClientService {
  /// Override the default dio instance used for icon fetching.
  static Dio dio = Dio(
    BaseOptions(
      baseUrl: '$api/',
      receiveTimeout: defaultTimeout,
    ),
  );

  /// Override the cache get function to provide a custom cache backend.
  /// Also override [IconifyClientService.cacheSet]
  static FutureOr<String?> Function(String key) cacheGet = _defaultCacheGetter;
  static Future<String?> _defaultCacheGetter(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(key)) return prefs.getString(key);
    return null;
  }

  /// Override the cache set function to provide a custom cache backend.
  /// Also override [IconifyClientService.cacheGet]
  static FutureOr<void> Function(String key, String data) cacheSet =
      _defaultCacheSetter;
  static Future<void> _defaultCacheSetter(String key, String data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  IconifyClientService();

  Future<Either<DioException, Response>> getRequest(String endpoint) async {
    try {
      final response = await dio.get(endpoint);
      if (response.statusCode == 200) {
        return Right(response);
      } else {
        return Left(
          DioException(
            message: "Error",
            requestOptions: RequestOptions(),
          ),
        );
      }
    } on DioException catch (e) {
      return Left(
        DioException(
          message: "Error",
          requestOptions: e.requestOptions,
        ),
      );
    } catch (e) {
      return Left(
        DioException(
          message: "Error",
          requestOptions: RequestOptions(),
        ),
      );
    }
  }
}
