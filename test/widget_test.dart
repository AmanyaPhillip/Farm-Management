import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farm_management/main.dart';

void main() {
  testWidgets('MyApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    // App should render a MaterialApp with the login screen entry point.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
