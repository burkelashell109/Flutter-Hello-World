// ============================================================================
// IMPORTS AND DEPENDENCIES
// ============================================================================

import 'package:flutter/material.dart';
import 'dart:ui' as ui;         // Low-level rendering and image generation
import 'dart:typed_data';      // Efficient byte array handling for image data

// ============================================================================
// APP ICON GENERATOR - PROGRAMMATIC ICON CREATION
// ============================================================================

/// Widget-based app icon generator for creating consistent, scalable application icons.
/// 
/// **Design Philosophy:**
/// This generator creates app icons programmatically using Flutter's widget system,
/// ensuring perfect consistency between the app's UI and its icon appearance.
/// The design reflects the core "Hello World" theme with animated text elements.
/// 
/// **Visual Design Elements:**
/// - **Circular Background**: Clean, modern circular design with subtle gradient
/// - **Animated Typography**: "Hello" and "World" text with dynamic positioning
/// - **Color Consistency**: Uses the same red/blue color scheme as the app
/// - **Decorative Elements**: Sparkles and hearts add personality and visual interest
/// - **Professional Polish**: Shadows, gradients, and careful spacing create depth
/// 
/// **Technical Implementation:**
/// - **Widget-Based**: Uses Flutter widgets for easy customization and maintenance
/// - **Scalable Design**: Vector-based elements scale perfectly to any icon size
/// - **PNG Generation**: Static method for generating PNG files for app stores
/// - **High Resolution**: Generates 1024x1024 icons suitable for all platforms
/// 
/// **Icon Specifications:**
/// - **Size**: 1024x1024 pixels (Apple App Store and Google Play standard)
/// - **Format**: PNG with transparency support
/// - **Color Space**: sRGB for consistent color reproduction
/// - **Design**: Circular icon safe area with appropriate margins
/// 
/// **For Developers:**
/// The icon can be generated in two ways:
/// 1. **Widget Preview**: Use AppIconGenerator() widget for design preview
/// 2. **PNG Export**: Call AppIconGenerator.generatePng() for app store submission
/// 
/// **Usage Example:**
/// ```dart
/// // Preview in Flutter app
/// Widget build(BuildContext context) {
///   return AppIconGenerator();
/// }
/// 
/// // Generate PNG for app stores
/// final iconBytes = await AppIconGenerator.generatePng();
/// final file = File('app_icon.png');
/// await file.writeAsBytes(iconBytes);
/// ```
/// 
/// **Design Customization:**
/// Developers can modify the visual design by adjusting:
/// - Colors: Change text colors and gradient stops
/// - Typography: Modify font sizes, styles, and positioning
/// - Decorations: Add, remove, or reposition sparkles and hearts
/// - Layout: Adjust text rotation angles and spacing
/// 
/// **Brand Consistency:**
/// The icon design maintains visual consistency with the app by:
/// - Using identical color values (#FF3B30 red, #007AFF blue)
/// - Reflecting the animated text theme
/// - Maintaining the playful, friendly personality
/// - Following Material Design and iOS Human Interface Guidelines
class AppIconGenerator extends StatelessWidget {
  const AppIconGenerator({super.key});

  /// Builds the complete app icon design using Flutter widgets.
  /// 
  /// **Layout Structure:**
  /// - Container: Circular background with gradient and shadow
  /// - Stack: Layered positioning for text and decorative elements
  /// - Positioned: Precise placement of "Hello" and "World" text
  /// - Transform.rotate: Dynamic rotation for visual interest
  /// - Decorative Icons: Sparkles and hearts for personality
  /// 
  /// **Visual Hierarchy:**
  /// 1. Background gradient provides depth and professionalism
  /// 2. Main text ("Hello", "World") serves as primary focus
  /// 3. Decorative elements add personality without overwhelming
  /// 4. Shadows and effects create visual depth and polish
  /// 
  /// **Returns:** Complete icon widget suitable for preview or rendering
  @override
  Widget build(BuildContext context) {
    return Container(
      // Icon dimensions: 1024x1024 (standard for app stores)
      width: 1024,
      height: 1024,
      
      // Background styling with professional gradient and shadow
      decoration: BoxDecoration(
        // Subtle gradient from light gray to slightly darker gray
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F9FA), // Very light gray (top-left)
            Color(0xFFE9ECEF), // Light gray (bottom-right)
          ],
        ),
        
        // Circular icon shape (modern app icon standard)
        shape: BoxShape.circle,
        
        // Subtle border for definition against light backgrounds
        border: Border.all(
          color: const Color(0xFFDEE2E6), // Light gray border
          width: 8,                        // Proportional to icon size
        ),
        
        // Professional drop shadow for depth
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Subtle shadow
            blurRadius: 20,                        // Soft edge
            offset: const Offset(0, 10),           // Slightly below icon
          ),
        ],
      ),
      
      // Content layer with text and decorative elements
      child: Stack(
        children: [
          // Primary text: "Hello" - positioned in upper center area
          Positioned(
            top: 320,    // Vertical positioning from top
            left: 0,     // Full width alignment
            right: 0,    // Full width alignment
            child: Transform.rotate(
              angle: -0.15, // Slight counter-clockwise rotation (~8.6 degrees)
              child: Text(
                'Hello',
                textAlign: TextAlign.center, // Center alignment
                style: TextStyle(
                  fontSize: 140,                           // Large, readable size
                  fontWeight: FontWeight.bold,             // Bold for impact
                  color: const Color(0xFFFF3B30),          // App red color
                  fontFamily: 'Arial',                     // Cross-platform font
                  
                  // Text shadow for depth and readability
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.15), // Subtle shadow
                      offset: const Offset(4, 6),            // Below and right
                      blurRadius: 8,                          // Soft edge
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Secondary text: "World" - positioned in lower center area
          Positioned(
            top: 480,    // Below "Hello" text
            left: 0,     // Full width alignment
            right: 0,    // Full width alignment
            child: Transform.rotate(
              angle: 0.08, // Slight clockwise rotation (~4.6 degrees)
              child: Text(
                'World',
                textAlign: TextAlign.center, // Center alignment
                style: TextStyle(
                  fontSize: 140,                           // Matching size with "Hello"
                  fontWeight: FontWeight.bold,             // Bold for impact
                  color: const Color(0xFF007AFF),          // App blue color
                  fontFamily: 'Arial',                     // Cross-platform font
                  
                  // Matching text shadow for consistency
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.15), // Subtle shadow
                      offset: const Offset(4, 6),            // Below and right
                      blurRadius: 8,                          // Soft edge
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Decorative elements: Sparkles for magical/animated feel
          
          // Top-left sparkle
          Positioned(
            top: 180,
            left: 160,
            child: Transform.rotate(
              angle: 0.3, // Rotation for dynamic feel
              child: const Icon(
                Icons.auto_awesome,               // Star/sparkle icon
                size: 40,                         // Medium size
                color: Color(0xFFFFD700),         // Gold color
              ),
            ),
          ),
          
          // Top-right sparkle
          Positioned(
            top: 160,
            right: 160,
            child: Transform.rotate(
              angle: -0.4, // Counter-rotation for balance
              child: const Icon(
                Icons.auto_awesome,               // Star/sparkle icon
                size: 35,                         // Slightly smaller
                color: Color(0xFFFFD700),         // Gold color
              ),
            ),
          ),
          
          // Bottom-left sparkle
          Positioned(
            bottom: 200,
            left: 140,
            child: Transform.rotate(
              angle: 0.5, // Different rotation angle
              child: const Icon(
                Icons.auto_awesome,               // Star/sparkle icon
                size: 30,                         // Smaller size
                color: Color(0xFFFFD700),         // Gold color
              ),
            ),
          ),
          
          // Bottom-right sparkle
          Positioned(
            bottom: 160,
            right: 140,
            child: Transform.rotate(
              angle: -0.3, // Counter-rotation for variety
              child: const Icon(
                Icons.auto_awesome,               // Star/sparkle icon
                size: 38,                         // Medium size
                color: Color(0xFFFFD700),         // Gold color
              ),
            ),
          ),
          
          // Decorative hearts for friendly, approachable feel
          
          // Left-side heart
          Positioned(
            top: 300,
            left: 200,
            child: Transform.rotate(
              angle: 0.2, // Slight rotation
              child: Icon(
                Icons.favorite,                   // Heart icon
                size: 25,                         // Small size
                color: Colors.pink.withOpacity(0.6), // Semi-transparent pink
              ),
            ),
          ),
          
          // Right-side heart
          Positioned(
            bottom: 280,
            right: 200,
            child: Transform.rotate(
              angle: -0.2, // Counter-rotation
              child: Icon(
                Icons.favorite,                   // Heart icon
                size: 30,                         // Slightly larger
                color: Colors.pink.withOpacity(0.6), // Semi-transparent pink
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Generate PNG from this widget
  static Future<Uint8List> generatePng() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1024, 1024);
    
    // Paint background
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFF8F9FA), Color(0xFFE9ECEF)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      480,
      paint,
    );
    
    // Draw border
    final borderPaint = Paint()
      ..color = const Color(0xFFDEE2E6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      480,
      borderPaint,
    );
    
    // Draw "Hello" text
    final helloTextPainter = TextPainter(
      text: const TextSpan(
        text: 'Hello',
        style: TextStyle(
          fontSize: 140,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFF3B30),
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    helloTextPainter.layout();
    
    canvas.save();
    canvas.translate(size.width / 2, 390);
    canvas.rotate(-0.15);
    helloTextPainter.paint(canvas, Offset(-helloTextPainter.width / 2, -helloTextPainter.height / 2));
    canvas.restore();
    
    // Draw "World" text
    final worldTextPainter = TextPainter(
      text: const TextSpan(
        text: 'World',
        style: TextStyle(
          fontSize: 140,
          fontWeight: FontWeight.bold,
          color: Color(0xFF007AFF),
          fontFamily: 'Arial',
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    worldTextPainter.layout();
    
    canvas.save();
    canvas.translate(size.width / 2, 580);
    canvas.rotate(0.08);
    worldTextPainter.paint(canvas, Offset(-worldTextPainter.width / 2, -worldTextPainter.height / 2));
    canvas.restore();
    
    final picture = recorder.endRecording();
    final image = await picture.toImage(1024, 1024);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
