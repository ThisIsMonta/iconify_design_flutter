import 'package:example/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders example sections', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(1200, 1800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const IconifyDesignExample());

    expect(find.text('Iconify Design'), findsOneWidget);
    expect(find.text('Basic Usage'), findsOneWidget);
    expect(find.text('Size and Color'), findsOneWidget);
    expect(find.text('Custom Placeholder'), findsOneWidget);
    expect(find.text('Custom Error Widgets'), findsOneWidget);
    expect(find.text('Icon Grid'), findsOneWidget);
    expect(find.text('Buttons'), findsOneWidget);
  });
}
