import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world/utils/text_utils.dart';
import 'package:hello_world/models/text_properties.dart';

void main() {
  group('TextUtils Tests', () {
    
    group('measureText', () {
      testWidgets('should measure text size correctly', (WidgetTester tester) async {
        // Build a simple widget to have a proper rendering context
        await tester.pumpWidget(const MaterialApp(
          home: Scaffold(body: Text('Test')),
        ));

        const style = TextStyle(fontSize: 20);
        final size = TextUtils.measureText('Hello', style);
        
        expect(size.width, greaterThan(0));
        expect(size.height, greaterThan(0));
        expect(size.height, closeTo(20, 5)); // Font size should be close to height
      });

      testWidgets('should return different sizes for different text', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(
          home: Scaffold(body: Text('Test')),
        ));

        const style = TextStyle(fontSize: 20);
        final shortSize = TextUtils.measureText('Hi', style);
        final longSize = TextUtils.measureText('Hello World!', style);
        
        expect(longSize.width, greaterThan(shortSize.width));
        expect(longSize.height, equals(shortSize.height)); // Same font size
      });
    });

    group('calculateCenteredPositions', () {
      test('should calculate centered positions correctly', () {
        const screenSize = Size(800, 600);
        const helloSize = Size(100, 50);
        const worldSize = Size(120, 50);
        const gap = 32.0;
        
        final positions = TextUtils.calculateCenteredPositions(
          screenSize: screenSize,
          helloSize: helloSize,
          worldSize: worldSize,
          gap: gap,
        );
        
        final totalWidth = helloSize.width + worldSize.width + gap;
        final expectedCenterX = (screenSize.width - totalWidth) / 2;
        final expectedCenterY = (screenSize.height - helloSize.height) / 2;
        
        expect(positions['hello_x'], equals(expectedCenterX));
        expect(positions['hello_y'], equals(expectedCenterY));
        expect(positions['world_x'], equals(expectedCenterX + helloSize.width + gap));
        expect(positions['world_y'], equals(expectedCenterY));
      });

      test('should handle custom gap correctly', () {
        const screenSize = Size(800, 600);
        const helloSize = Size(100, 50);
        const worldSize = Size(120, 50);
        const customGap = 50.0;
        
        final positions = TextUtils.calculateCenteredPositions(
          screenSize: screenSize,
          helloSize: helloSize,
          worldSize: worldSize,
          gap: customGap,
        );
        
        final totalWidth = helloSize.width + worldSize.width + customGap;
        final expectedCenterX = (screenSize.width - totalWidth) / 2;
        
        expect(positions['world_x'], 
               equals(expectedCenterX + helloSize.width + customGap));
      });
    });

    group('applyPhysics', () {
      test('should bounce off left edge', () {
        final textProps = TextProperties(
          x: -5, // Beyond left edge
          y: 100,
          dx: -2, // Moving left
          dy: 1,
          text: 'Test',
          color: Colors.blue,
        );
        
        TextUtils.applyPhysics(
          textProps: textProps,
          screenSize: const Size(800, 600),
          textSize: const Size(50, 20),
          drawerHeight: 100,
          speed: 2.0,
        );
        
        expect(textProps.x, equals(0)); // Clamped to boundary
        expect(textProps.dx, greaterThan(0)); // Bounced right
      });

      test('should bounce off right edge', () {
        final textProps = TextProperties(
          x: 800, // Beyond right edge (screenWidth = 800, textWidth = 50)
          y: 100,
          dx: 2, // Moving right
          dy: 1,
          text: 'Test',
          color: Colors.blue,
        );
        
        TextUtils.applyPhysics(
          textProps: textProps,
          screenSize: const Size(800, 600),
          textSize: const Size(50, 20),
          drawerHeight: 100,
          speed: 2.0,
        );
        
        expect(textProps.x, equals(750)); // 800 - 50 = 750
        expect(textProps.dx, lessThan(0)); // Bounced left
      });

      test('should bounce off top edge', () {
        final textProps = TextProperties(
          x: 100,
          y: -5, // Beyond top edge
          dx: 1,
          dy: -2, // Moving up
          text: 'Test',
          color: Colors.blue,
        );
        
        TextUtils.applyPhysics(
          textProps: textProps,
          screenSize: const Size(800, 600),
          textSize: const Size(50, 20),
          drawerHeight: 100,
          speed: 2.0,
        );
        
        expect(textProps.y, equals(0)); // Clamped to boundary
        expect(textProps.dy, greaterThan(0)); // Bounced down
      });

      test('should bounce off bottom edge', () {
        final textProps = TextProperties(
          x: 100,
          y: 600, // Beyond bottom edge (screenHeight = 600, textHeight = 20)
          dx: 1,
          dy: 2, // Moving down
          text: 'Test',
          color: Colors.blue,
        );
        
        TextUtils.applyPhysics(
          textProps: textProps,
          screenSize: const Size(800, 600),
          textSize: const Size(50, 20),
          drawerHeight: 100,
          speed: 2.0,
        );
        
        expect(textProps.y, equals(580)); // 600 - 20 = 580
        expect(textProps.dy, lessThan(0)); // Bounced up
      });

      test('should handle small screen sizes safely', () {
        final textProps = TextProperties(
          x: 5,
          y: 5,
          dx: 1,
          dy: 1,
          text: 'Test',
          color: Colors.blue,
        );
        
        // Very small screen where boundaries would be negative
        TextUtils.applyPhysics(
          textProps: textProps,
          screenSize: const Size(30, 15), // Smaller than text size
          textSize: const Size(50, 20),
          drawerHeight: 0,
          speed: 2.0,
        );
        
        // Should use safe limits (10.0) instead of negative values
        expect(textProps.x, lessThanOrEqualTo(10.0));
        expect(textProps.y, lessThanOrEqualTo(10.0));
      });
    });

    group('updateVelocities', () {
      test('should stop movement when speed is zero', () {
        final textProps = TextProperties(
          x: 100,
          y: 100,
          dx: 5,
          dy: 3,
          text: 'Test',
          color: Colors.blue,
        );
        
        TextUtils.updateVelocities(textProps: textProps, speed: 0);
        
        expect(textProps.dx, equals(0));
        expect(textProps.dy, equals(0));
      });

      test('should preserve direction when updating speed', () {
        final textProps = TextProperties(
          x: 100,
          y: 100,
          dx: 2, // Positive (moving right)
          dy: -3, // Negative (moving up)
          text: 'Test',
          color: Colors.blue,
        );
        
        TextUtils.updateVelocities(textProps: textProps, speed: 5);
        
        expect(textProps.dx, equals(5)); // Positive direction preserved
        expect(textProps.dy, equals(-5)); // Negative direction preserved
      });

      test('should generate random direction when transitioning from stationary', () {
        final textProps = TextProperties(
          x: 100,
          y: 100,
          dx: 0, // Stationary
          dy: 0, // Stationary
          text: 'Test',
          color: Colors.blue,
        );
        
        TextUtils.updateVelocities(textProps: textProps, speed: 3);
        
        // Should have some velocity after transitioning from stationary
        final totalVelocity = (textProps.dx * textProps.dx + textProps.dy * textProps.dy);
        expect(totalVelocity, greaterThan(0));
        
        // Total velocity magnitude should be close to speed (within reasonable tolerance)
        expect(totalVelocity, closeTo(9, 1)); // speed^2 = 3^2 = 9
      });
    });

    group('resetVelocities', () {
      test('should reset all velocities to zero', () {
        final textProps = TextProperties(
          x: 100,
          y: 100,
          dx: 5,
          dy: -3,
          text: 'Test',
          color: Colors.blue,
        );
        
        TextUtils.resetVelocities(textProps);
        
        expect(textProps.dx, equals(0));
        expect(textProps.dy, equals(0));
        // Position should remain unchanged
        expect(textProps.x, equals(100));
        expect(textProps.y, equals(100));
      });
    });
  });
}