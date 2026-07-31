import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iconify_design/iconify_design.dart';
import 'package:iconify_design/src/shared/constants.dart';
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

  _FakeCacheAdapter(this.responseData);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    requestCount++;
    return Future.value(ResponseBody.fromString(responseData, 200));
  }

  @override
  void close({bool force = false}) {}
}

void main() {
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

    final dio = Dio(BaseOptions(baseUrl: "$api/"));
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

    await tester.pumpWidget(
      const MaterialApp(home: IconifyIcon(icon: 'test:custom')),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(adapter.requestCount, 1);
  });
}
