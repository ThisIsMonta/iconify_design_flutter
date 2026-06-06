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
}
