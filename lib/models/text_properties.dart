// ============================================================================
// IMPORTS AND DEPENDENCIES
// ============================================================================

import 'package:flutter/material.dart';

// ============================================================================
// TEXT PROPERTIES MODEL - ANIMATED TEXT DATA STRUCTURE
// ============================================================================

/// Model class representing a moving text element with comprehensive physics properties.
/// 
/// This class serves as the core data structure for animated text elements in the
/// moving text system. It encapsulates all properties needed for rendering,
/// animation, and physics simulation in a single, cohesive object.
/// 
/// **Design Philosophy:**
/// - **Mutable Animation Properties**: Position and velocity can be modified for real-time updates
/// - **Immutable Display Properties**: Text content remains constant (use copyWith for changes)
/// - **Physics Integration**: Designed specifically for collision detection and bouncing
/// - **Performance Optimization**: Minimal object allocation during animation loops
/// 
/// **Key Features:**
/// - **Real-time Updates**: Position and velocity modified in-place for 60fps animation
/// - **Physics Simulation**: Velocity components for realistic movement and bouncing
/// - **Flexible Styling**: Mutable color property for dynamic color transitions
/// - **Developer-Friendly**: copyWith method for creating modified instances
/// 
/// **Animation Lifecycle:**
/// 1. **Creation**: Initialize with starting position, velocity, text, and color
/// 2. **Animation Loop**: Update x/y position based on dx/dy velocity each frame
/// 3. **Physics**: Modify dx/dy when collision detected (bouncing behavior)
/// 4. **Rendering**: Use x/y for Positioned widget placement, color for styling
/// 
/// **Performance Considerations:**
/// - Position updates (x, y) happen 60 times per second - optimized for efficiency
/// - Velocity updates (dx, dy) only occur during physics events - minimal overhead
/// - Color changes are infrequent - acceptable for object allocation
/// - Text content never changes - zero allocation after creation
/// 
/// **For Developers:**
/// ```dart
/// // Create animated text element
/// final textProps = TextProperties(
///   x: 100.0, y: 200.0,     // Initial position on screen
///   dx: 1.5, dy: -2.0,      // Initial velocity (pixels per frame)
///   text: 'Hello',          // Display text (immutable)
///   color: Colors.blue,     // Text color (mutable for animations)
/// );
/// 
/// // Animation loop (60fps)
/// textProps.x += textProps.dx;  // Update position
/// textProps.y += textProps.dy;
/// 
/// // Physics simulation (on collision)
/// if (textProps.x <= 0) {
///   textProps.x = 0;              // Clamp to boundary
///   textProps.dx = -textProps.dx; // Reverse velocity (bounce)
/// }
/// 
/// // Dynamic color changes
/// textProps.color = Colors.red;   // Instant color change
/// 
/// // Create variants (immutable pattern)
/// final newProps = textProps.copyWith(
///   text: 'World!',        // Different text content
///   color: Colors.green,   // Different color
/// );
/// ```
/// 
/// **Mathematical Properties:**
/// - Position (x, y): Measured in logical pixels from top-left corner
/// - Velocity (dx, dy): Pixels per frame at 60fps (positive = right/down)
/// - Collision Detection: Boundary checking against screen edges
/// - Physics Simulation: Elastic collision with velocity reversal
class TextProperties {
  /// Current X position on screen (in logical pixels)
  double x;
  
  /// Current Y position on screen (in logical pixels)
  double y;
  
  /// Horizontal velocity (pixels per frame at 60fps)
  double dx;
  
  /// Vertical velocity (pixels per frame at 60fps)
  double dy;
  
  /// The text content to display (immutable)
  final String text;
  
  /// The color to render the text (immutable)
  Color color;

  /// Creates a new [TextProperties] instance with all required properties.
  /// 
  /// **Parameters:**
  /// - [x], [y]: Initial position coordinates
  /// - [dx], [dy]: Initial velocity components
  /// - [text]: The string content to display
  /// - [color]: The color for rendering the text
  TextProperties({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.text,
    required this.color,
  });

  /// Creates a copy of this [TextProperties] with optionally updated values.
  /// 
  /// This method follows the immutable data pattern, allowing you to create
  /// a new instance with specific properties changed while preserving others.
  /// 
  /// **Example:**
  /// ```dart
  /// final newProps = originalProps.copyWith(
  ///   x: 150.0,  // Update position
  ///   color: Colors.red,  // Change color
  ///   // y, dx, dy, text remain unchanged
  /// );
  /// ```
  TextProperties copyWith({
    double? x,
    double? y,
    double? dx,
    double? dy,
    String? text,
    Color? color,
  }) {
    return TextProperties(
      x: x ?? this.x,
      y: y ?? this.y,
      dx: dx ?? this.dx,
      dy: dy ?? this.dy,
      text: text ?? this.text,
      color: color ?? this.color,
    );
  }
}

/// Configuration class for text styling and appearance.
/// 
/// This immutable class encapsulates font-related properties used for
/// rendering text widgets. It provides a convenient [textStyle] getter
/// that converts the configuration to a Flutter [TextStyle].
/// 
/// **Design Philosophy:**
/// - Immutable configuration objects for predictable styling
/// - Separation of styling logic from rendering logic
/// - Easy conversion to Flutter's native [TextStyle]
/// 
/// **Usage Example:**
/// ```dart
/// const config = TextConfig(
///   fontSize: 24.0,
///   fontFamily: 'Arial',
///   isBold: true,
/// );
/// 
/// // Apply to a Text widget
/// Text('Hello', style: config.textStyle)
/// ```
class TextConfig {
  /// Font size in logical pixels
  final double fontSize;
  
  /// Font family name (null uses system default)
  final String? fontFamily;
  
  /// Whether to apply bold font weight
  final bool isBold;

  /// Creates a new [TextConfig] with the specified styling properties.
  /// 
  /// **Parameters:**
  /// - [fontSize]: The size of the font in logical pixels
  /// - [fontFamily]: Optional font family name (null = system default)
  /// - [isBold]: Whether to use bold font weight
  const TextConfig({
    required this.fontSize,
    this.fontFamily,
    required this.isBold,
  });

  /// Converts this configuration to a Flutter [TextStyle].
  /// 
  /// This getter provides a convenient way to apply the configuration
  /// to any Flutter Text widget or TextSpan.
  /// 
  /// **Returns:** A [TextStyle] configured with this object's properties
  TextStyle get textStyle => TextStyle(
    fontSize: fontSize,
    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    fontFamily: fontFamily,
  );

  /// Creates a copy of this [TextConfig] with optionally updated values.
  /// 
  /// Follows the immutable data pattern for predictable configuration
  /// management throughout the application.
  /// 
  /// **Example:**
  /// ```dart
  /// final newConfig = originalConfig.copyWith(
  ///   fontSize: 32.0,  // Increase size
  ///   isBold: true,     // Make bold
  ///   // fontFamily remains unchanged
  /// );
  /// ```
  TextConfig copyWith({
    double? fontSize,
    String? fontFamily,
    bool? isBold,
  }) {
    return TextConfig(
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      isBold: isBold ?? this.isBold,
    );
  }
}
