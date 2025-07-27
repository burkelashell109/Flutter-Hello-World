import 'package:flutter/material.dart';

/// Model class representing a moving text element with physics properties.
/// 
/// This class encapsulates all the properties needed to render and animate
/// a text widget, including position, velocity, content, and styling.
/// 
/// **Key Features:**
/// - Mutable position and velocity for real-time animation updates
/// - Immutable text content and color properties
/// - [copyWith] method for creating modified instances
/// 
/// **Usage Example:**
/// ```dart
/// final textProps = TextProperties(
///   x: 100.0, y: 200.0,
///   dx: 1.5, dy: -2.0,
///   text: 'Hello', 
///   color: Colors.blue,
/// );
/// 
/// // Update position during animation
/// textProps.x += textProps.dx;
/// textProps.y += textProps.dy;
/// ```
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
