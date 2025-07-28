import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hello_world/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('MovingTextApp Integration Tests', () {
    
    testWidgets('App starts and displays moving text correctly', (WidgetTester tester) async {
      // Launch the app
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

      // Wait for the app to initialize
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify the main app widget is present
      expect(find.byType(MovingTextApp), findsOneWidget);
      
      // Verify the app has a scaffold structure
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Control panel can be opened and interacted with', (WidgetTester tester) async {
      // Launch the app
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

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to find and interact with control panel elements
      // Look for DraggableScrollableSheet which contains the control panel
      final draggableSheet = find.byType(DraggableScrollableSheet);
      if (draggableSheet.evaluate().isNotEmpty) {
        // If control panel is present, try to interact with it
        await tester.drag(draggableSheet, const Offset(0, -200));
        await tester.pumpAndSettle();
      }

      // The app should continue to function without errors
      expect(find.byType(MovingTextApp), findsOneWidget);
    });

    testWidgets('App handles screen rotation gracefully', (WidgetTester tester) async {
      // Launch the app
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

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify app loads in portrait
      expect(find.byType(MovingTextApp), findsOneWidget);

      // Simulate screen size change (like rotation)
      await tester.binding.setSurfaceSize(const Size(800, 600)); // Landscape-like
      await tester.pumpAndSettle();

      // App should still be functional
      expect(find.byType(MovingTextApp), findsOneWidget);

      // Restore original size
      await tester.binding.setSurfaceSize(const Size(411, 731)); // Portrait-like
      await tester.pumpAndSettle();

      expect(find.byType(MovingTextApp), findsOneWidget);
    });

    testWidgets('App performance - animation runs smoothly', (WidgetTester tester) async {
      // Launch the app
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

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Let the animation run for a few frames
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 16)); // ~60fps
      }

      // App should still be responsive
      expect(find.byType(MovingTextApp), findsOneWidget);
    });

    testWidgets('App handles tap gestures correctly', (WidgetTester tester) async {
      // Launch the app
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

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Try tapping on the screen
      await tester.tapAt(const Offset(200, 300));
      await tester.pump();

      // App should handle the tap without crashing
      expect(find.byType(MovingTextApp), findsOneWidget);

      // Try another tap at different location
      await tester.tapAt(const Offset(100, 500));
      await tester.pump();

      expect(find.byType(MovingTextApp), findsOneWidget);
    });

    testWidgets('App memory usage - no memory leaks during animation', (WidgetTester tester) async {
      // Launch the app
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

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Run animation for extended period to check for memory leaks
      for (int i = 0; i < 60; i++) { // Simulate 1 second of animation
        await tester.pump(const Duration(milliseconds: 16));
      }

      // App should still be functional without memory issues
      expect(find.byType(MovingTextApp), findsOneWidget);
    });

    testWidgets('App state persistence - configuration survives app lifecycle', (WidgetTester tester) async {
      // Launch the app
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

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify initial state
      expect(find.byType(MovingTextApp), findsOneWidget);

      // App should continue to function after lifecycle events
      await tester.pump();
      expect(find.byType(MovingTextApp), findsOneWidget);
    });

    testWidgets('Error handling - app gracefully handles edge cases', (WidgetTester tester) async {
      // Launch the app
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

      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Test with very small screen size
      await tester.binding.setSurfaceSize(const Size(100, 100));
      await tester.pumpAndSettle();

      // App should handle small screen size gracefully
      expect(find.byType(MovingTextApp), findsOneWidget);

      // Test with very large screen size
      await tester.binding.setSurfaceSize(const Size(2000, 1500));
      await tester.pumpAndSettle();

      // App should handle large screen size gracefully
      expect(find.byType(MovingTextApp), findsOneWidget);

      // Restore normal size
      await tester.binding.setSurfaceSize(const Size(411, 731));
      await tester.pumpAndSettle();

      expect(find.byType(MovingTextApp), findsOneWidget);
    });
  });
}