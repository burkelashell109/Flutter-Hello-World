import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/text_properties.dart';

/// Utility class for text-related calculations and operations
class TextUtils {
  // Shared Random instance to ensure truly independent random numbers
  static final math.Random _random = math.Random();
  /// Measures the size of text with the given style
  static Size measureText(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    
    return Size(painter.width, painter.height);
  }

  /// Calculates the centered position for two text widgets side by side
  static Map<String, double> calculateCenteredPositions({
    required Size screenSize,
    required Size helloSize,
    required Size worldSize,
    double gap = 32.0,
  }) {
    final totalWidth = helloSize.width + worldSize.width + gap;
    final centerX = (screenSize.width - totalWidth) / 2;
    final centerY = (screenSize.height - helloSize.height) / 2;
    
    return {
      'hello_x': centerX,
      'hello_y': centerY,
      'world_x': centerX + helloSize.width + gap,
      'world_y': centerY,
    };
  }

  /// Applies physics (clamping and bouncing) to text position
  static void applyPhysics({
    required TextProperties textProps,
    required Size screenSize,
    required Size textSize,
    required double drawerHeight, // Kept for compatibility but not used for boundaries
    required double speed,
  }) {
    // Calculate boundaries using full screen (ignore drawer height)
    final bottomLimit = screenSize.height - textSize.height;
    final rightLimit = screenSize.width - textSize.width;
    
    // Ensure we have valid boundaries (at least 10px to prevent edge cases)
    final safeBottomLimit = bottomLimit > 10.0 ? bottomLimit : 10.0;
    final safeRightLimit = rightLimit > 10.0 ? rightLimit : 10.0;
    
    // Apply movement based on velocity
    textProps.x += textProps.dx;
    textProps.y += textProps.dy;
    
    // Bounce off edges and clamp positions (using full screen boundaries)
    if (textProps.x <= 0) {
      textProps.x = 0;
      textProps.dx = speed.abs(); // Bounce right
      // Add randomness to dy when bouncing off left/right edges (±1.0 to ±2.0 range)
      final randomOffset = (_random.nextDouble() - 0.5) * 4.0; // Range: -2.0 to +2.0
      textProps.dy += randomOffset;
    }
    if (textProps.y <= 0) {
      textProps.y = 0;
      textProps.dy = speed.abs(); // Bounce down
      // Add randomness to dx when bouncing off top/bottom edges (±1.0 to ±2.0 range)
      final randomOffset = (_random.nextDouble() - 0.5) * 4.0; // Range: -2.0 to +2.0
      textProps.dx += randomOffset;
    }
    if (textProps.x >= safeRightLimit) {
      textProps.x = safeRightLimit;
      textProps.dx = -speed.abs(); // Bounce left
      // Add randomness to dy when bouncing off left/right edges (±1.0 to ±2.0 range)
      final randomOffset = (_random.nextDouble() - 0.5) * 4.0; // Range: -2.0 to +2.0
      textProps.dy += randomOffset;
    }
    if (textProps.y >= safeBottomLimit) {
      textProps.y = safeBottomLimit;
      textProps.dy = -speed.abs(); // Bounce up
      // Add randomness to dx when bouncing off top/bottom edges (±1.0 to ±2.0 range)
      final randomOffset = (_random.nextDouble() - 0.5) * 4.0; // Range: -2.0 to +2.0
      textProps.dx += randomOffset;
    }
  }

  /// Updates movement velocities based on speed
  /// Applies random direction when transitioning from speed=0 to speed>0
  static void updateVelocities({
    required TextProperties textProps,
    required double speed,
  }) {
    if (speed == 0) {
      textProps.dx = 0;
      textProps.dy = 0;
    } else {
      // Check if transitioning from stopped (speed=0) to moving (speed>0)
      final wasStationary = textProps.dx == 0 && textProps.dy == 0;
      
      if (wasStationary) {
        // Generate random direction (360 degrees)
        _setRandomDirection(textProps, speed);
      } else {
        // Preserve current direction, just update speed magnitude
        textProps.dx = textProps.dx.sign * speed;
        textProps.dy = textProps.dy.sign * speed;
      }
    }
  }

  /// Generates a random 360° direction for text movement
  /// Sets dx and dy based on random angle and given speed
  static void _setRandomDirection(TextProperties textProps, double speed) {
    // Generate random angle between 0 and 2π (360 degrees)
    final randomAngle = _random.nextDouble() * 2 * math.pi;
    
    // Convert polar coordinates to cartesian (dx, dy)
    textProps.dx = math.cos(randomAngle) * speed;
    textProps.dy = math.sin(randomAngle) * speed;
  }

  /// Resets text velocities to zero (for reset button functionality)
  /// This ensures the next speed change will trigger random directions
  static void resetVelocities(TextProperties textProps) {
    textProps.dx = 0;
    textProps.dy = 0;
  }
}
