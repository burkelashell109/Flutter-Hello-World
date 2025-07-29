// ============================================================================
// IMPORTS AND DEPENDENCIES
// ============================================================================

import 'dart:async'; // For error handling with runZonedGuarded
import 'package:flutter/material.dart';

// Application models - data structures for text properties and configuration
import 'models/text_properties.dart';

// Animation controllers - manages text movement, physics, and transitions
import 'controllers/text_animation_controller.dart';

// UI widgets - custom widgets for rendering moving text and control panels
import 'widgets/moving_text_widget.dart';
import 'widgets/control_panel_widget.dart';

// Utility functions - text measurement, positioning, and physics calculations
import 'utils/text_utils.dart';

// ============================================================================
// APPLICATION ENTRY POINT
// ============================================================================

/// Main entry point for the Flutter application.
/// 
/// Implements comprehensive error handling using [runZonedGuarded] to catch
/// and log any uncaught exceptions during app execution. This prevents app
/// crashes and provides debugging information for developers.
/// 
/// **Error Handling Strategy:**
/// - Global exception catching with runZonedGuarded
/// - Debug logging for error tracking and troubleshooting
/// - Graceful failure without app termination
/// 
/// **For Developers:**
/// Any uncaught exceptions will be logged to the debug console with full
/// stack traces, making it easier to identify and fix issues during development.
void main() {
  // Wrap the entire app in error handling to catch uncaught exceptions
  runZonedGuarded(() {
    // Start the Flutter application
    runApp(const MyApp());
  }, (error, stackTrace) {
    // Log any uncaught errors to the debug console for developer analysis
    debugPrint('Application error: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}

// ============================================================================
// ROOT APPLICATION WIDGET
// ============================================================================

/// Root application widget that configures Material Design theming and navigation.
/// 
/// This widget serves as the foundation for the entire app, setting up:
/// - Material Design 3 (Material You) theming with dynamic colors
/// - Light and dark theme support that follows system preferences
/// - Consistent color schemes based on a primary seed color
/// - Debug banner removal for cleaner presentation
/// 
/// **Design Philosophy:**
/// - Uses Material Design 3 for modern, accessible UI components
/// - Implements system-responsive theming (light/dark mode)
/// - Provides consistent visual language throughout the app
/// 
/// **For Developers:**
/// Modify the [_buildLightTheme] and [_buildDarkTheme] methods to customize
/// the app's visual appearance. The seed color (currently blue) generates
/// all other colors in the theme automatically.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Remove debug banner for cleaner presentation
      debugShowCheckedModeBanner: false,
      
      // Configure light theme based on Material Design 3
      theme: _buildLightTheme(),
      
      // Configure dark theme for system dark mode support
      darkTheme: _buildDarkTheme(),
      
      // Automatically switch between light/dark based on system preference
      themeMode: ThemeMode.system,
      
      // Set the main application screen
      home: const MovingTextApp(),
    );
  }

  /// Builds the light theme configuration using Material Design 3.
  /// 
  /// **Color Generation:**
  /// Uses a seed color (#2196F3 - Material Blue) to automatically generate
  /// a complete color palette including primary, secondary, tertiary colors
  /// and their variants. This ensures visual consistency and accessibility.
  /// 
  /// **For Developers:**
  /// Change the seedColor to modify the entire app's color scheme.
  /// Material Design 3 will automatically generate harmonious colors.
  ThemeData _buildLightTheme() {
    return ThemeData(
      // Enable Material Design 3 (Material You) components
      useMaterial3: true,
      
      // Generate complete color scheme from seed color
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3), // Material Blue
        brightness: Brightness.light,
      ),
    );
  }

  /// Builds the dark theme configuration using Material Design 3.
  /// 
  /// **Dark Mode Support:**
  /// Uses the same seed color as light theme but with dark brightness.
  /// This ensures color consistency while adapting to dark mode preferences.
  /// 
  /// **Accessibility:**
  /// Dark themes reduce eye strain in low-light conditions and can help
  /// conserve battery on OLED displays.
  ThemeData _buildDarkTheme() {
    return ThemeData(
      // Enable Material Design 3 (Material You) components
      useMaterial3: true,
      
      // Generate dark color scheme from same seed color
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3), // Material Blue
        brightness: Brightness.dark,
      ),
    );
  }
}

// ============================================================================
// MAIN APPLICATION WIDGET - STATEFUL LOGIC
// ============================================================================

/// Main application widget containing the animated text and control system.
/// 
/// This is the core widget that manages the "Hello World" moving text animation.
/// It coordinates between user controls, animation logic, physics simulation,
/// and rendering to create an interactive text animation experience.
/// 
/// **Key Responsibilities:**
/// - Text animation and physics simulation management
/// - User interface state and control panel interactions
/// - Error handling and recovery for robust operation
/// - Responsive layout adapting to different screen sizes
/// - Reset functionality to return to initial state
/// 
/// **Architecture Pattern:**
/// Uses a controller-based architecture where [TextAnimationController] handles
/// the animation logic while this widget manages UI state and user interactions.
/// This separation makes the code more maintainable and testable.
/// 
/// **For Developers:**
/// This widget demonstrates Flutter best practices including:
/// - Proper StatefulWidget lifecycle management
/// - Controller pattern for complex logic separation
/// - Error boundaries and graceful failure handling
/// - Responsive design with LayoutBuilder
/// - Performance-optimized rebuilds with targeted setState calls
class MovingTextApp extends StatefulWidget {
  const MovingTextApp({super.key});

  @override
  State<MovingTextApp> createState() => _MovingTextAppState();
}

// ============================================================================
// STATE CLASS - PROPERTIES AND INITIALIZATION
// ============================================================================

/// State class managing animation controllers, UI state, and user interactions.
/// 
/// **Mixin Usage:**
/// - [TickerProviderStateMixin]: Provides animation ticker for smooth 60fps animation
/// 
/// **State Management Strategy:**
/// This class follows a clear separation of concerns:
/// - Animation logic: Handled by TextAnimationController
/// - UI state: Managed locally (panel visibility, initialization status)
/// - Error handling: Comprehensive try-catch with user feedback
/// - Performance: Optimized rebuilds and efficient memory management
class _MovingTextAppState extends State<MovingTextApp> with TickerProviderStateMixin {
  
  // ============================================================================
  // CORE CONTROLLERS AND ANIMATION MANAGEMENT
  // ============================================================================
  
  /// Primary controller for text animation, movement, and physics simulation.
  /// 
  /// **Responsibilities:**
  /// - Manages text widget positions and velocities
  /// - Handles collision detection and bouncing physics
  /// - Provides smooth animation transitions and reset functionality
  /// - Coordinates with UI updates through callback system
  late TextAnimationController _animationController;
  
  /// Scroll controller for the control panel's scrollable content.
  /// 
  /// **Purpose:**
  /// Manages scrolling within the control panel when content exceeds
  /// the available screen space, ensuring all controls remain accessible
  /// on smaller devices or when the panel contains many options.
  late ScrollController _panelScrollController;
  
  /// Animation controller specifically for smooth reset transitions.
  /// 
  /// **Reset Animation Details:**
  /// - Duration: 2 seconds for smooth visual transition
  /// - Curve: EaseInOut for natural motion feeling
  /// - Animates: Position, color, and font size changes
  /// - Prevents: User interactions during reset to avoid conflicts
  late AnimationController _resetAnimationController;
  
  /// Animation progress tracker for reset transitions (0.0 to 1.0).
  /// 
  /// **Progress Mapping:**
  /// - 0.0: Current state (before reset)
  /// - 1.0: Target state (centered, default colors, default font size)
  /// - Used for smooth interpolation of all animated properties
  late Animation<double> _resetProgress;
  
  // ============================================================================
  // APPLICATION STATE VARIABLES
  // ============================================================================
  
  /// Current state of all control panel settings and user preferences.
  /// 
  /// **Contains:**
  /// - speed: Animation speed (0.0 = stopped, 25.0 = maximum)
  /// - fontSize: Text size in logical pixels (12.0 to 144.0)
  /// - helloColor/worldColor: Individual text colors
  /// - selectedFontIndex: Index into available font options
  /// - isBold: Whether text uses bold font weight
  /// - drawerSize: Control panel size (legacy parameter, maintained for compatibility)
  late ControlPanelState _controlState;
  
  /// Flag indicating whether the text animation system has been fully initialized.
  /// 
  /// **Initialization Process:**
  /// 1. Wait for valid screen dimensions from LayoutBuilder
  /// 2. Calculate initial text positions using TextUtils
  /// 3. Create TextProperties objects for "Hello" and "World!"
  /// 4. Initialize animation controller with text widgets
  /// 5. Set flag to true and trigger UI update
  /// 
  /// **Usage:**
  /// Prevents rendering issues by ensuring text widgets are only displayed
  /// after proper initialization with valid screen dimensions.
  bool _isInitialized = false;
  
  /// Flag indicating whether a reset animation is currently in progress.
  /// 
  /// **Purpose:**
  /// - Prevents multiple simultaneous reset operations
  /// - Disables user controls during reset to avoid conflicts
  /// - Ensures smooth, uninterrupted reset transitions
  /// - Maintains UI consistency during state changes
  bool _isResetting = false;
  
  /// Flag controlling the visibility of the control panel.
  /// 
  /// **Behavior:**
  /// - true: Panel slides up from bottom with fade-in animation
  /// - false: Panel slides down and fades out
  /// - Toggled by floating action button or tap-outside-to-dismiss
  /// - Prevents layout errors by conditionally rendering panel
  bool _isPanelVisible = false;
  
  /// Cache of the most recent screen size for handling orientation changes.
  /// 
  /// **Purpose:**
  /// - Detects screen size/orientation changes
  /// - Triggers text repositioning when dimensions change
  /// - Maintains relative text positioning across rotations
  /// - Prevents text from moving outside screen bounds
  Size? _lastScreenSize;
  
  // ============================================================================
  // ERROR HANDLING AND RELIABILITY
  // ============================================================================
  
  /// Current initialization error message for developer debugging.
  /// 
  /// **Error Handling Strategy:**
  /// - Stores error details for debugging purposes
  /// - Displays user-friendly SnackBar messages instead of persistent banners
  /// - Auto-clears errors after timeout to prevent stale error states
  /// - Enables retry mechanisms for transient failures
  String? _initializationError;
  
  /// Counter tracking initialization retry attempts.
  /// 
  /// **Retry Logic:**
  /// - Implements exponential backoff (200ms × retry_count)
  /// - Prevents infinite retry loops with maximum attempt limit
  /// - Handles transient failures like temporary screen size unavailability
  /// - Provides progressive delay for system stabilization
  int _initializationRetryCount = 0;
  
  /// Maximum number of initialization retry attempts before giving up.
  /// 
  /// **Rationale:**
  /// 5 attempts with exponential backoff provides sufficient opportunity
  /// for system stabilization while preventing infinite loops that could
  /// impact app performance or user experience.
  static const int _maxInitializationRetries = 5;

  // ============================================================================
  // WIDGET LIFECYCLE - INITIALIZATION AND SETUP
  // ============================================================================

  /// Initializes the widget state and sets up controllers.
  /// 
  /// **Initialization Sequence:**
  /// 1. Initialize all animation controllers and their configurations
  /// 2. Set up default control panel state with sensible defaults
  /// 3. Schedule text positioning once screen dimensions are available
  /// 4. Configure comprehensive error handling for any initialization failures
  /// 
  /// **Error Recovery:**
  /// If initialization fails, the error is captured, logged, and displayed
  /// to the user via SnackBar. The app remains functional and can retry
  /// initialization automatically.
  @override
  void initState() {
    super.initState();
    try {
      // Initialize animation controllers and scroll controllers
      _initializeControllers();
      
      // Set up default control panel state
      _initializeState();
      
      // Schedule initialization of text positions (requires screen dimensions)
      _scheduleInitialization();
    } catch (e, stackTrace) {
      // Log detailed error information for developer debugging
      debugPrint('Initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      
      // Display user-friendly error message and enable recovery
      _handleInitializationError(e);
    }
  }

  // ============================================================================
  // INPUT VALIDATION AND SECURITY - PROTECTING AGAINST INVALID DATA
  // ============================================================================

  /// Input validation helper methods for security and stability.
  /// 
  /// **Security Importance:**
  /// These validation methods protect the application from:
  /// - Array index out-of-bounds errors
  /// - Division by zero and mathematical edge cases
  /// - Invalid numerical inputs (NaN, Infinity)
  /// - Layout errors from negative or extreme values
  /// 
  /// **Design Pattern:**
  /// All validation methods follow a consistent pattern:
  /// 1. Check for invalid input conditions
  /// 2. Log warning with original and corrected values
  /// 3. Return safe fallback value within acceptable range
  /// 4. Ensure app continues functioning despite bad input
  
  /// Validates and clamps font index to prevent array access errors.
  /// 
  /// **Security Check:**
  /// Prevents crashes from invalid array indices that could come from:
  /// - Corrupted app state
  /// - External data sources
  /// - Race conditions during initialization
  /// 
  /// **Parameters:**
  /// - [index]: Font index to validate
  /// 
  /// **Returns:** Valid index (0 if input was invalid)
  /// 
  /// **Example:**
  /// ```dart
  /// final safeIndex = _validateFontIndex(-1);  // Returns: 0
  /// final safeIndex = _validateFontIndex(999); // Returns: 0
  /// ```
  int _validateFontIndex(int index) {
    if (index < 0 || index >= ControlPanelConfig.fontOptions.length) {
      debugPrint('Invalid font index: $index, using default: 0');
      return 0;
    }
    return index;
  }

  /// Validates and clamps font size to prevent layout issues.
  /// 
  /// **Layout Protection:**
  /// Prevents UI layout errors from extreme font sizes:
  /// - Too small: Text becomes invisible or unreadable
  /// - Too large: Text overflows screen, causes performance issues
  /// - Invalid: NaN or Infinity values crash the rendering system
  /// 
  /// **Parameters:**
  /// - [size]: Font size to validate (in logical pixels)
  /// 
  /// **Returns:** Safe font size within acceptable range (12.0 to 144.0)
  double _validateFontSize(double size) {
    if (size.isNaN || size.isInfinite || size <= 0) {
      debugPrint('Invalid font size: $size, using default: 72.0');
      return 72.0;
    }
    return size.clamp(ControlPanelConfig.minFontSize, ControlPanelConfig.maxFontSize);
  }

  /// Validates speed input with comprehensive mathematical checking.
  /// 
  /// **Physics Safety:**
  /// Ensures animation speed values don't break the physics simulation:
  /// - Negative speeds: Could cause erratic movement behavior
  /// - Extreme speeds: Could cause text to jump past screen boundaries
  /// - Invalid numbers: NaN/Infinity break collision detection
  /// 
  /// **Parameters:**
  /// - [speed]: Animation speed to validate (pixels per frame)
  /// 
  /// **Returns:** Safe speed value within range (0.0 to 25.0)
  double _validateSpeed(double speed) {
    if (speed.isNaN || speed.isInfinite) {
      debugPrint('Invalid speed value: $speed, using 0.0');
      return 0.0;
    }
    return speed.clamp(ControlPanelConfig.minSpeed, ControlPanelConfig.maxSpeed);
  }

  /// Validates drawer size with bounds checking.
  /// 
  /// **UI Consistency:**
  /// Ensures the control panel drawer size remains within reasonable bounds:
  /// - Negative values: Would cause layout errors
  /// - Values > 1.0: Would exceed screen size (since it's a fraction)
  /// - Invalid numbers: Break layout calculations
  /// 
  /// **Parameters:**
  /// - [size]: Drawer size as fraction of screen (0.0 to 1.0)
  /// 
  /// **Returns:** Safe drawer size fraction
  double _validateDrawerSize(double size) {
    if (size.isNaN || size.isInfinite) {
      debugPrint('Invalid drawer size: $size, using 0.05');
      return 0.05;
    }
    return size.clamp(0.0, 1.0);
  }

  /// Gets font family with safe array access.
  /// 
  /// **Memory Safety:**
  /// Prevents array access violations by validating the index before
  /// accessing the font options array. Critical for app stability.
  /// 
  /// **Parameters:**
  /// - [index]: Index into the font options array
  /// 
  /// **Returns:** Font family name or null for default system font
  String? _getSafeFontFamily(int index) {
    final validatedIndex = _validateFontIndex(index);
    return ControlPanelConfig.fontOptions[validatedIndex];
  }

  /// Validates screen size with comprehensive mathematical checks.
  /// 
  /// **Layout Validation:**
  /// Ensures screen dimensions are valid for text positioning calculations:
  /// - Positive dimensions: Required for meaningful layout
  /// - Finite values: Infinite dimensions break positioning math
  /// - Reasonable limits: Prevents integer overflow in calculations
  /// 
  /// **Parameters:**
  /// - [size]: Screen size to validate
  /// 
  /// **Returns:** true if size is valid for layout calculations
  bool _validateScreenSize(Size size) {
    return size.width > 0 && 
           size.height > 0 && 
           size.width.isFinite && 
           size.height.isFinite &&
           size.width < double.maxFinite &&
           size.height < double.maxFinite;
  }

  // ============================================================================
  // ERROR HANDLING AND USER FEEDBACK
  // ============================================================================

  /// Displays error messages to users via non-intrusive SnackBar notifications.
  /// 
  /// **User Experience Design:**
  /// - Uses floating SnackBar for non-blocking error display
  /// - Red background clearly indicates error state
  /// - Auto-dismisses to avoid persistent UI clutter
  /// - Allows users to continue using app despite errors
  /// 
  /// **Parameters:**
  /// - [message]: User-friendly error message to display
  void _showErrorSnackBar(String message) {
    // Ensure widget is still mounted before showing UI
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating, // Non-blocking overlay style
      ),
    );
  }

  /// Handles initialization errors with comprehensive logging and user feedback.
  /// 
  /// **Error Recovery Strategy:**
  /// 1. Log detailed error for developer debugging
  /// 2. Store error state for internal tracking
  /// 3. Show user-friendly notification
  /// 4. Auto-clear error after timeout to prevent stale state
  /// 5. Maintain app functionality despite initialization failure
  /// 
  /// **Parameters:**
  /// - [error]: The error object that occurred during initialization
  void _handleInitializationError(Object error) {
    // Safety check - don't attempt UI operations on unmounted widget
    if (!mounted) return;
    
    final errorMessage = error.toString();
    debugPrint('Initialization error: $errorMessage');
    
    // Store error for debugging but don't use it for UI (avoids layout issues)
    _initializationError = errorMessage;
    
    // Use SnackBar for user feedback instead of persistent banner
    _showErrorSnackBar('Initialization failed: $errorMessage');
    
    // Auto-clear error after 8 seconds to prevent stale error state
    Timer(const Duration(seconds: 8), () {
      if (mounted && _initializationError == errorMessage) {
        _initializationError = null;
      }
    });
  }

  void _initializeControllers() {
    try {
      _animationController = TextAnimationController(vsync: this);
      // Ensure text remains visible by always triggering setState after initialization
      _animationController.onUpdate = () {
        print("Animation callback: mounted=$mounted, _controlState.speed=${_controlState.speed}, _isInitialized=$_isInitialized");
        // Always call setState when mounted to ensure text widgets are rendered
        if (mounted) {
          print("setState called: ensuring text visibility");
          setState(() {});
        }
      };
      _panelScrollController = ScrollController();
      
      // Initialize reset animation controller
      _resetAnimationController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );
      _resetProgress = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _resetAnimationController,
        curve: Curves.easeInOut,
      ));
    } catch (e) {
      throw Exception('Failed to initialize controllers: $e');
    }
  }

  void _initializeState() {
    _controlState = const ControlPanelState(
      speed: 0.0,
      fontSize: 72.0,
      helloColor: Colors.red,
      worldColor: Colors.blue,
      selectedFontIndex: 0,
      isBold: false,
      drawerSize: 0.05, // Start with very small drawer
    );
  }

  void _scheduleInitialization() {
    // Initialization is now handled by LayoutBuilder in _buildMainContent
    // This ensures we have valid screen dimensions before positioning text
  }

  /// Initialize text positions with comprehensive validation and error handling
  void _initializeTextPositions() {
    if (!mounted) return;
    
    try {
      final size = MediaQuery.of(context).size;
      
      // Validate screen dimensions with comprehensive checks
      if (!_validateScreenSize(size)) {
        _scheduleRetryInitialization();
        return;
      }
      
      final textConfig = _createCurrentTextConfig();
      final textWidgets = _createInitialTextWidgets(size, textConfig);
      
      _animationController.initializeTextWidgets(textWidgets);
      _animationController.updateTextConfig(textConfig);
      
      setState(() {
        _isInitialized = true;
        _initializationError = null;
      });
      
    } catch (e, stackTrace) {
      debugPrint('Text initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      _handleTextInitializationError(e);
    }
  }

  /// Schedule retry initialization with exponential backoff
  void _scheduleRetryInitialization() {
    if (_initializationRetryCount >= _maxInitializationRetries) {
      debugPrint('Max initialization retries reached');
      _handleTextInitializationError('Screen size unavailable after maximum retries');
      return;
    }
    
    _initializationRetryCount++;
    final delay = Duration(milliseconds: 200 * _initializationRetryCount);
    
    Timer(delay, () {
      if (mounted && !_isInitialized) {
        _initializeTextPositions();
      }
    });
  }

  /// Create text config with input validation and bounds checking
  TextConfig _createCurrentTextConfig() {
    final safeSelectedFontIndex = _validateFontIndex(_controlState.selectedFontIndex);
    final safeFontSize = _validateFontSize(_controlState.fontSize);
    
    return TextConfig(
      fontSize: safeFontSize,
      fontFamily: _getSafeFontFamily(safeSelectedFontIndex),
      isBold: _controlState.isBold,
    );
  }

  /// Create initial text widgets with position validation
  List<TextProperties> _createInitialTextWidgets(Size screenSize, TextConfig textConfig) {
    final helloSize = TextUtils.measureText('Hello', textConfig.textStyle);
    final worldSize = TextUtils.measureText('World!', textConfig.textStyle);
    
    final positions = TextUtils.calculateCenteredPositions(
      screenSize: screenSize,
      helloSize: helloSize,
      worldSize: worldSize,
    );
    
    // Validate and clamp positions with comprehensive bounds checking
    final safePositions = _validateAndClampPositions(
      positions, screenSize, helloSize, worldSize);
    
    return [
      TextProperties(
        x: safePositions['hello_x']!,
        y: safePositions['hello_y']!,
        dx: 0,
        dy: 0,
        text: 'Hello',
        color: _controlState.helloColor,
      ),
      TextProperties(
        x: safePositions['world_x']!,
        y: safePositions['world_y']!,
        dx: 0,
        dy: 0,
        text: 'World!',
        color: _controlState.worldColor,
      ),
    ];
  }

  /// Validate and clamp positions with comprehensive safety checks
  Map<String, double> _validateAndClampPositions(
    Map<String, double> positions,
    Size screenSize,
    Size helloSize,
    Size worldSize,
  ) {
    // Helper function to safely clamp positions
    double safeClamp(double value, double min, double max) {
      if (value.isNaN || value.isInfinite) {
        return min;
      }
      return value.clamp(min, max);
    }
    
    return {
      'hello_x': safeClamp(
        positions['hello_x'] ?? 0.0, 
        0.0, 
        (screenSize.width - helloSize.width).clamp(0.0, screenSize.width)
      ),
      'hello_y': safeClamp(
        positions['hello_y'] ?? 0.0, 
        0.0, 
        (screenSize.height - helloSize.height).clamp(0.0, screenSize.height)
      ),
      'world_x': safeClamp(
        positions['world_x'] ?? 0.0, 
        0.0, 
        (screenSize.width - worldSize.width).clamp(0.0, screenSize.width)
      ),
      'world_y': safeClamp(
        positions['world_y'] ?? 0.0, 
        0.0, 
        (screenSize.height - worldSize.height).clamp(0.0, screenSize.height)
      ),
    };
  }

  /// Handle text initialization errors with user feedback
  void _handleTextInitializationError(Object error) {
    if (!mounted) return;
    
    debugPrint('Text initialization failed: $error');
    setState(() {
      _initializationError = error.toString();
      _isInitialized = false;
    });
    
    _showErrorSnackBar('Failed to initialize text: ${error.toString()}');
  }

  /// Update control state with comprehensive validation and error checking
  void _updateControlState({
    double? speed,
    double? fontSize,
    Color? helloColor,
    Color? worldColor,
    int? selectedFontIndex,
    bool? isBold,
    double? drawerSize,
  }) {
    if (!mounted) return;
    
    try {
      _controlState = ControlPanelState(
        speed: _validateSpeed(speed ?? _controlState.speed),
        fontSize: _validateFontSize(fontSize ?? _controlState.fontSize),
        helloColor: helloColor ?? _controlState.helloColor,
        worldColor: worldColor ?? _controlState.worldColor,
        selectedFontIndex: _validateFontIndex(selectedFontIndex ?? _controlState.selectedFontIndex),
        isBold: isBold ?? _controlState.isBold,
        drawerSize: _validateDrawerSize(drawerSize ?? _controlState.drawerSize),
      );
    } catch (e) {
      debugPrint('Error updating control state: $e');
      // Continue with current state if update fails
    }
  }

  // Event handlers with comprehensive input validation and error handling
  void _handleSpeedChange(double newSpeed) {
    try {
      final validatedSpeed = _validateSpeed(newSpeed);
      _updateControlState(speed: validatedSpeed);
      _animationController.updateSpeed(validatedSpeed);
    } catch (e) {
      debugPrint('Error handling speed change: $e');
      _showErrorSnackBar('Failed to update speed: ${e.toString()}');
    }
  }

  void _handleFontSizeChange(double newSize) {
    try {
      _updateControlState(fontSize: newSize);
      _updateTextConfig();
    } catch (e) {
      debugPrint('Error handling font size change: $e');
      _showErrorSnackBar('Failed to update font size: ${e.toString()}');
    }
  }

  void _handleHelloColorChange(Color newColor) {
    try {
      _updateControlState(helloColor: newColor);
      _animationController.updateTextColor(0, newColor);
    } catch (e) {
      debugPrint('Error handling hello color change: $e');
      _showErrorSnackBar('Failed to update hello color: ${e.toString()}');
    }
  }

  void _handleWorldColorChange(Color newColor) {
    try {
      _updateControlState(worldColor: newColor);
      _animationController.updateTextColor(1, newColor);
    } catch (e) {
      debugPrint('Error handling world color change: $e');
      _showErrorSnackBar('Failed to update world color: ${e.toString()}');
    }
  }

  void _handleFontChange(int newIndex) {
    try {
      final validatedIndex = _validateFontIndex(newIndex);
      _updateControlState(selectedFontIndex: validatedIndex);
      _updateTextConfig();
    } catch (e) {
      debugPrint('Error handling font change: $e');
      _showErrorSnackBar('Failed to update font: ${e.toString()}');
    }
  }

  void _handleBoldChange(bool newBold) {
    try {
      _updateControlState(isBold: newBold);
      _updateTextConfig();
    } catch (e) {
      debugPrint('Error handling bold change: $e');
      _showErrorSnackBar('Failed to update bold setting: ${e.toString()}');
    }
  }

  void _handleReset() {
    if (_isResetting) return; // Prevent multiple resets

    setState(() {
      _isPanelVisible = false; // Immediately close the controls drawer
      _isResetting = true;
    });
    
    final size = MediaQuery.of(context).size;
    
    // Store current state for smooth animation
    final startPositions = _animationController.textWidgets.map((widget) => {
      'x': widget.x,
      'y': widget.y,
    }).toList();
    
    final startColors = _animationController.textWidgets.map((widget) => widget.color).toList();
    final startFontSize = _controlState.fontSize;
    
    // Start reset animation
    setState(() {
      _isResetting = true;
    });
    
    // Immediately close the control panel and stop movement
    setState(() => _isPanelVisible = false);
    
    // Stop the text movement immediately
    _animationController.updateSpeed(0.0);
    
    // Immediately change font and bold to final values to avoid position jumps
    _controlState = ControlPanelState(
      speed: 0.0,
      fontSize: startFontSize, // Keep current size for now, will animate
      helloColor: _controlState.helloColor,
      worldColor: _controlState.worldColor,
      selectedFontIndex: 0, // Immediately change to default font
      isBold: false, // Immediately turn off bold
      drawerSize: 0.05,
    );
    
    // Update text config immediately with final font/bold but current size
    _updateTextConfig();
    
    // Start the smooth reset animation
    late VoidCallback animationListener;
    animationListener = () {
      final progress = _resetProgress.value;
      
      // Animate font size from start to 72.0
      final currentFontSize = startFontSize + (72.0 - startFontSize) * progress;
      
      // Update control state with animated font size
      _controlState = ControlPanelState(
        speed: 0.0,
        fontSize: currentFontSize,
        helloColor: _controlState.helloColor,
        worldColor: _controlState.worldColor,
        selectedFontIndex: 0,
        isBold: false,
        drawerSize: 0.05,
      );
      
      // Animate positions, colors, and font size
      _animationController.animateToCenter(
        screenSize: size,
        progress: progress,
        startPositions: startPositions,
        startColors: startColors,
        targetFontSize: currentFontSize,
      );
      
      setState(() {});
    };
    
    _resetAnimationController.addListener(animationListener);
    
    // Start the animation and handle completion
    _resetAnimationController.forward().then((_) {
      if (!mounted) return;
      
      // Remove the animation listener to prevent further updates
      _resetAnimationController.removeListener(animationListener);
      
      // At 2-second mark: Ensure final state is exact
      _controlState = const ControlPanelState(
        speed: 0.0,
        fontSize: 72.0,
        helloColor: Colors.red,
        worldColor: Colors.blue,
        selectedFontIndex: 0,
        isBold: false,
        drawerSize: 0.05,
      );
      
      // Lock positions first to prevent any movement
      _animationController.lockPositions(screenSize: size);
      
      // Ensure exact colors without triggering position updates
      _animationController.updateTextColorSilent(0, Colors.red);
      _animationController.updateTextColorSilent(1, Colors.blue);
      
      // Re-enable controls
      setState(() {
        _isResetting = false;
      });
      
      // Reset the animation controller for next use
      _resetAnimationController.reset();
    });
  }

  void _handleToggleDrawer() {
    // Since we're using a simple sliding panel now, this can just toggle visibility
    setState(() => _isPanelVisible = !_isPanelVisible);
  }

  void _updateTextConfig() {
    try {
      final validatedIndex = _validateFontIndex(_controlState.selectedFontIndex);
      final safeFontFamily = _getSafeFontFamily(validatedIndex);
      
      final textConfig = TextConfig(
        fontSize: _validateFontSize(_controlState.fontSize),
        fontFamily: safeFontFamily,
        isBold: _controlState.isBold,
      );
      
      // Only update the text config, don't trigger repositioning during reset
      if (!_isResetting) {
        _animationController.updateTextConfig(textConfig);
      } else {
        // During reset, just update the internal config without triggering callbacks
        _animationController.updateTextConfigSilent(textConfig);
      }
    } catch (e) {
      debugPrint('Error updating text config: $e');
      _showErrorSnackBar('Failed to update text configuration');
    }
  }

  void _initializeTextWithSize(Size screenSize) {
    try {
      debugPrint('Initializing text with screen size: ${screenSize.width} x ${screenSize.height}');
      
      if (!_validateScreenSize(screenSize)) {
        throw Exception('Invalid screen size for text initialization');
      }
      
      final textConfig = _createCurrentTextConfig();
      final helloSize = TextUtils.measureText('Hello', textConfig.textStyle);
      final worldSize = TextUtils.measureText('World!', textConfig.textStyle);

      final positions = TextUtils.calculateCenteredPositions(
        screenSize: screenSize,
        helloSize: helloSize,
        worldSize: worldSize,
      );

      final safePositions = _validateAndClampPositions(
        positions, screenSize, helloSize, worldSize);

      debugPrint('Calculated positions: $safePositions');

      final textWidgets = [
        TextProperties(
          x: safePositions['hello_x']!,
          y: safePositions['hello_y']!,
          dx: 0,
          dy: 0,
          text: 'Hello',
          color: _controlState.helloColor,
        ),
        TextProperties(
          x: safePositions['world_x']!,
          y: safePositions['world_y']!,
          dx: 0,
          dy: 0,
          text: 'World!',
          color: _controlState.worldColor,
        ),
      ];

      debugPrint('Created text widgets: ${textWidgets.length}');
      for (int i = 0; i < textWidgets.length; i++) {
        final widget = textWidgets[i];
        debugPrint('Widget $i: "${widget.text}" at (${widget.x}, ${widget.y}) color: ${widget.color}');
      }

      _animationController.initializeTextWidgets(textWidgets);
      _animationController.updateTextConfig(textConfig);

      // Guarantee a rebuild after initialization
      _isInitialized = true;
      debugPrint('Text initialization complete, setting _isInitialized = true');
      
      // Force immediate setState to ensure text widgets are displayed
      if (mounted) {
        setState(() {
          debugPrint('Final setState called after text initialization - text should now be visible');
        });
      }
    } catch (e) {
      debugPrint('Error initializing text with size: $e');
      _handleTextInitializationError(e);
    }
  }

  void _repositionTextWithSize(Size screenSize) {
    try {
      if (!_validateScreenSize(screenSize)) {
        throw Exception('Invalid screen size for repositioning');
      }
      
      final textConfig = _createCurrentTextConfig();
      final helloSize = TextUtils.measureText('Hello', textConfig.textStyle);
      final worldSize = TextUtils.measureText('World!', textConfig.textStyle);
      
      final positions = TextUtils.calculateCenteredPositions(
        screenSize: screenSize,
        helloSize: helloSize,
        worldSize: worldSize,
      );
      
      final safePositions = _validateAndClampPositions(
        positions, screenSize, helloSize, worldSize);
      
      // Update existing text widget positions with validation
      if (_animationController.textWidgets.length >= 2) {
        _animationController.textWidgets[0].x = safePositions['hello_x']!;
        _animationController.textWidgets[0].y = safePositions['hello_y']!;
        _animationController.textWidgets[1].x = safePositions['world_x']!;
        _animationController.textWidgets[1].y = safePositions['world_y']!;
        
        // Force a UI update
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error repositioning text: $e');
      _showErrorSnackBar('Failed to reposition text');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) => _buildMainContent(constraints),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildMainContent(BoxConstraints constraints) {
    final currentSize = Size(constraints.maxWidth, constraints.maxHeight);

    // Initialize text positions on the first valid layout
    if (!_isInitialized && constraints.maxWidth > 0 && constraints.maxHeight > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isInitialized) {
          _initializeTextWithSize(currentSize);
        }
      });
    }

    // If we have invalid text positions, fix them after build
    if (_isInitialized && constraints.maxWidth > 0 && constraints.maxHeight > 0 && _animationController.textWidgets.isNotEmpty) {
      bool needsReCenter = false;
      for (final widget in _animationController.textWidgets) {
        if (widget.x < 0 || widget.y < 0 || 
            widget.x > currentSize.width || widget.y > currentSize.height) {
          needsReCenter = true;
          break;
        }
      }
      if (needsReCenter) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _repositionTextWithSize(currentSize);
          }
        });
      }
    }

    _updatePhysics(constraints);

    // Handle screen size/orientation changes
    if (_lastScreenSize != null &&
        (currentSize.width != _lastScreenSize!.width || currentSize.height != _lastScreenSize!.height)) {
      // For each text widget, update its position to maintain relative placement
      for (final widget in _animationController.textWidgets) {
        final relX = widget.x / _lastScreenSize!.width;
        final relY = widget.y / _lastScreenSize!.height;
        widget.x = relX * currentSize.width;
        widget.y = relY * currentSize.height;
      }
    }
    _lastScreenSize = currentSize;

    // Always build the Stack, but ensure text widgets are always visible above overlays/panels
    return Stack(
      children: [
        if (_animationController.textWidgets.isEmpty)
          const Center(child: CircularProgressIndicator()),
        ..._buildMovingTextWidgets(),
        // Only build the control panel when visible to avoid layout errors
        if (_isPanelVisible)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildSlidingControlPanel(constraints),
          ),
      ],
    );
  }

  List<Widget> _buildMovingTextWidgets() {
    try {
      debugPrint('Building text widgets: ${_animationController.textWidgets.length} widgets');
      final textConfig = _createCurrentTextConfig();

      final widgets = _animationController.textWidgets.map((textProps) {
        debugPrint('Widget: "${textProps.text}" at (${textProps.x}, ${textProps.y}) color: ${textProps.color}');
        return MovingTextWidget(
          key: ValueKey('${textProps.text}-${textConfig.fontFamily}-${textConfig.fontSize}-${textConfig.isBold}'),
          textProps: textProps,
          textConfig: textConfig,
        );
      }).toList();
      
      debugPrint('Returning ${widgets.length} text widgets');
      return widgets;
    } catch (e) {
      debugPrint('Error building moving text widgets: $e');
      return [];
    }
  }

  void _updatePhysics(BoxConstraints constraints) {
    debugPrint('_updatePhysics called: speed=${_controlState.speed}, isResetting=$_isResetting, isInitialized=${_animationController.isInitialized}');
    
    // Don't apply physics during reset animation or when speed is 0
    if (_isResetting || _controlState.speed <= 0 || !_animationController.isInitialized) {
      if (_controlState.speed <= 0 && _animationController.isInitialized) {
        debugPrint('Physics skipped - speed is 0, but checking if text is still moving...');
        // Check if text widgets have velocity when they shouldn't
        for (int i = 0; i < _animationController.textWidgets.length; i++) {
          final widget = _animationController.textWidgets[i];
          if (widget.dx != 0 || widget.dy != 0) {
            debugPrint('WARNING: Widget $i "${widget.text}" has velocity (${widget.dx}, ${widget.dy}) when speed is 0!');
          }
        }
      }
      return;
    }
    
    debugPrint('Applying physics with speed=${_controlState.speed}');
    _animationController.applyPhysics(
      screenSize: Size(constraints.maxWidth, constraints.maxHeight),
      drawerHeight: 0.0, // Legacy parameter, not used
    );
  }

  // Replace _buildControlsDrawer with a custom sliding panel
  Widget _buildSlidingControlPanel(BoxConstraints constraints) {
    final panelHeight = constraints.maxHeight * 0.5;
    if (!_isPanelVisible) {
      // Always return a SizedBox with finite height to avoid layout errors
      return SizedBox(height: panelHeight);
    }

    return SizedBox(
      height: panelHeight,
      child: Stack(
        children: [
          // Overlay for tap-off-to-hide
          GestureDetector(
            onTap: () => setState(() => _isPanelVisible = false),
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.black.withOpacity(0.2),
              width: double.infinity,
              height: panelHeight,
            ),
          ),
          // Sliding panel with entrance animation
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 350),
            tween: Tween<double>(begin: 1.0, end: 0.0),
            curve: Curves.easeInOut,
            builder: (context, slideValue, child) {
              return Transform.translate(
                offset: Offset(0, slideValue * panelHeight),
                child: child,
              );
            },
            child: _buildControlPanel(_panelScrollController),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(ScrollController scrollController) {
    final callbacks = ControlPanelCallbacks(
      onSpeedChanged: _isResetting ? null : _handleSpeedChange,
      onFontSizeChanged: _isResetting ? null : _handleFontSizeChange,
      onHelloColorChanged: _isResetting ? null : _handleHelloColorChange,
      onWorldColorChanged: _isResetting ? null : _handleWorldColorChange,
      onFontChanged: _isResetting ? null : _handleFontChange,
      onBoldChanged: _isResetting ? null : _handleBoldChange,
      onToggleDrawer: _isResetting ? null : _handleToggleDrawer,
      onReset: _isResetting ? null : _handleReset,
    );

    return ControlPanelWidget(
      state: _controlState,
      callbacks: callbacks,
      scrollController: scrollController,
    );
  }

  // Update the FAB to toggle the panel
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => setState(() => _isPanelVisible = !_isPanelVisible),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      elevation: 6,
      child: Icon(_isPanelVisible ? Icons.close : Icons.settings_rounded),
    );
  }

  @override
  void dispose() {
    // Dispose controllers with comprehensive error handling
    try {
      _animationController.dispose();
    } catch (e) {
      debugPrint('Error disposing animation controller: $e');
    }
    
    try {
      _resetAnimationController.dispose();
    } catch (e) {
      debugPrint('Error disposing reset animation controller: $e');
    }
    
    try {
      _panelScrollController.dispose();
    } catch (e) {
      debugPrint('Error disposing panel scroll controller: $e');
    }
    
    super.dispose();
  }
}
