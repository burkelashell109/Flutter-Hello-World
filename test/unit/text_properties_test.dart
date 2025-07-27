import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hello_world/models/text_properties.dart';

// Auto-testing enabled - tests should run automatically when this file changes
// Toggle continuous testing: Ctrl+Shift+P -> "Test: Toggle Continuous Run"
void main() {
  group('TextProperties Tests', () {
    
    test('should create TextProperties with all required fields', () {
      final textProps = TextProperties(
        x: 100.0,
        y: 200.0,
        dx: 1.5,
        dy: -2.0,
        text: 'Hello World',
        color: Colors.red,
      );
      
      expect(textProps.x, equals(100.0));
      expect(textProps.y, equals(200.0));
      expect(textProps.dx, equals(1.5));
      expect(textProps.dy, equals(-2.0));
      expect(textProps.text, equals('Hello World'));
      expect(textProps.color, equals(Colors.red));
    });

    group('copyWith', () {
      late TextProperties originalProps;
      
      setUp(() {
        originalProps = TextProperties(
          x: 50.0,
          y: 75.0,
          dx: 2.0,
          dy: 1.5,
          text: 'Original',
          color: Colors.blue,
        );
      });

      test('should create copy with updated x position', () {
        final copied = originalProps.copyWith(x: 150.0);
        
        expect(copied.x, equals(150.0));
        expect(copied.y, equals(75.0)); // Unchanged
        expect(copied.dx, equals(2.0)); // Unchanged
        expect(copied.dy, equals(1.5)); // Unchanged
        expect(copied.text, equals('Original')); // Unchanged
        expect(copied.color, equals(Colors.blue)); // Unchanged
        
        // Original should remain unchanged
        expect(originalProps.x, equals(50.0));
      });

      test('should create copy with updated y position', () {
        final copied = originalProps.copyWith(y: 125.0);
        
        expect(copied.x, equals(50.0)); // Unchanged
        expect(copied.y, equals(125.0));
        expect(copied.dx, equals(2.0)); // Unchanged
        expect(copied.dy, equals(1.5)); // Unchanged
        expect(copied.text, equals('Original')); // Unchanged
        expect(copied.color, equals(Colors.blue)); // Unchanged
      });

      test('should create copy with updated velocities', () {
        final copied = originalProps.copyWith(dx: -1.0, dy: 3.0);
        
        expect(copied.x, equals(50.0)); // Unchanged
        expect(copied.y, equals(75.0)); // Unchanged
        expect(copied.dx, equals(-1.0));
        expect(copied.dy, equals(3.0));
        expect(copied.text, equals('Original')); // Unchanged
        expect(copied.color, equals(Colors.blue)); // Unchanged
      });

      test('should create copy with updated text', () {
        final copied = originalProps.copyWith(text: 'Updated Text');
        
        expect(copied.x, equals(50.0)); // Unchanged
        expect(copied.y, equals(75.0)); // Unchanged
        expect(copied.dx, equals(2.0)); // Unchanged
        expect(copied.dy, equals(1.5)); // Unchanged
        expect(copied.text, equals('Updated Text'));
        expect(copied.color, equals(Colors.blue)); // Unchanged
      });

      test('should create copy with updated color', () {
        final copied = originalProps.copyWith(color: Colors.green);
        
        expect(copied.x, equals(50.0)); // Unchanged
        expect(copied.y, equals(75.0)); // Unchanged
        expect(copied.dx, equals(2.0)); // Unchanged
        expect(copied.dy, equals(1.5)); // Unchanged
        expect(copied.text, equals('Original')); // Unchanged
        expect(copied.color, equals(Colors.green));
      });

      test('should create copy with multiple updated fields', () {
        final copied = originalProps.copyWith(
          x: 200.0,
          dy: -5.0,
          text: 'Multi Update',
          color: Colors.purple,
        );
        
        expect(copied.x, equals(200.0));
        expect(copied.y, equals(75.0)); // Unchanged
        expect(copied.dx, equals(2.0)); // Unchanged
        expect(copied.dy, equals(-5.0));
        expect(copied.text, equals('Multi Update'));
        expect(copied.color, equals(Colors.purple));
      });

      test('should create identical copy when no parameters provided', () {
        final copied = originalProps.copyWith();
        
        expect(copied.x, equals(originalProps.x));
        expect(copied.y, equals(originalProps.y));
        expect(copied.dx, equals(originalProps.dx));
        expect(copied.dy, equals(originalProps.dy));
        expect(copied.text, equals(originalProps.text));
        expect(copied.color, equals(originalProps.color));
        
        // Should be different instances
        expect(identical(copied, originalProps), isFalse);
      });
    });

    test('should handle zero values correctly', () {
      final textProps = TextProperties(
        x: 0.0,
        y: 0.0,
        dx: 0.0,
        dy: 0.0,
        text: '',
        color: Colors.transparent,
      );
      
      expect(textProps.x, equals(0.0));
      expect(textProps.y, equals(0.0));
      expect(textProps.dx, equals(0.0));
      expect(textProps.dy, equals(0.0));
      expect(textProps.text, equals(''));
      expect(textProps.color, equals(Colors.transparent));
    });

    test('should handle negative values correctly', () {
      final textProps = TextProperties(
        x: -50.0,
        y: -25.0,
        dx: -1.5,
        dy: -3.0,
        text: 'Negative Test',
        color: Colors.black,
      );
      
      expect(textProps.x, equals(-50.0));
      expect(textProps.y, equals(-25.0));
      expect(textProps.dx, equals(-1.5));
      expect(textProps.dy, equals(-3.0));
      expect(textProps.text, equals('Negative Test'));
      expect(textProps.color, equals(Colors.black));
    });

    test('should handle large values correctly', () {
      final textProps = TextProperties(
        x: 9999.99,
        y: 8888.88,
        dx: 100.5,
        dy: 200.75,
        text: 'Very long text that might be used in the application',
        color: Colors.amber,
      );
      
      expect(textProps.x, equals(9999.99));
      expect(textProps.y, equals(8888.88));
      expect(textProps.dx, equals(100.5));
      expect(textProps.dy, equals(200.75));
      expect(textProps.text, equals('Very long text that might be used in the application'));
      expect(textProps.color, equals(Colors.amber));
    });
  });

  group('TextConfig Tests', () {
    test('should create TextConfig with required fields', () {
      const config = TextConfig(
        fontSize: 24.0,
        isBold: true,
      );
      
      expect(config.fontSize, equals(24.0));
      expect(config.isBold, equals(true));
      expect(config.fontFamily, isNull);
    });

    test('should create TextConfig with optional fontFamily', () {
      const config = TextConfig(
        fontSize: 18.0,
        fontFamily: 'Arial',
        isBold: false,
      );
      
      expect(config.fontSize, equals(18.0));
      expect(config.fontFamily, equals('Arial'));
      expect(config.isBold, equals(false));
    });

    test('should handle various font sizes', () {
      const smallConfig = TextConfig(fontSize: 8.0, isBold: false);
      const largeConfig = TextConfig(fontSize: 72.0, isBold: true);
      
      expect(smallConfig.fontSize, equals(8.0));
      expect(largeConfig.fontSize, equals(72.0));
    });
  });
}