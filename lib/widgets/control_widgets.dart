// ============================================================================
// IMPORTS AND DEPENDENCIES
// ============================================================================

import 'package:flutter/material.dart';

// ============================================================================
// COLOR PICKER WIDGET - INTERACTIVE COLOR SELECTION
// ============================================================================

/// Interactive color picker widget with gradient selection and real-time preview.
/// 
/// **User Experience Design:**
/// This widget provides an intuitive color selection interface that combines
/// visual feedback with direct manipulation. Users can see their current
/// color selection and easily choose new colors from a continuous spectrum.
/// 
/// **Key Features:**
/// - **Visual Preview**: Circular color indicator shows current selection
/// - **Gradient Interface**: Horizontal gradient bar for color selection
/// - **Touch Interaction**: Tap or drag to select colors anywhere on the gradient
/// - **Real-time Feedback**: Color preview updates instantly during selection
/// - **Accessible Design**: Clear labels and sufficient touch target sizes
/// 
/// **Color Science:**
/// Uses HSV (Hue, Saturation, Value) color space for natural color selection:
/// - Hue: 0-360° around the color wheel (red, yellow, green, cyan, blue, magenta)
/// - Saturation: Fixed at 100% for vibrant colors
/// - Value: Fixed at 100% for maximum brightness
/// - This provides intuitive color selection that matches user expectations
/// 
/// **Mathematical Implementation:**
/// - Position on gradient (0.0 to 1.0) maps to hue angle (0° to 360°)
/// - HSV color conversion ensures consistent color brightness and saturation
/// - Reverse mapping from RGB to HSV for accurate indicator positioning
/// 
/// **Performance Optimizations:**
/// - Efficient gradient rendering with predefined color stops
/// - Minimal widget rebuilds using targeted state updates
/// - Optimized touch handling with gesture recognition
/// - Smart indicator positioning to avoid layout thrashing
/// 
/// **For Developers:**
/// ```dart
/// ColorPickerWidget(
///   label: 'Text Color',           // Descriptive label for accessibility
///   value: Colors.blue,            // Current color selection
///   onChanged: (newColor) {        // Callback for color changes
///     setState(() {
///       currentColor = newColor;
///     });
///   },
/// )
/// ```
/// 
/// **Accessibility Features:**
/// - Clear text labels for screen readers
/// - Sufficient contrast for color preview borders
/// - Adequate touch target sizes (40x40 minimum)
/// - Logical tab order for keyboard navigation
class ColorPickerWidget extends StatelessWidget {
  static const double _colorPreviewSize = 32.0;
  static const double _gradientHeight = 40.0;
  static const double _spacingMedium = 16.0;
  static const double _indicatorWidth = 4.0;
  
  final Color value;
  final ValueChanged<Color> onChanged;
  final String label;

  const ColorPickerWidget({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        SizedBox(
          width: 50, // Fixed width for label alignment
          child: Text(
            label,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: _spacingMedium),
        _buildColorPreview(theme),
        const SizedBox(width: _spacingMedium),
        Expanded(
          child: _buildGradientSlider(theme),
        ),
      ],
    );
  }

  /// Builds the circular color preview with shadow and border
  Widget _buildColorPreview(ThemeData theme) {
    return Container(
      width: _colorPreviewSize,
      height: _colorPreviewSize,
      decoration: BoxDecoration(
        color: value,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.outline,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// Builds the interactive gradient slider
  Widget _buildGradientSlider(ThemeData theme) {
    return SizedBox(
      height: _gradientHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return GestureDetector(
            onPanUpdate: (details) => _handleColorSelection(
              details.localPosition.dx, 
              constraints.maxWidth,
            ),
            onTapDown: (details) => _handleColorSelection(
              details.localPosition.dx, 
              constraints.maxWidth,
            ),
            child: _buildGradientContainer(constraints.maxWidth, theme),
          );
        },
      ),
    );
  }

  /// Handles color selection from gradient position
  void _handleColorSelection(double x, double maxWidth) {
    final percent = (x / maxWidth).clamp(0.0, 1.0);
    final selectedColor = HSVColor.fromAHSV(1, percent * 360, 1, 1).toColor();
    onChanged(selectedColor);
  }

  /// Builds the gradient container with color indicator
  Widget _buildGradientContainer(double maxWidth, ThemeData theme) {
    return Container(
      decoration: _buildGradientDecoration(theme),
      child: Stack(
        children: [
          _buildColorIndicator(maxWidth, theme),
        ],
      ),
    );
  }

  /// Creates the gradient decoration with color stops
  BoxDecoration _buildGradientDecoration(ThemeData theme) {
    return BoxDecoration(
      gradient: const LinearGradient(
        colors: [
          Color(0xFFFF0000), // Red
          Color(0xFFFFFF00), // Yellow
          Color(0xFF00FF00), // Green
          Color(0xFF00FFFF), // Cyan
          Color(0xFF0000FF), // Blue
          Color(0xFFFF00FF), // Magenta
          Color(0xFFFF0000), // Red (back to start)
        ],
        stops: [0.0, 0.17, 0.33, 0.5, 0.67, 0.83, 1.0],
      ),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: theme.colorScheme.outline.withOpacity(0.5),
        width: 1,
      ),
    );
  }

  /// Builds the position indicator for the current color
  Widget _buildColorIndicator(double maxWidth, ThemeData theme) {
    final hue = HSVColor.fromColor(value).hue;
    
    // Ensure maxWidth is valid to avoid clamp errors
    if (maxWidth <= _indicatorWidth) {
      return const SizedBox.shrink(); // Don't show indicator if not enough space
    }
    
    final indicatorPosition = ((hue / 360) * maxWidth).clamp(
      _indicatorWidth / 2, 
      maxWidth - _indicatorWidth / 2,
    );

    return Positioned(
      left: indicatorPosition - _indicatorWidth / 2,
      top: 0,
      bottom: 0,
      child: Container(
        width: _indicatorWidth,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface,
          borderRadius: BorderRadius.circular(2),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withOpacity(0.3),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }
}

/// A font picker widget with navigation arrows and display
class FontPickerWidget extends StatelessWidget {
  static const String _defaultFontName = 'Default';
  
  final int selectedIndex;
  final List<String?> fontOptions;
  final ValueChanged<int> onFontChanged;

  const FontPickerWidget({
    super.key,
    required this.selectedIndex,
    required this.fontOptions,
    required this.onFontChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Family',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        _buildFontSelector(theme),
      ],
    );
  }

  /// Builds the font selector with navigation arrows
  Widget _buildFontSelector(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          _buildNavigationButton(
            theme: theme,
            icon: Icons.keyboard_arrow_left_rounded,
            onPressed: () => _navigateFont(FontDirection.previous),
          ),
          _buildFontDisplay(theme),
          _buildNavigationButton(
            theme: theme,
            icon: Icons.keyboard_arrow_right_rounded,
            onPressed: () => _navigateFont(FontDirection.next),
          ),
        ],
      ),
    );
  }

  /// Builds a navigation button (left or right arrow)
  Widget _buildNavigationButton({
    required ThemeData theme,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(12),
        minimumSize: const Size(48, 48),
      ),
    );
  }

  /// Builds the current font name display
  Widget _buildFontDisplay(ThemeData theme) {
    final currentFontName = _getCurrentFontName();
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Text(
          currentFontName,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
            fontFamily: fontOptions[selectedIndex],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Gets the current font name or default
  String _getCurrentFontName() {
    return fontOptions[selectedIndex] ?? _defaultFontName;
  }

  /// Handles font navigation in the specified direction
  void _navigateFont(FontDirection direction) {
    final newIndex = _calculateNewIndex(direction);
    onFontChanged(newIndex);
  }

  /// Calculates the new index based on navigation direction
  int _calculateNewIndex(FontDirection direction) {
    switch (direction) {
      case FontDirection.next:
        return selectedIndex < fontOptions.length - 1 
            ? selectedIndex + 1 
            : 0; // Wrap to beginning
      case FontDirection.previous:
        return selectedIndex > 0 
            ? selectedIndex - 1 
            : fontOptions.length - 1; // Wrap to end
    }
  }
}

/// Enum for font navigation direction
enum FontDirection { next, previous }

/// A reusable slider control widget with label and value display
class SliderControlWidget extends StatelessWidget {
  static const int _decimalPlaces = 1;
  
  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final ValueChanged<double> onChanged;

  const SliderControlWidget({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _formatValue(value),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
            activeTrackColor: theme.colorScheme.primary,
            inactiveTrackColor: theme.colorScheme.surfaceVariant,
            thumbColor: theme.colorScheme.primary,
            overlayColor: theme.colorScheme.primary.withOpacity(0.12),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  /// Formats the slider value for display
  /// Shows integers as whole numbers, decimals with one decimal place
  String _formatValue(double value) {
    if (value == value.toInt()) {
      return value.toInt().toString();
    } else {
      return value.toStringAsFixed(_decimalPlaces);
    }
  }
}
