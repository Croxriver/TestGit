import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo_app/main.dart';

void main() {
  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('나의 할 일'), findsOneWidget);
  });

  testWidgets('FAB is present', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('새 할 일'), findsOneWidget);
  });
}
