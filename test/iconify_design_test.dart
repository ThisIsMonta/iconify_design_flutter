import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _cachedSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24">
  <path fill="currentColor" d="M12 2L2 22h20L12 2z"/>
</svg>
''';

/// Fake cache adapter for dio to mock requests
class _FakeCacheAdapter implements HttpClientAdapter {
  final String responseData;
  int requestCount = 0;
  RequestOptions? lastRequestOptions;

  _FakeCacheAdapter(this.responseData);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requestCount++;
    lastRequestOptions = options;
    return Future.value(ResponseBody.fromString(responseData, 200));
  }

  @override
  void close({bool force = false}) {}
}

/// Fake cache adapter for dio that fails the first [failures] requests
class _FlakyCacheAdapter implements HttpClientAdapter {
  final String responseData;
  final int failures;
  int requestCount = 0;

  _FlakyCacheAdapter(this.responseData, {required this.failures});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requestCount++;
    if (requestCount <= failures) {
      return Future.value(ResponseBody.fromString('error', 500));
    }
    return Future.value(ResponseBody.fromString(responseData, 200));
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  setUp(IconifyClientService.clearMemoryCache);

  testWidgets('renders cached icon with default color', (tester) async {
    SharedPreferences.setMockInitialValues({'icon:test:cached': _cachedSvg});

    await tester.pumpWidget(
      const MaterialApp(home: IconifyIcon(icon: 'test:cached')),
    );
    await tester.pump();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders cached icon when color is null', (tester) async {
    SharedPreferences.setMockInitialValues({'icon:test:cached': _cachedSvg});

    await tester.pumpWidget(
      const MaterialApp(
        home: IconifyIcon(
          icon: 'test:cached',
          color: null,
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses custom placeholder while loading', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        home: IconifyIcon(
          icon: 'loading-icon',
          placeholder: Text('Loading icon'),
        ),
      ),
    );

    expect(find.text('Loading icon'), findsOneWidget);
  });

  testWidgets('uses custom error widget when icon cannot be loaded', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(
        home: IconifyIcon(
          icon: 'invalid-icon',
          errorWidget: Text('Icon unavailable'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Icon unavailable'), findsOneWidget);
  });

  testWidgets('uses custom in-memory cache to save and load icons', (
    tester,
  ) async {
    final originalDio = IconifyClientService.dio;
    final originalCacheGet = IconifyClientService.cacheGet;
    final originalCacheSet = IconifyClientService.cacheSet;
    addTearDown(() {
      IconifyClientService.dio = originalDio;
      IconifyClientService.cacheGet = originalCacheGet;
      IconifyClientService.cacheSet = originalCacheSet;
    });

    final Map<String, String> memoryCache = {};
    IconifyClientService.cacheGet = (key) => memoryCache[key];
    IconifyClientService.cacheSet = (key, data) => memoryCache[key] = data;

    const customBaseUrl = 'https://custom.example.com/';
    const customTimeout = Duration(seconds: 5);
    final dio = Dio(
      BaseOptions(baseUrl: customBaseUrl, receiveTimeout: customTimeout),
    );
    final adapter = _FakeCacheAdapter(_cachedSvg);
    dio.httpClientAdapter = adapter;
    IconifyClientService.dio = dio;

    await tester.pumpWidget(
      const MaterialApp(home: IconifyIcon(icon: 'test:custom')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(memoryCache['icon:test:custom'], isNotNull);
    expect(memoryCache['icon:test:custom'], _cachedSvg);
    expect(adapter.requestCount, 1);
    expect(adapter.lastRequestOptions!.baseUrl, customBaseUrl);
    expect(adapter.lastRequestOptions!.receiveTimeout, customTimeout);

    await tester.pumpWidget(
      const MaterialApp(home: IconifyIcon(icon: 'test:custom')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(adapter.requestCount, 1);
  });

  testWidgets('caches each icon under its own key after an async lookup', (
    tester,
  ) async {
    final originalDio = IconifyClientService.dio;
    final originalCacheGet = IconifyClientService.cacheGet;
    final originalCacheSet = IconifyClientService.cacheSet;
    addTearDown(() {
      IconifyClientService.dio = originalDio;
      IconifyClientService.cacheGet = originalCacheGet;
      IconifyClientService.cacheSet = originalCacheSet;
    });

    final firstLookup = Completer<String?>();
    final cache = <String, String>{};
    final adapter = _FakeCacheAdapter(_cachedSvg);
    IconifyClientService.dio = Dio(BaseOptions(baseUrl: 'https://example.com/'))
      ..httpClientAdapter = adapter;
    IconifyClientService.cacheGet = (key) {
      if (key == 'icon:test:first') return firstLookup.future;
      return cache[key];
    };
    IconifyClientService.cacheSet = (key, data) => cache[key] = data;

    await tester.pumpWidget(
      const MaterialApp(home: IconifyIcon(icon: 'test:first')),
    );
    await tester.pumpWidget(
      const MaterialApp(home: IconifyIcon(icon: 'test:second')),
    );
    await tester.pumpAndSettle();
    expect(adapter.lastRequestOptions?.path, 'test/second.svg');
    expect(cache, {'icon:test:second': _cachedSvg});

    firstLookup.complete(null);
    await tester.pumpAndSettle();
    expect(adapter.lastRequestOptions?.path, 'test/first.svg');
    expect(cache['icon:test:first'], _cachedSvg);
  });

  testWidgets('rebuilds neither re-fetch nor re-show the placeholder', (
    tester,
  ) async {
    final originalDio = IconifyClientService.dio;
    addTearDown(() {
      IconifyClientService.dio = originalDio;
    });
    SharedPreferences.setMockInitialValues({});

    const customBaseUrl = 'https://custom.example.com/';
    final dio = Dio(BaseOptions(baseUrl: customBaseUrl));
    final adapter = _FakeCacheAdapter(_cachedSvg);
    dio.httpClientAdapter = adapter;
    IconifyClientService.dio = dio;

    await tester.pumpWidget(
      const MaterialApp(home: IconifyIcon(icon: 'test:rebuilt')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(adapter.requestCount, 1);

    // rebuilding the same icon renders synchronously
    // with same request count and no placeholder
    await tester.pumpWidget(
      const MaterialApp(home: IconifyIcon(icon: 'test:rebuilt')),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(adapter.requestCount, 1);
  });

  testWidgets('concurrent widgets for the same icon share one request', (
    tester,
  ) async {
    final originalDio = IconifyClientService.dio;
    addTearDown(() {
      IconifyClientService.dio = originalDio;
    });
    SharedPreferences.setMockInitialValues({});

    final dio = Dio();
    final adapter = _FakeCacheAdapter(_cachedSvg);
    dio.httpClientAdapter = adapter;
    IconifyClientService.dio = dio;

    await tester.pumpWidget(
      const MaterialApp(
        home: Column(
          children: [
            IconifyIcon(icon: 'test:shared'),
            IconifyIcon(icon: 'test:shared')
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsNWidgets(2));
    expect(adapter.requestCount, 1);
  });

  test('in-memory cache evicts least-recently-used entries', () {
    IconifyClientService.maxMemoryCacheIcons = 2;
    addTearDown(() => IconifyClientService.maxMemoryCacheIcons = 128);

    IconifyClientService.memorySet('icon:a', 'A');
    IconifyClientService.memorySet('icon:b', 'B');

    // reading 'a' makes it the most recently used
    expect(IconifyClientService.memoryGet('icon:a'), 'A');

    // 'c' evicts the least recently used entry 'b'
    IconifyClientService.memorySet('icon:c', 'C');
    expect(IconifyClientService.memoryGet('icon:b'), isNull);
    expect(IconifyClientService.memoryGet('icon:a'), 'A');
    expect(IconifyClientService.memoryGet('icon:c'), 'C');
  });

  testWidgets('renders icons when the memory cache is disabled',
      (tester) async {
    IconifyClientService.maxMemoryCacheIcons = 0;
    addTearDown(() => IconifyClientService.maxMemoryCacheIcons = 128);

    SharedPreferences.setMockInitialValues({'icon:test:disabled': _cachedSvg});

    await tester.pumpWidget(
      const MaterialApp(home: IconifyIcon(icon: 'test:disabled')),
    );
    await tester.pump();

    // icons still render through the persistent cache while disabled
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.takeException(), isNull);

    // and nothing was written to the in-memory cache
    // must enable memory cache to read from it
    IconifyClientService.maxMemoryCacheIcons = 128;
    expect(
      IconifyClientService.memoryGet(
        IconifyClientService.iconKey('test:disabled'),
      ),
      isNull,
    );
  });

  testWidgets('retries a failed icon when the widget is rebuilt', (
    tester,
  ) async {
    final originalDio = IconifyClientService.dio;
    addTearDown(() {
      IconifyClientService.dio = originalDio;
    });
    SharedPreferences.setMockInitialValues({});

    final dio = Dio();
    final adapter = _FlakyCacheAdapter(_cachedSvg, failures: 1);
    dio.httpClientAdapter = adapter;
    IconifyClientService.dio = dio;

    // the first attempt fails and the default error widget is shown
    await tester.pumpWidget(
      const MaterialApp(home: IconifyIcon(icon: 'test:retry')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsNothing);
    expect(adapter.requestCount, 1);

    // rebuilding the widget retries the request once and renders the icon
    await tester.pumpWidget(
      const MaterialApp(home: IconifyIcon(icon: 'test:retry')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(adapter.requestCount, 2);
  });
}
