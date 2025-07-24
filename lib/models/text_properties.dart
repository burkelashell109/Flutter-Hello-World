import 'package:flutter/material.dart';

/// Model class to hold properties for a moving text widget
class TextProperties {
  double x;
  double y;
  double dx;
  double dy;
  final String text;
  Color color;

  TextProperties({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.text,
    required this.color,
  });

  /// Create a copy of this object with updated values
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

/// Configuration class for text styling
class TextConfig {
  final double fontSize;
  final String? fontFamily;
  final bool isBold;

  const TextConfig({
    required this.fontSize,
    this.fontFamily,
    required this.isBold,
  });

  TextStyle get textStyle => TextStyle(
    fontSize: fontSize,
    fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
    fontFamily: fontFamily,
  );

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
