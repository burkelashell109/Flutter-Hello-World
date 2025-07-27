// This is a basic Flutter widget test for the MovingTextApp.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hello_world/main.dart';

void main() {
  group('MovingTextApp Tests', () {
    testWidgets('App initializes and renders MovingTextApp', (WidgetTester tester) async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(
        MaterialApp(
          home: const MovingTextApp(),
        ),
      );

      // Wait for a few frames instead of pumpAndSettle to avoid animation timeout
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify that MovingTextApp is rendered
      expect(find.byType(MovingTextApp), findsOneWidget);
      
      // Verify the app has a Scaffold structure
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('App renders with MaterialApp theme', (WidgetTester tester) async {
      // Build the complete app
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
          ),
          home: const MovingTextApp(),
        ),
      );

      // Wait for a few frames instead of pumpAndSettle
      for (int i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify the app loads without errors
      expect(find.byType(MovingTextApp), findsOneWidget);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('App structure includes expected widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const MovingTextApp(),
        ),
      );

      // Wait for initial frame
      await tester.pump();

      // Verify basic structure exists
      expect(find.byType(MovingTextApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
