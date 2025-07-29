import 'package:flutter/material.dart';
import '../models/text_properties.dart';

// ============================================================================
// IMPORTS AND DEPENDENCIES
// ============================================================================

import 'package:flutter/material.dart';

// Import models for text properties and configuration
import '../models/text_properties.dart';

// ============================================================================
// MOVING TEXT WIDGET - ANIMATED TEXT RENDERER
// ============================================================================

/// Stateless widget that renders a single animated text element at a specific position.
/// 
/// This widget serves as the visual representation of a [TextProperties] object,
/// handling the conversion from animation data to rendered Flutter UI components.
/// It's designed for high-performance rendering with minimal rebuilds.
/// 
/// **Design Philosophy:**
/// - **Stateless Architecture**: Pure function from properties to visual output
/// - **Performance Optimized**: Efficient rendering with strategic key usage
/// - **Separation of Concerns**: Focuses solely on rendering, not animation logic
/// - **Responsive Design**: Automatically adapts to different screen sizes and orientations
/// 
/// **Key Features:**
/// - **Absolute Positioning**: Uses Positioned widget for precise placement
/// - **Dynamic Styling**: Applies font configuration and color from properties
/// - **Performance Keys**: ValueKey prevents unnecessary widget rebuilds
/// - **Text Rendering**: Leverages Flutter's optimized Text widget
/// 
/// **Performance Optimizations:**
/// - **Strategic Keys**: ValueKey based on text content and style prevents unnecessary rebuilds
/// - **Immutable Properties**: Stateless design eliminates state management overhead
/// - **Efficient Updates**: Only rebuilds when actual content or style changes
/// - **Minimal Overhead**: Direct property-to-widget mapping with no intermediate processing
/// 
/// **For Developers:**
/// This widget is typically not instantiated directly by developers. Instead,
/// it's created automatically by the animation system based on [TextProperties]
/// objects. The animation controller manages a list of these widgets and updates
/// their properties each frame.
/// 
/// **Usage in Animation System:**
/// ```dart
/// // Animation controller creates MovingTextWidget instances
/// final widgets = textPropertiesList.map((textProps) {
///   return MovingTextWidget(
///     key: ValueKey('${textProps.text}-${textConfig.fontFamily}'),
///     textProps: textProps,    // Position, color, content
///     textConfig: textConfig,  // Font styling information
///   );
/// }).toList();
/// 
/// // These widgets are then placed in a Stack for layered rendering
/// return Stack(children: widgets);
/// ```
/// 
/// **Widget Lifecycle:**
/// 1. **Creation**: Animation system instantiates with current text properties
/// 2. **Rendering**: build() method converts properties to Positioned Text widget
/// 3. **Updates**: Flutter rebuilds only when ValueKey indicates changes
/// 4. **Disposal**: Automatic cleanup when animation system removes the widget
/// 
/// **Positioning System:**
/// Uses Flutter's Positioned widget for absolute positioning within a Stack.
/// The x,y coordinates from TextProperties map directly to left,top properties.
/// This enables pixel-perfect control over text placement during animation.
/// 
/// **Text Styling Integration:**
/// Combines the base TextStyle from TextConfig with the dynamic color from
/// TextProperties, allowing for independent control of font properties and
/// color animations.
class MovingTextWidget extends StatelessWidget {
  /// The text properties containing position, velocity, content, and color information.
  /// 
  /// **Content Details:**
  /// - x, y: Current position coordinates for absolute positioning
  /// - dx, dy: Velocity components (used by animation system, not directly by widget)
  /// - text: The string content to display
  /// - color: Current text color (can change during animations)
  final TextProperties textProps;

  /// The text configuration containing font styling information.
  /// 
  /// **Styling Details:**
  /// - fontSize: Size in logical pixels
  /// - fontFamily: Font family name (null = system default)
  /// - isBold: Whether to use bold font weight
  /// - Provides textStyle getter that converts to Flutter TextStyle
  final TextConfig textConfig;

  /// Creates a new MovingTextWidget with the specified properties and configuration.
  /// 
  /// **Parameters:**
  /// - [key]: Widget key for Flutter's widget tree optimization
  /// - [textProps]: Position, content, and color data
  /// - [textConfig]: Font styling configuration
  /// 
  /// **Performance Note:**
  /// The key should include text content and styling information to ensure
  /// proper widget rebuilding when configuration changes.
  const MovingTextWidget({
    super.key,
    required this.textProps,
    required this.textConfig,
  });

  /// Builds the positioned text widget with current properties and styling.
  /// 
  /// **Rendering Process:**
  /// 1. Creates Positioned widget with coordinates from textProps
  /// 2. Creates Text widget with content from textProps
  /// 3. Applies base styling from textConfig
  /// 4. Overrides color with current color from textProps
  /// 5. Assigns performance-optimized ValueKey for efficient updates
  /// 
  /// **Performance Optimization:**
  /// The ValueKey includes text content and font configuration to ensure
  /// Flutter only rebuilds this widget when the visual output would actually
  /// change, minimizing unnecessary render operations during animation.
  /// 
  /// **Returns:** A Positioned widget containing styled text at the specified coordinates
  @override
  Widget build(BuildContext context) {
    return Positioned(
      // Use coordinates from text properties for absolute positioning
      left: textProps.x,
      top: textProps.y,
      child: Text(
        // Display the text content
        textProps.text,
        
        // Performance-optimized key to prevent unnecessary rebuilds
        // Includes text content and styling info to detect meaningful changes
        key: ValueKey('${textProps.text}-${textConfig.fontFamily}-${textConfig.fontSize}-${textConfig.isBold}'),
        
        // Apply styling from configuration with color override from properties
        style: textConfig.textStyle.copyWith(color: textProps.color),
      ),
    );
  }
}
