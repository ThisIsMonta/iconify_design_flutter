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

  /// Returns the cache key for a specific icon.
  static String iconKey(String icon) {
    return 'icon:$icon';
  }

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

  /// Maximum number of icons to keep in the in-memory cache.
  /// Set to 0 to disable memory caching entirely.
  /// The in-memory cache returns before any other backend (including custom cache).
  static int maxMemoryCacheIcons = 128;

  static Future<void> _defaultCacheSetter(String key, String data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, data);
  }

  static final Map<String, String> _memoryCache = {};

  IconifyClientService();

  /// Removes all entries from the in-memory cache.
  static void clearMemoryCache() => _memoryCache.clear();

  /// Reads an icon from the in-memory cache.
  static String? memoryGet(String key) {
    if (maxMemoryCacheIcons <= 0) return null;
    // remove and reinsert so least-recently-used entries stay at the start
    final data = _memoryCache.remove(key);
    if (data != null) _memoryCache[key] = data;
    return data;
  }

  /// Writes an icon to the in-memory cache.
  static void memorySet(String key, String data) {
    if (maxMemoryCacheIcons <= 0) return;
    _memoryCache.remove(key);
    // evict the least-recently-used entries above the max
    while (_memoryCache.length >= maxMemoryCacheIcons) {
      _memoryCache.remove(_memoryCache.keys.first);
    }
    _memoryCache[key] = data;
  }

  /// Outbound icon requests that are currently resolving.
  static final Map<String, Future<String?>> _requestsInFlight = {};

  /// Fetches an icon and caches it.
  Future<String?> resolveIcon(String icon) {
    final cacheKey = iconKey(icon);

    // return already running request
    final running = _requestsInFlight[cacheKey];
    if (running != null) return running;

    Future<String?> fetch() async {
      // Check if the icon is already cached in a persistent cache
      final cachedIcon = await cacheGet(cacheKey);
      if (cachedIcon != null) {
        memorySet(cacheKey, cachedIcon);
        return cachedIcon;
      }

      // Split the icon identifier into prefix and icon name
      final iconParts = icon.split(":");
      if (iconParts.length != 2) return null;

      final prefix = iconParts[0];
      final iconName = iconParts[1];
      if (prefix.isEmpty || iconName.isEmpty) return null;

      // Fetch the icon from the remote source
      final response = await getRequest('$prefix/$iconName.svg');

      // Cache the fetched icon locally and return the data
      return response.fold(
        (l) {
          return null;
        },
        (r) async {
          await cacheSet(cacheKey, r.data);
          memorySet(cacheKey, r.data);
          return r.data;
        },
      );
    }

    final request = fetch().whenComplete(() {
      _requestsInFlight.remove(cacheKey);
    });
    _requestsInFlight[cacheKey] = request;
    return request;
  }

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
