import 'package:flutter/material.dart';
import 'control_widgets.dart';

// ============================================================================
// CONFIGURATION CLASSES
// ============================================================================

/// Configuration constants for the control panel
class ControlPanelConfig {
  static const List<String?> fontOptions = [
    null, // Default system font
    'Arial',
    'Comic',
    'Trebuchet',
    'Times',
    'Ariblk',
    'monospace',
    'serif',
    'sans-serif',
  ];

  static const double minSpeed = 0.0;
  static const double maxSpeed = 25.0;
  static const double minFontSize = 12.0;
  static const double maxFontSize = 144.0;
}

/// Callbacks for control panel interactions
class ControlPanelCallbacks {
  final ValueChanged<double>? onSpeedChanged;
  final ValueChanged<double>? onFontSizeChanged;
  final ValueChanged<Color>? onHelloColorChanged;
  final ValueChanged<Color>? onWorldColorChanged;
  final ValueChanged<int>? onFontChanged;
  final ValueChanged<bool>? onBoldChanged;
  final VoidCallback? onToggleDrawer;
  final VoidCallback? onReset;

  const ControlPanelCallbacks({
    this.onSpeedChanged,
    this.onFontSizeChanged,
    this.onHelloColorChanged,
    this.onWorldColorChanged,
    this.onFontChanged,
    this.onBoldChanged,
    this.onToggleDrawer,
    this.onReset,
  });
}

/// Current state of all controls
class ControlPanelState {
  final double speed;
  final double fontSize;
  final Color helloColor;
  final Color worldColor;
  final int selectedFontIndex;
  final bool isBold;
  final double drawerSize;

  const ControlPanelState({
    required this.speed,
    required this.fontSize,
    required this.helloColor,
    required this.worldColor,
    required this.selectedFontIndex,
    required this.isBold,
    required this.drawerSize,
  });
}

// ============================================================================
// MAIN CONTROL PANEL WIDGET
// ============================================================================

/// Main control panel widget for text animation settings
class ControlPanelWidget extends StatelessWidget {
  final ControlPanelState state;
  final ControlPanelCallbacks callbacks;
  final ScrollController scrollController;

  const ControlPanelWidget({
    super.key,
    required this.state,
    required this.callbacks,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.85), // 85% opacity background
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildBottomSheetHandle(theme),
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: Column(
                children: [
                  _buildBottomSheetHeader(theme),
                  const SizedBox(height: 24),
                  _buildSliderControls(),
                  const SizedBox(height: 24),
                  _buildFontControls(),
                  const SizedBox(height: 20),
                  _buildBoldnessControl(theme),
                  const SizedBox(height: 24),
                  _buildColorControls(),
                  const SizedBox(height: 32),
                  _buildResetButton(theme),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================================
  // PRIVATE WIDGET BUILDERS
  // ============================================================================

  Widget _buildBottomSheetHandle(ThemeData theme) {
    return Container(
      width: 32,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildBottomSheetHeader(ThemeData theme) {
    final isExpanded = state.drawerSize > 0.15;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Controls',
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        FilledButton.tonalIcon(
          onPressed: callbacks.onToggleDrawer,
          icon: Icon(
            isExpanded 
                ? Icons.expand_more_rounded 
                : Icons.expand_less_rounded,
          ),
          label: Text(isExpanded ? 'Collapse' : 'Expand'),
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderControls() {
    return Column(
      children: [
        SliderControlWidget(
          label: 'Speed',
          value: state.speed,
          min: ControlPanelConfig.minSpeed,
          max: ControlPanelConfig.maxSpeed,
          divisions: 25, // 0 to 25 in integer steps
          onChanged: callbacks.onSpeedChanged ?? (_) {},
        ),
        SliderControlWidget(
          label: 'Size',
          value: state.fontSize,
          min: ControlPanelConfig.minFontSize,
          max: ControlPanelConfig.maxFontSize,
          divisions: 132, // 12 to 144 in integer steps
          onChanged: callbacks.onFontSizeChanged ?? (_) {},
        ),
      ],
    );
  }

  Widget _buildFontControls() {
    return FontPickerWidget(
      selectedIndex: state.selectedFontIndex,
      fontOptions: ControlPanelConfig.fontOptions,
      onFontChanged: callbacks.onFontChanged ?? (_) {},
    );
  }

  Widget _buildBoldnessControl(ThemeData theme) {
    return Row(
      children: [
        Text(
          'Bold Text',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Switch(
          value: state.isBold,
          onChanged: (value) => callbacks.onBoldChanged?.call(value),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }

  Widget _buildColorControls() {
    return Column(
      children: [
        ColorPickerWidget(
          label: 'Hello',
          value: state.helloColor,
          onChanged: callbacks.onHelloColorChanged ?? (_) {},
        ),
        const SizedBox(height: 16), // Increased spacing between color pickers
        ColorPickerWidget(
          label: 'World!',
          value: state.worldColor,
          onChanged: callbacks.onWorldColorChanged ?? (_) {},
        ),
      ],
    );
  }

  Widget _buildResetButton(ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: 0.5,
        child: FilledButton.tonal(
          onPressed: callbacks.onReset,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(
            'Reset',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSecondaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
