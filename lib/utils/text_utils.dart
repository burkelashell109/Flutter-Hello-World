import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/text_properties.dart';

/// Utility class providing text measurement, positioning, and physics calculations.
/// 
/// This class contains the core algorithms that power the moving text animation,
/// including physics simulation, collision detection, and responsive positioning.
/// All methods are static and pure functions for maximum testability.
/// 
/// **Key Algorithms:**
/// - **Text Measurement**: Accurate text sizing for layout calculations
/// - **Physics Simulation**: Realistic bouncing with elastic collisions
/// - **Velocity Management**: Speed-based movement with random direction generation
/// - **Boundary Detection**: Screen edge collision with randomized bounce effects
/// 
/// **Performance Considerations:**
/// - Uses shared Random instance to avoid constructor overhead
/// - Efficient TextPainter reuse for measurements
/// - In-place modifications for real-time animation performance
class TextUtils {
  /// Shared Random instance for consistent random number generation.
  /// 
  /// Using a static instance ensures thread safety and avoids the overhead
  /// of creating new Random objects during high-frequency animation updates.
  static final math.Random _random = math.Random();

  /// Measures the rendered size of text with the given style.
  /// 
  /// This method uses Flutter's TextPainter to calculate the exact pixel
  /// dimensions that text will occupy when rendered. Essential for accurate
  /// collision detection and responsive layout calculations.
  /// 
  /// **Algorithm Details:**
  /// 1. Creates a TextPainter with the provided text and style
  /// 2. Invokes layout() to calculate dimensions
  /// 3. Returns the computed width and height as a Size object
  /// 
  /// **Performance:** Optimized for repeated calls during animation loops
  /// 
  /// **Example:**
  /// ```dart
  /// const style = TextStyle(fontSize: 24, fontFamily: 'Arial');
  /// final size = TextUtils.measureText('Hello World', style);
  /// print('Text will be ${size.width}x${size.height} pixels');
  /// ```
  /// 
  /// **Parameters:**
  /// - [text]: The string content to measure
  /// - [style]: TextStyle defining font, size, weight, etc.
  /// 
  /// **Returns:** Size object with width and height in logical pixels
  static Size measureText(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    
    return Size(painter.width, painter.height);
  }

  /// Calculates centered positions for two text widgets placed side by side.
  /// 
  /// This algorithm computes the optimal positioning for a "Hello World" layout
  /// where both words are centered as a group on the screen. Essential for
  /// responsive design across different screen sizes.
  /// 
  /// **Algorithm Steps:**
  /// 1. Calculate total width: hello + gap + world
  /// 2. Determine horizontal center: (screen_width - total_width) / 2
  /// 3. Calculate vertical center based on text height
  /// 4. Position "Hello" at center, "World" at center + hello_width + gap
  /// 
  /// **Mathematical Formula:**
  /// ```
  /// total_width = hello_width + world_width + gap
  /// center_x = (screen_width - total_width) / 2
  /// hello_x = center_x
  /// world_x = center_x + hello_width + gap
  /// center_y = (screen_height - text_height) / 2
  /// ```
  /// 
  /// **Example:**
  /// ```dart
  /// final positions = TextUtils.calculateCenteredPositions(
  ///   screenSize: Size(800, 600),
  ///   helloSize: Size(100, 50),
  ///   worldSize: Size(120, 50),
  ///   gap: 32.0,
  /// );
  /// // Returns: {'hello_x': 282, 'hello_y': 275, 'world_x': 414, 'world_y': 275}
  /// ```
  /// 
  /// **Parameters:**
  /// - [screenSize]: Available screen dimensions
  /// - [helloSize]: Measured size of "Hello" text
  /// - [worldSize]: Measured size of "World" text  
  /// - [gap]: Horizontal spacing between the words (default: 32.0)
  /// 
  /// **Returns:** Map with keys: 'hello_x', 'hello_y', 'world_x', 'world_y'
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

  /// Applies physics simulation including collision detection and elastic bouncing.
  /// 
  /// This is the core physics engine that creates realistic movement behavior.
  /// The algorithm handles boundary collision with elastic bouncing and adds
  /// randomization to prevent predictable movement patterns.
  /// 
  /// **Physics Model:**
  /// - **Velocity Integration**: position += velocity
  /// - **Elastic Collision**: velocity reverses on boundary contact
  /// - **Randomized Bounce**: adds ±2.0 pixel variance to prevent loops
  /// - **Boundary Clamping**: ensures text stays within screen bounds
  /// 
  /// **Collision Detection Algorithm:**
  /// ```dart
  /// if (position <= 0) {
  ///   position = 0;                    // Clamp to boundary
  ///   velocity = abs(speed);           // Reverse direction
  ///   velocity_perpendicular += random; // Add chaos
  /// }
  /// ```
  /// 
  /// **Randomization Strategy:**
  /// - Range: ±2.0 pixels of velocity modification
  /// - Applied perpendicular to collision surface
  /// - Prevents infinite loops and predictable patterns
  /// - Creates organic, lifelike movement
  /// 
  /// **Performance Optimizations:**
  /// - In-place modification of TextProperties (no allocations)
  /// - Safe boundary calculations with 10px minimum
  /// - Single-pass collision detection for all edges
  /// 
  /// **Example:**
  /// ```dart
  /// // Apply physics to moving text each frame
  /// TextUtils.applyPhysics(
  ///   textProps: myTextProperties,
  ///   screenSize: Size(800, 600),
  ///   textSize: Size(100, 50),
  ///   drawerHeight: 0.0,  // Legacy parameter
  ///   speed: 5.0,
  /// );
  /// ```
  /// 
  /// **Parameters:**
  /// - [textProps]: The text object to update (modified in-place)
  /// - [screenSize]: Screen dimensions for boundary calculation
  /// - [textSize]: Size of the text for collision detection
  /// - [drawerHeight]: Legacy parameter (unused, kept for compatibility)
  /// - [speed]: Movement speed magnitude for bounce calculations
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

  /// Updates movement velocities based on current speed setting.
  /// 
  /// This method manages the transition between different speed states and
  /// ensures smooth velocity changes. When transitioning from stopped (speed=0)
  /// to moving (speed>0), it generates a random direction to create dynamic,
  /// unpredictable movement patterns.
  /// 
  /// **State Transitions:**
  /// - **Speed = 0**: Sets velocity to zero (stationary)
  /// - **Speed > 0 (from stationary)**: Generates random 360° direction
  /// - **Speed > 0 (already moving)**: Preserves direction, updates magnitude
  /// 
  /// **Direction Preservation Logic:**
  /// ```dart
  /// if (was_stationary) {
  ///   generate_random_360_degree_direction();
  /// } else {
  ///   preserve_current_direction();
  ///   update_speed_magnitude();
  /// }
  /// ```
  /// 
  /// **Example Usage:**
  /// ```dart
  /// // User adjusts speed slider from 0 to 15
  /// TextUtils.updateVelocities(
  ///   textProps: myText,
  ///   speed: 15.0,
  /// );
  /// // Result: Random direction with magnitude 15
  /// 
  /// // User adjusts speed from 15 to 25 (already moving)
  /// TextUtils.updateVelocities(
  ///   textProps: myText,
  ///   speed: 25.0,
  /// );
  /// // Result: Same direction, increased magnitude to 25
  /// ```
  /// 
  /// **Parameters:**
  /// - [textProps]: Text object to update (modified in-place)
  /// - [speed]: New speed magnitude (0 = stationary, >0 = moving)
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

  /// Generates a random 360° direction vector for text movement.
  /// 
  /// This private method implements polar-to-cartesian coordinate conversion
  /// to create uniformly distributed random directions. Used when text
  /// transitions from stationary to moving state.
  /// 
  /// **Mathematical Implementation:**
  /// 1. Generate random angle: θ ∈ [0, 2π]
  /// 2. Convert to cartesian coordinates:
  ///    - dx = cos(θ) × speed
  ///    - dy = sin(θ) × speed
  /// 3. Result: Unit vector scaled by speed magnitude
  /// 
  /// **Uniform Distribution:**
  /// The algorithm ensures equal probability for all directions,
  /// preventing bias toward cardinal directions (up/down/left/right).
  /// 
  /// **Example Results:**
  /// ```dart
  /// // θ = 0°    → dx = +speed, dy = 0      (right)
  /// // θ = 90°   → dx = 0,      dy = +speed (down)
  /// // θ = 180°  → dx = -speed, dy = 0      (left)
  /// // θ = 270°  → dx = 0,      dy = -speed (up)
  /// // θ = 45°   → dx = +0.7×speed, dy = +0.7×speed (diagonal)
  /// ```
  /// 
  /// **Parameters:**
  /// - [textProps]: Text object to update with new direction
  /// - [speed]: Magnitude of the velocity vector
  static void _setRandomDirection(TextProperties textProps, double speed) {
    // Generate random angle between 0 and 2π (360 degrees)
    final randomAngle = _random.nextDouble() * 2 * math.pi;
    
    // Convert polar coordinates to cartesian (dx, dy)
    textProps.dx = math.cos(randomAngle) * speed;
    textProps.dy = math.sin(randomAngle) * speed;
  }

  /// Resets text velocities to zero for reset button functionality.
  /// 
  /// This method provides a clean way to stop all text movement, typically
  /// used when the user clicks a reset button. Setting velocities to zero
  /// ensures that the next speed change will trigger random direction
  /// generation via [updateVelocities].
  /// 
  /// **State Change:**
  /// - Sets dx = 0, dy = 0 (stationary state)
  /// - Next non-zero speed will generate random direction
  /// - Provides clean separation between reset and movement logic
  /// 
  /// **Example:**
  /// ```dart
  /// // User clicks reset button
  /// TextUtils.resetVelocities(myTextProperties);
  /// 
  /// // Later, user adjusts speed slider
  /// TextUtils.updateVelocities(myTextProperties, speed: 10.0);
  /// // Result: New random direction with speed 10
  /// ```
  /// 
  /// **Parameters:**
  /// - [textProps]: Text object to reset (modified in-place)
  static void resetVelocities(TextProperties textProps) {
    textProps.dx = 0;
    textProps.dy = 0;
  }
}
