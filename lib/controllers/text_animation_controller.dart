import 'package:flutter/material.dart';
import '../models/text_properties.dart';
import '../utils/text_utils.dart';

/// Controller for managing text animation and movement with physics simulation
/// 
/// This controller handles:
/// - Text positioning and movement with customizable speed
/// - Physics-based collision detection and bouncing
/// - Smooth reset animations back to center position
/// - Font configuration changes with live updates
/// - Color transitions for individual text elements
class TextAnimationController {
  // ============================================================================
  // CORE PROPERTIES AND INITIALIZATION
  // ============================================================================
  
  final TickerProvider vsync;
  late AnimationController _controller;
  
  // State management
  final List<TextProperties> _textWidgets = [];
  TextConfig _textConfig = const TextConfig(fontSize: 72, isBold: false);
  double _speed = 0.0;
  bool _isInitialized = false;
  
  // Callbacks
  VoidCallback? onUpdate;
  
  /// Creates a new TextAnimationController with 60fps animation loop
  TextAnimationController({required this.vsync}) {
    _initializeController();
  }

  // ============================================================================
  // PUBLIC GETTERS
  // ============================================================================
  
  /// Returns the list of text widgets being animated
  List<TextProperties> get textWidgets => _textWidgets;
  
  /// Returns the current text configuration (font size, family, boldness)
  TextConfig get textConfig => _textConfig;
  
  /// Returns the current animation speed
  double get speed => _speed;
  
  /// Returns whether the controller has been initialized with text widgets
  bool get isInitialized => _isInitialized;

  // ============================================================================
  // INITIALIZATION AND SETUP
  // ============================================================================

  /// Sets up the internal AnimationController with 60fps timing
  void _initializeController() {
    _controller = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 16),
    )..addListener(_onAnimationFrame)
     ..repeat();
  }

  /// Initialize text widgets with given properties
  /// @param widgets List of TextProperties containing position, velocity, and display data
  void initializeTextWidgets(List<TextProperties> widgets) {
    _textWidgets.clear();
    _textWidgets.addAll(widgets);
    _isInitialized = true;
  }

  // ============================================================================
  // CONFIGURATION UPDATES
  // ============================================================================

  /// Update text configuration and trigger UI refresh
  /// @param newConfig TextConfig containing font styling information
  void updateTextConfig(TextConfig newConfig) {
    _textConfig = newConfig;
    _triggerUIUpdate();
  }

  /// Update text configuration without triggering UI update
  /// Used during animations to avoid interfering with smooth transitions
  /// @param newConfig TextConfig containing font styling information
  void updateTextConfigSilent(TextConfig newConfig) {
    _textConfig = newConfig;
  }

  /// Update animation speed for all text widgets
  /// @param newSpeed New speed value (0 stops movement, positive values increase speed)
  void updateSpeed(double newSpeed) {
    _speed = newSpeed;
    _updateAllVelocities(newSpeed);
    _triggerUIUpdate();
  }

  // ============================================================================
  // COLOR MANAGEMENT
  // ============================================================================

  /// Update color for a specific text widget with UI refresh
  /// @param index Index of the text widget to update (0-based)
  /// @param color New color to apply to the text widget
  void updateTextColor(int index, Color color) {
    if (_isValidIndex(index)) {
      _textWidgets[index].color = color;
      _triggerUIUpdate();
    }
  }

  /// Update color for a specific text widget without triggering UI update
  /// Used during animations to avoid interfering with smooth transitions
  /// @param index Index of the text widget to update (0-based)
  /// @param color New color to apply to the text widget
  void updateTextColorSilent(int index, Color color) {
    if (_isValidIndex(index)) {
      _textWidgets[index].color = color;
    }
  }

  // ============================================================================
  // PHYSICS AND MOVEMENT
  // ============================================================================

  /// Apply physics simulation to all text widgets
  /// Handles boundary collision detection and response
  /// @param screenSize Current screen dimensions
  /// @param drawerHeight Height of the control drawer at bottom of screen
  void applyPhysics({
    required Size screenSize,
    required double drawerHeight,
  }) {
    if (!_canApplyPhysics(screenSize)) return;
    
    for (final widget in _textWidgets) {
      final textSize = _measureTextSize(widget.text);
      if (_isValidTextSize(textSize)) {
        _applyPhysicsToWidget(widget, screenSize, textSize, drawerHeight);
      }
    }
  }

  /// Called every animation frame to update positions
  void _onAnimationFrame() {
    if (!_shouldUpdatePositions()) return;
    _triggerUIUpdate();
  }

  // ============================================================================
  // RESET ANIMATIONS
  // ============================================================================

  /// Reset text positions to center with immediate positioning
  /// @param screenSize Size of the screen to calculate center positions
  void resetToCenter({required Size screenSize}) {
    _stopMovement();
    _resetAllVelocities();
    _positionTextAtCenter(screenSize);
    _triggerUIUpdate();
  }

  /// Smoothly animate text widgets back to center with color transitions
  /// @param screenSize Current screen size for calculating center positions
  /// @param progress Animation progress from 0.0 to 1.0
  /// @param startPositions Original positions when reset started
  /// @param startColors Original colors when reset started
  /// @param targetFontSize Optional target font size for the animation
  void animateToCenter({
    required Size screenSize,
    required double progress,
    required List<Map<String, double>> startPositions,
    required List<Color> startColors,
    double? targetFontSize,
  }) {
    if (!_canAnimate()) return;
    
    final targetPositions = _calculateTargetPositions(screenSize, targetFontSize);
    _interpolatePositionsAndColors(progress, startPositions, startColors, targetPositions);
    _updateFontSizeIfProvided(targetFontSize);
    _triggerUIUpdate();
  }

  /// Lock text positions at their current locations to prevent recalculation
  /// @param screenSize Current screen size (kept for API compatibility)
  void lockPositions({required Size screenSize}) {
    if (!_canAnimate()) return;
    _lockAllVelocities();
    // Note: Don't call _triggerUIUpdate() to prevent repositioning
  }

  // ============================================================================
  // PRIVATE HELPER METHODS - VALIDATION
  // ============================================================================

  bool _isValidIndex(int index) => index >= 0 && index < _textWidgets.length;
  
  bool _canApplyPhysics(Size screenSize) => 
      _isInitialized && screenSize.width > 0 && screenSize.height > 0;
  
  bool _isValidTextSize(Size textSize) => 
      textSize.width > 0 && textSize.height > 0;
  
  bool _shouldUpdatePositions() => _isInitialized && _speed > 0;
  
  bool _canAnimate() => _isInitialized && _textWidgets.isNotEmpty;

  // ============================================================================
  // PRIVATE HELPER METHODS - TEXT MEASUREMENT AND POSITIONING
  // ============================================================================

  Size _measureTextSize(String text) => 
      TextUtils.measureText(text, _textConfig.textStyle);

  Map<String, double> _calculateTargetPositions(Size screenSize, double? targetFontSize) {
    final fontSize = targetFontSize ?? _textConfig.fontSize;
    final targetTextConfig = TextConfig(
      fontSize: fontSize,
      fontFamily: _textConfig.fontFamily,
      isBold: _textConfig.isBold,
    );
    
    final helloSize = TextUtils.measureText('Hello', targetTextConfig.textStyle);
    final worldSize = TextUtils.measureText('World!', targetTextConfig.textStyle);
    
    return TextUtils.calculateCenteredPositions(
      screenSize: screenSize,
      helloSize: helloSize,
      worldSize: worldSize,
    );
  }

  void _positionTextAtCenter(Size screenSize) {
    if (_textWidgets.isEmpty) return;
    
    final positions = _calculateTargetPositions(screenSize, null);
    
    if (_textWidgets.length >= 2) {
      _textWidgets[0].x = positions['hello_x']!;
      _textWidgets[0].y = positions['hello_y']!;
      _textWidgets[1].x = positions['world_x']!;
      _textWidgets[1].y = positions['world_y']!;
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS - VELOCITY AND MOVEMENT
  // ============================================================================

  void _updateAllVelocities(double speed) {
    for (final widget in _textWidgets) {
      TextUtils.updateVelocities(textProps: widget, speed: speed);
    }
  }

  void _resetAllVelocities() {
    for (final widget in _textWidgets) {
      TextUtils.resetVelocities(widget);
    }
  }

  void _lockAllVelocities() {
    for (final widget in _textWidgets) {
      widget.dx = 0;
      widget.dy = 0;
    }
  }

  void _stopMovement() {
    _speed = 0.0;
  }

  void _applyPhysicsToWidget(
    TextProperties widget,
    Size screenSize,
    Size textSize,
    double drawerHeight,
  ) {
    TextUtils.applyPhysics(
      textProps: widget,
      screenSize: screenSize,
      textSize: textSize,
      drawerHeight: drawerHeight,
      speed: _speed,
    );
  }

  // ============================================================================
  // PRIVATE HELPER METHODS - ANIMATION INTERPOLATION
  // ============================================================================

  void _interpolatePositionsAndColors(
    double progress,
    List<Map<String, double>> startPositions,
    List<Color> startColors,
    Map<String, double> targetPositions,
  ) {
    const targetColors = [Colors.red, Colors.blue];
    
    for (int i = 0; i < _textWidgets.length && i < startPositions.length; i++) {
      final widget = _textWidgets[i];
      final startPos = startPositions[i];
      
      _interpolatePosition(widget, startPos, targetPositions, progress, i);
      _interpolateColor(widget, startColors, targetColors, progress, i);
      _resetWidgetVelocity(widget);
    }
  }

  void _interpolatePosition(
    TextProperties widget,
    Map<String, double> startPos,
    Map<String, double> targetPositions,
    double progress,
    int index,
  ) {
    final targetX = index == 0 ? targetPositions['hello_x']! : targetPositions['world_x']!;
    final targetY = index == 0 ? targetPositions['hello_y']! : targetPositions['world_y']!;
    
    widget.x = startPos['x']! + (targetX - startPos['x']!) * progress;
    widget.y = startPos['y']! + (targetY - startPos['y']!) * progress;
  }

  void _interpolateColor(
    TextProperties widget,
    List<Color> startColors,
    List<Color> targetColors,
    double progress,
    int index,
  ) {
    if (index < startColors.length && index < targetColors.length) {
      widget.color = Color.lerp(startColors[index], targetColors[index], progress) 
          ?? targetColors[index];
    }
  }

  void _resetWidgetVelocity(TextProperties widget) {
    widget.dx = 0;
    widget.dy = 0;
  }

  void _updateFontSizeIfProvided(double? targetFontSize) {
    if (targetFontSize != null) {
      _textConfig = TextConfig(
        fontSize: targetFontSize,
        fontFamily: _textConfig.fontFamily,
        isBold: _textConfig.isBold,
      );
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS - UI UPDATES
  // ============================================================================

  void _triggerUIUpdate() {
    onUpdate?.call();
  }

  // ============================================================================
  // CLEANUP
  // ============================================================================

  /// Disposes of the internal AnimationController to prevent memory leaks
  void dispose() {
    _controller.dispose();
  }
}
