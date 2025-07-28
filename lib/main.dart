import 'dart:async';
import 'package:flutter/material.dart';
import 'models/text_properties.dart';
import 'controllers/text_animation_controller.dart';
import 'widgets/moving_text_widget.dart';
import 'widgets/control_panel_widget.dart';
import 'utils/text_utils.dart';

void main() {
  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stackTrace) {
    // Log errors to help with debugging
    debugPrint('Application error: $error');
    debugPrint('Stack trace: $stackTrace');
  });
}

/// Root application widget with comprehensive error handling
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      home: const MovingTextApp(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.light,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2196F3),
        brightness: Brightness.dark,
      ),
    );
  }
}

/// Main application widget with refactored, maintainable code structure
class MovingTextApp extends StatefulWidget {
  const MovingTextApp({super.key});

  @override
  State<MovingTextApp> createState() => _MovingTextAppState();
}

class _MovingTextAppState extends State<MovingTextApp> with TickerProviderStateMixin {
  // Controllers and state management
  late TextAnimationController _animationController;
  final ValueNotifier<double> _sheetSize = ValueNotifier(0.05); // Start very small
  late DraggableScrollableController _sheetController;
  
  // Reset animation controllers
  late AnimationController _resetAnimationController;
  late Animation<double> _resetProgress;
  
  // Current state
  late ControlPanelState _controlState;
  bool _isInitialized = false;
  bool _isResetting = false;
  bool _isPanelVisible = false;
  Size? _lastScreenSize;
  
  // Error tracking for better stability
  String? _initializationError;
  int _initializationRetryCount = 0;
  static const int _maxInitializationRetries = 5;

  @override
  void initState() {
    super.initState();
    try {
      _initializeControllers();
      _initializeState();
      _scheduleInitialization();
    } catch (e, stackTrace) {
      debugPrint('Initialization error: $e');
      debugPrint('Stack trace: $stackTrace');
      _handleInitializationError(e);
    }
  }

  /// Input validation helper methods for security and stability
  
  /// Validate and clamp font index with bounds checking
  int _validateFontIndex(int index) {
    if (index < 0 || index >= ControlPanelConfig.fontOptions.length) {
      debugPrint('Invalid font index: $index, using default: 0');
      return 0;
    }
    return index;
  }

  /// Validate and clamp font size
  double _validateFontSize(double size) {
    if (size.isNaN || size.isInfinite || size <= 0) {
      debugPrint('Invalid font size: $size, using default: 72.0');
      return 72.0;
    }
    return size.clamp(ControlPanelConfig.minFontSize, ControlPanelConfig.maxFontSize);
  }

  /// Validate speed input with comprehensive checking
  double _validateSpeed(double speed) {
    if (speed.isNaN || speed.isInfinite) {
      debugPrint('Invalid speed value: $speed, using 0.0');
      return 0.0;
    }
    return speed.clamp(ControlPanelConfig.minSpeed, ControlPanelConfig.maxSpeed);
  }

  /// Validate drawer size with bounds checking
  double _validateDrawerSize(double size) {
    if (size.isNaN || size.isInfinite) {
      debugPrint('Invalid drawer size: $size, using 0.05');
      return 0.05;
    }
    return size.clamp(0.0, 1.0);
  }

  /// Get font family with safe array access
  String? _getSafeFontFamily(int index) {
    final validatedIndex = _validateFontIndex(index);
    return ControlPanelConfig.fontOptions[validatedIndex];
  }

  /// Validate screen size with comprehensive checks
  bool _validateScreenSize(Size size) {
    return size.width > 0 && 
           size.height > 0 && 
           size.width.isFinite && 
           size.height.isFinite &&
           size.width < double.maxFinite &&
           size.height < double.maxFinite;
  }

  /// Show error message to user
  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Handle initialization errors with user feedback
  void _handleInitializationError(Object error) {
    if (!mounted) return;
    
    final errorMessage = error.toString();
    debugPrint('Initialization error: $errorMessage');
    
    // Only update state if error message is different to avoid unnecessary rebuilds
    if (_initializationError != errorMessage) {
      setState(() {
        _initializationError = errorMessage;
      });
    }
    
    _showErrorSnackBar('Initialization failed: $errorMessage');
    
    // Auto-clear error after 8 seconds (reduced from 10)
    Timer(const Duration(seconds: 8), () {
      if (mounted && _initializationError == errorMessage) {
        setState(() {
          _initializationError = null;
        });
      }
    });
  }

  void _initializeControllers() {
    try {
      _animationController = TextAnimationController(vsync: this);
      _animationController.onUpdate = () => setState(() {});
      _sheetController = DraggableScrollableController();
      
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
      
      // Keep sheet size in sync with controller
      _sheetController.addListener(() {
        if (_sheetController.isAttached) {
          _sheetSize.value = _sheetController.size;
        }
      });
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
    _sheetSize.value = 0.05;
    _sheetController.animateTo(
      0.05,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    
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
    final currentSize = _sheetSize.value;
    final isExpanded = currentSize > 0.15; // Lower threshold for expanded state
    final targetSize = isExpanded ? 0.05 : 0.75; // Increased from 0.6 to 0.75 for much more space
    
    _sheetSize.value = targetSize;
    _sheetController.animateTo(
      targetSize,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    
    _controlState = ControlPanelState(
      speed: _controlState.speed,
      fontSize: _controlState.fontSize,
      helloColor: _controlState.helloColor,
      worldColor: _controlState.worldColor,
      selectedFontIndex: _controlState.selectedFontIndex,
      isBold: _controlState.isBold,
      drawerSize: targetSize,
    );
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

      _animationController.initializeTextWidgets(textWidgets);
      _animationController.updateTextConfig(textConfig);

      // Guarantee a rebuild after initialization
      _isInitialized = true;
      Future.microtask(() {
        if (mounted) setState(() {});
      });
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
      body: Stack(
        children: [
          // Main content
          LayoutBuilder(
            builder: (context, constraints) => _buildMainContent(constraints),
          ),
          // Show error banner if there's an initialization error (less intrusive)
          if (_initializationError != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                color: Colors.red.shade50,
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.red.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Initialization warning: $_initializationError',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => _initializationError = null),
                        color: Colors.red.shade700,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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

    // Always build the Stack, but show a loading indicator if text widgets are empty
    return Stack(
      children: [
        if (_animationController.textWidgets.isEmpty)
          const Center(child: CircularProgressIndicator()),
        ..._buildMovingTextWidgets(),
        _buildSlidingControlPanel(constraints),
      ],
    );
  }

  List<Widget> _buildMovingTextWidgets() {
    try {
      final textConfig = _createCurrentTextConfig();

      return _animationController.textWidgets.map((textProps) {
        return MovingTextWidget(
          key: ValueKey('${textProps.text}-${textConfig.fontFamily}-${textConfig.fontSize}-${textConfig.isBold}'),
          textProps: textProps,
          textConfig: textConfig,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error building moving text widgets: $e');
      return [];
    }
  }

  void _updatePhysics(BoxConstraints constraints) {
    // Don't apply physics during reset animation or when speed is 0
    if (_isResetting || _controlState.speed <= 0 || !_animationController.isInitialized) {
      return;
    }
    
    final drawerHeight = _sheetSize.value * constraints.maxHeight;
    _animationController.applyPhysics(
      screenSize: Size(constraints.maxWidth, constraints.maxHeight),
      drawerHeight: drawerHeight,
    );
  }

  // Replace _buildControlsDrawer with a custom sliding panel
  Widget _buildSlidingControlPanel(BoxConstraints constraints) {
    final panelHeight = constraints.maxHeight * 0.5;
    return Stack(
      children: [
        // Overlay for tap-off-to-hide
        if (_isPanelVisible)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => setState(() => _isPanelVisible = false),
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.black.withOpacity(0.2)),
            ),
          ),
        // Sliding panel
        AnimatedSlide(
          offset: _isPanelVisible ? Offset(0, 0) : Offset(0, 1),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: panelHeight,
              width: double.infinity,
              child: _buildControlPanel(ScrollController()),
            ),
          ),
        ),
      ],
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
      _sheetController.dispose();
    } catch (e) {
      debugPrint('Error disposing sheet controller: $e');
    }
    
    try {
      _sheetSize.dispose();
    } catch (e) {
      debugPrint('Error disposing sheet size notifier: $e');
    }
    
    super.dispose();
  }
}
