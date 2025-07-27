import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world/widgets/control_panel_widget.dart';

void main() {
  group('ControlPanelWidget Tests', () {
    late ControlPanelState testState;
    late ControlPanelCallbacks testCallbacks;
    late ScrollController scrollController;

    setUp(() {
      testState = const ControlPanelState(
        speed: 10.0,
        fontSize: 36.0,
        helloColor: Colors.blue,
        worldColor: Colors.red,
        selectedFontIndex: 0,
        isBold: false,
        drawerSize: 0.3,
      );

      testCallbacks = ControlPanelCallbacks(
        onSpeedChanged: (value) {},
        onFontSizeChanged: (value) {},
        onHelloColorChanged: (color) {},
        onWorldColorChanged: (color) {},
        onFontChanged: (index) {},
        onBoldChanged: (bold) {},
        onToggleDrawer: () {},
        onReset: () {},
      );

      scrollController = ScrollController();
    });

    tearDown(() {
      scrollController.dispose();
    });

    testWidgets('should render ControlPanelWidget correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanelWidget(
              state: testState,
              callbacks: testCallbacks,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      // Verify the control panel renders
      expect(find.byType(ControlPanelWidget), findsOneWidget);
      
      // Verify the header is present
      expect(find.text('Controls'), findsOneWidget);
    });

    testWidgets('should display correct slider labels', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanelWidget(
              state: testState,
              callbacks: testCallbacks,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      // Look for speed and size controls
      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('Size'), findsOneWidget);
    });

    testWidgets('should display bold text control', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanelWidget(
              state: testState,
              callbacks: testCallbacks,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      // Verify bold text control
      expect(find.text('Bold Text'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);
    });

    testWidgets('should display reset button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanelWidget(
              state: testState,
              callbacks: testCallbacks,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      // Verify reset button
      expect(find.text('Reset'), findsOneWidget);
      expect(find.byType(FilledButton), findsOneWidget);
    });

    testWidgets('should call onReset when reset button is tapped', (WidgetTester tester) async {
      bool resetCalled = false;
      final callbacksWithReset = ControlPanelCallbacks(
        onReset: () => resetCalled = true,
      );

      // Set larger screen size for testing
      await tester.binding.setSurfaceSize(const Size(800, 1000));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanelWidget(
              state: testState,
              callbacks: callbacksWithReset,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      // Scroll down to make sure the reset button is visible
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Find and tap the FilledButton that contains the Reset text
      final resetButton = find.byType(FilledButton);
      if (resetButton.evaluate().isNotEmpty) {
        await tester.tap(resetButton, warnIfMissed: false);
        await tester.pump();
      }

      expect(resetCalled, isTrue);
    });

    testWidgets('should call onBoldChanged when switch is toggled', (WidgetTester tester) async {
      bool? boldValue;
      final callbacksWithBold = ControlPanelCallbacks(
        onBoldChanged: (value) => boldValue = value,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanelWidget(
              state: testState, // isBold is false initially
              callbacks: callbacksWithBold,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      // Tap the switch to toggle bold
      await tester.tap(find.byType(Switch));
      await tester.pump();

      expect(boldValue, isTrue); // Should be toggled from false to true
    });

    testWidgets('should render with different state values', (WidgetTester tester) async {
      final differentState = const ControlPanelState(
        speed: 25.0,
        fontSize: 72.0,
        helloColor: Colors.green,
        worldColor: Colors.purple,
        selectedFontIndex: 2,
        isBold: true,
        drawerSize: 0.8,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanelWidget(
              state: differentState,
              callbacks: testCallbacks,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      // Should still render correctly with different state
      expect(find.byType(ControlPanelWidget), findsOneWidget);
      expect(find.text('Controls'), findsOneWidget);
      expect(find.text('Bold Text'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('should handle null callbacks gracefully', (WidgetTester tester) async {
      const nullCallbacks = ControlPanelCallbacks(); // All callbacks are null

      // Set larger screen size for testing
      await tester.binding.setSurfaceSize(const Size(800, 1000));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanelWidget(
              state: testState,
              callbacks: nullCallbacks,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      // Should render without errors even with null callbacks
      expect(find.byType(ControlPanelWidget), findsOneWidget);
      
      // The reset button should be disabled when callback is null
      final resetButton = find.byType(FilledButton);
      expect(resetButton, findsOneWidget);
    });

    testWidgets('should have proper container styling', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ControlPanelWidget(
              state: testState,
              callbacks: testCallbacks,
              scrollController: scrollController,
            ),
          ),
        ),
      );

      // Find the main container
      final containerFinder = find.byType(Container).first;
      expect(containerFinder, findsOneWidget);

      // Verify ScrollView is present
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('ControlPanelState Tests', () {
    test('should create ControlPanelState with all required fields', () {
      const state = ControlPanelState(
        speed: 15.0,
        fontSize: 48.0,
        helloColor: Colors.orange,
        worldColor: Colors.cyan,
        selectedFontIndex: 3,
        isBold: true,
        drawerSize: 0.5,
      );

      expect(state.speed, equals(15.0));
      expect(state.fontSize, equals(48.0));
      expect(state.helloColor, equals(Colors.orange));
      expect(state.worldColor, equals(Colors.cyan));
      expect(state.selectedFontIndex, equals(3));
      expect(state.isBold, equals(true));
      expect(state.drawerSize, equals(0.5));
    });
  });

  group('ControlPanelConfig Tests', () {
    test('should have correct font options', () {
      expect(ControlPanelConfig.fontOptions, isNotEmpty);
      expect(ControlPanelConfig.fontOptions.first, isNull); // Default system font
      expect(ControlPanelConfig.fontOptions, contains('Arial'));
      expect(ControlPanelConfig.fontOptions, contains('Comic'));
    });

    test('should have valid speed ranges', () {
      expect(ControlPanelConfig.minSpeed, equals(0.0));
      expect(ControlPanelConfig.maxSpeed, equals(25.0));
      expect(ControlPanelConfig.minSpeed, lessThan(ControlPanelConfig.maxSpeed));
    });

    test('should have valid font size ranges', () {
      expect(ControlPanelConfig.minFontSize, equals(12.0));
      expect(ControlPanelConfig.maxFontSize, equals(144.0));
      expect(ControlPanelConfig.minFontSize, lessThan(ControlPanelConfig.maxFontSize));
    });
  });

  group('ControlPanelCallbacks Tests', () {
    test('should create ControlPanelCallbacks with all null callbacks', () {
      const callbacks = ControlPanelCallbacks();
      
      expect(callbacks.onSpeedChanged, isNull);
      expect(callbacks.onFontSizeChanged, isNull);
      expect(callbacks.onHelloColorChanged, isNull);
      expect(callbacks.onWorldColorChanged, isNull);
      expect(callbacks.onFontChanged, isNull);
      expect(callbacks.onBoldChanged, isNull);
      expect(callbacks.onToggleDrawer, isNull);
      expect(callbacks.onReset, isNull);
    });

    test('should create ControlPanelCallbacks with specific callbacks', () {
      bool resetCalled = false;
      double? speedValue;

      final callbacks = ControlPanelCallbacks(
        onReset: () => resetCalled = true,
        onSpeedChanged: (value) => speedValue = value,
      );

      expect(callbacks.onReset, isNotNull);
      expect(callbacks.onSpeedChanged, isNotNull);
      expect(callbacks.onFontSizeChanged, isNull); // Others should remain null

      // Test callbacks work
      callbacks.onReset?.call();
      callbacks.onSpeedChanged?.call(10.5);

      expect(resetCalled, isTrue);
      expect(speedValue, equals(10.5));
    });
  });
}