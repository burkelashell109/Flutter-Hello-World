# API Documentation

## Overview

This document provides a comprehensive reference for the public APIs and interfaces in the Hello World Flutter project. The architecture follows clean separation of concerns with well-defined contracts between layers.

---

## Public APIs by Layer

### 📊 Models Layer (`lib/models/`)

#### TextProperties
Represents a moving text element with physics properties.

```dart
class TextProperties {
  double x, y;           // Current position (mutable)
  double dx, dy;         // Velocity components (mutable)  
  final String text;     // Text content (immutable)
  Color color;           // Display color (mutable)
  
  TextProperties({required x, y, dx, dy, text, color});
  TextProperties copyWith({x, y, dx, dy, text, color});
}
```

**Usage Example:**
```dart
final textProps = TextProperties(
  x: 100.0, y: 200.0, dx: 1.5, dy: -2.0,
  text: 'Hello', color: Colors.blue,
);

// Update during animation
textProps.x += textProps.dx;
textProps.y += textProps.dy;
```

#### TextConfig
Immutable configuration for text styling.

```dart
class TextConfig {
  final double fontSize;      // Font size in logical pixels
  final String? fontFamily;   // Font family (null = system default)
  final bool isBold;         // Bold font weight flag
  
  const TextConfig({required fontSize, fontFamily, required isBold});
  TextStyle get textStyle;   // Converts to Flutter TextStyle
  TextConfig copyWith({fontSize, fontFamily, isBold});
}
```

**Usage Example:**
```dart
const config = TextConfig(fontSize: 24.0, fontFamily: 'Arial', isBold: true);
Text('Hello', style: config.textStyle);
```

---

### 🔧 Utils Layer (`lib/utils/`)

#### TextUtils
Static utility class for calculations and physics.

```dart
class TextUtils {
  // Text measurement
  static Size measureText(String text, TextStyle style);
  
  // Layout calculations  
  static Map<String, double> calculateCenteredPositions({
    required Size screenSize,
    required Size helloSize, 
    required Size worldSize,
    double gap = 32.0,
  });
  
  // Physics simulation
  static void applyPhysics({
    required TextProperties textProps,
    required Size screenSize,
    required Size textSize,
    required double drawerHeight,
    required double speed,
  });
  
  // Velocity management
  static void updateVelocities({
    required TextProperties textProps,
    required double speed,
  });
  
  static void resetVelocities(TextProperties textProps);
}
```

**Key Algorithms:**

**Text Measurement:**
```dart
// Accurate pixel-perfect text sizing
final size = TextUtils.measureText('Hello World', textStyle);
// Returns: Size(width: 120.5, height: 24.0)
```

**Physics Simulation:**
```dart
// Apply realistic bouncing physics each frame
TextUtils.applyPhysics(
  textProps: myText,
  screenSize: Size(800, 600),
  textSize: Size(100, 50), 
  drawerHeight: 0.0,
  speed: 5.0,
);
```

**Centered Positioning:**
```dart
// Calculate positions for side-by-side text
final positions = TextUtils.calculateCenteredPositions(
  screenSize: Size(800, 600),
  helloSize: Size(100, 50),
  worldSize: Size(120, 50),
  gap: 32.0,
);
// Returns: {'hello_x': 274, 'hello_y': 275, 'world_x': 406, 'world_y': 275}
```

---

### 🎮 Controllers Layer (`lib/controllers/`)

#### TextAnimationController
Manages animation state and coordinates between UI and physics.

```dart
class TextAnimationController {
  TextAnimationController({required TickerProvider vsync});
  
  // Public getters
  List<TextProperties> get textWidgets;
  TextConfig get textConfig;
  double get speed;
  bool get isInitialized;
  
  // Lifecycle management
  void dispose();
  
  // Configuration updates
  void updateSpeed(double newSpeed);
  void updateTextConfig(TextConfig newConfig);
  void updateColors({Color? helloColor, Color? worldColor});
  
  // Animation control
  void resetToCenter(Size screenSize);
  void initializeTextWidgets({
    required Size screenSize,
    required String helloText,
    required String worldText, 
    required Color helloColor,
    required Color worldColor,
  });
  
  // Callbacks
  VoidCallback? onUpdate;  // Called on each animation frame
}
```

**Usage Example:**
```dart
// Initialize controller
final controller = TextAnimationController(vsync: this);
controller.onUpdate = () => setState(() {});

// Setup text widgets
controller.initializeTextWidgets(
  screenSize: MediaQuery.of(context).size,
  helloText: 'Hello',
  worldText: 'World',
  helloColor: Colors.red,
  worldColor: Colors.blue,
);

// Update speed in real-time
controller.updateSpeed(15.0);
```

---

### 🎨 Widgets Layer (`lib/widgets/`)

#### ControlPanelWidget
Main control interface with sliders, pickers, and buttons.

```dart
class ControlPanelWidget extends StatelessWidget {
  const ControlPanelWidget({
    super.key,
    required this.state,
    required this.callbacks,
    required this.scrollController,
  });
  
  final ControlPanelState state;
  final ControlPanelCallbacks callbacks;
  final ScrollController scrollController;
}
```

#### ControlPanelState
Immutable state class for control panel configuration.

```dart
class ControlPanelState {
  final double speed;              // Animation speed (0-25)
  final double fontSize;           // Text size (12-144)
  final Color helloColor;          // "Hello" text color
  final Color worldColor;          // "World" text color  
  final int selectedFontIndex;     // Index in font options array
  final bool isBold;               // Bold text toggle
  final double drawerSize;         // Control panel size (0.0-1.0)
  
  const ControlPanelState({...});
  ControlPanelState copyWith({...});
}
```

#### ControlPanelCallbacks
Callback interface for control panel interactions.

```dart
class ControlPanelCallbacks {
  final ValueChanged<double>? onSpeedChanged;
  final ValueChanged<double>? onFontSizeChanged;
  final ValueChanged<Color>? onHelloColorChanged;
  final ValueChanged<Color>? onWorldColorChanged;
  final ValueChanged<int>? onFontChanged;
  final ValueChanged<bool>? onBoldChanged;
  final VoidCallback? onToggleDrawer;
  final VoidCallback? onReset;
  
  const ControlPanelCallbacks({...});
}
```

#### MovingTextWidget
Renders individual positioned text elements.

```dart
class MovingTextWidget extends StatelessWidget {
  const MovingTextWidget({
    super.key,
    required this.textProperties,
    required this.textConfig,
  });
  
  final TextProperties textProperties;
  final TextConfig textConfig;
}
```

---

## Configuration Constants

### ControlPanelConfig
Static configuration values for UI controls.

```dart
class ControlPanelConfig {
  static const List<String?> fontOptions = [
    null, 'Arial', 'Comic', 'Trebuchet', 'Times', 
    'Ariblk', 'monospace', 'serif', 'sans-serif',
  ];
  
  static const double minSpeed = 0.0;
  static const double maxSpeed = 25.0;
  static const double minFontSize = 12.0;
  static const double maxFontSize = 144.0;
}
```

---

## Data Flow Architecture

### State Management Flow
```
User Input → ControlPanelCallbacks → Main App State → Controller Updates → UI Rebuild
     ↑                                      ↓
     └── UI Components ←── Animation Loop ←──┘
```

### Animation Loop Flow
```
TextAnimationController.onUpdate()
         ↓
    Update Physics (60fps)
         ↓  
    TextUtils.applyPhysics()
         ↓
    Modify TextProperties
         ↓
    Trigger UI Rebuild
         ↓
    Render New Positions
```

### Event Handling Flow
```
User Slider Change → onSpeedChanged callback → _handleSpeedChange() 
                                                     ↓
                                            Update ControlPanelState
                                                     ↓  
                                            controller.updateSpeed()
                                                     ↓
                                            TextUtils.updateVelocities()
```

---

## Error Handling Patterns

### Defensive Programming
```dart
// Boundary safety checks
if (size.width <= 0 || size.height <= 0) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted && !_isInitialized) {
      _initializeTextPositions();
    }
  });
  return;
}
```

### Null Safety
```dart
// Optional callback pattern
callbacks.onSpeedChanged?.call(newSpeed);

// Null-aware font family
fontFamily: fontFamily ?? 'system-default',
```

### Resource Management
```dart
@override
void dispose() {
  _animationController.dispose();
  _resetAnimationController.dispose();
  _sheetController.dispose();
  super.dispose();
}
```

---

## Testing APIs

### Test Utilities
```dart
// Standard test fixtures
const testScreenSize = Size(800, 600);
const testTextProps = TextProperties(
  x: 100, y: 200, dx: 1.5, dy: -2.0,
  text: 'Test', color: Colors.blue,
);
```

### Widget Testing Patterns
```dart
testWidgets('should render control panel', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: ControlPanelWidget(
      state: testState,
      callbacks: testCallbacks,
      scrollController: ScrollController(),
    ),
  ));
  
  expect(find.byType(ControlPanelWidget), findsOneWidget);
});
```

---

## Performance Considerations

### Animation Optimization
- **60fps Target**: All animations designed for 16.67ms frame time
- **In-place Updates**: TextProperties modified directly (no allocations)
- **Efficient Rebuilds**: Targeted setState calls minimize widget tree updates

### Memory Management
- **Static Utils**: No instance allocation for utility functions
- **Shared Random**: Single Random instance prevents constructor overhead
- **Proper Disposal**: All controllers and resources cleaned up correctly

### Responsive Design
- **Text Measurement**: Cached where possible, recalculated on font changes
- **Layout Calculations**: Optimized for different screen sizes
- **Boundary Detection**: Safe calculations with minimum size constraints

---

This API documentation provides the foundation for understanding, extending, and maintaining the codebase. All public interfaces follow consistent patterns and include comprehensive error handling.
