import 'package:flutter/material.dart';
import 'models/text_properties.dart';
import 'controllers/text_animation_controller.dart';
import 'widgets/moving_text_widget.dart';
import 'widgets/control_panel_widget.dart';
import 'utils/text_utils.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
      ),
      home: const MovingTextApp(),
    ),
  );
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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeState();
    _scheduleInitialization();
  }

  void _initializeControllers() {
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

  void _initializeTextPositions() {
    final size = MediaQuery.of(context).size;
    
    // Ensure we have a valid screen size
    if (size.width <= 0 || size.height <= 0) {
      // Try again after another frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_isInitialized) {
          _initializeTextPositions();
        }
      });
      return;
    }
    
    final textConfig = TextConfig(
      fontSize: _controlState.fontSize,
      fontFamily: ControlPanelConfig.fontOptions[_controlState.selectedFontIndex],
      isBold: _controlState.isBold,
    );
    
    final helloSize = TextUtils.measureText('Hello', textConfig.textStyle);
    final worldSize = TextUtils.measureText('World!', textConfig.textStyle);
    
    final positions = TextUtils.calculateCenteredPositions(
      screenSize: size,
      helloSize: helloSize,
      worldSize: worldSize,
    );
    
    // Safety check: Ensure positions are valid (not negative, not off-screen)
    final safeHelloX = positions['hello_x']!.clamp(0.0, size.width - helloSize.width);
    final safeHelloY = positions['hello_y']!.clamp(0.0, size.height - helloSize.height);
    final safeWorldX = positions['world_x']!.clamp(0.0, size.width - worldSize.width);
    final safeWorldY = positions['world_y']!.clamp(0.0, size.height - worldSize.height);
    
    if (safeHelloX != positions['hello_x'] || safeHelloY != positions['hello_y'] ||
        safeWorldX != positions['world_x'] || safeWorldY != positions['world_y']) {
    }
    
    final textWidgets = [
      TextProperties(
        x: safeHelloX,
        y: safeHelloY,
        dx: 0,
        dy: 0,
        text: 'Hello',
        color: _controlState.helloColor,
      ),
      TextProperties(
        x: safeWorldX,
        y: safeWorldY,
        dx: 0,
        dy: 0,
        text: 'World!',
        color: _controlState.worldColor,
      ),
    ];
    
    _animationController.initializeTextWidgets(textWidgets);
    _animationController.updateTextConfig(textConfig);
    
    // Don't apply physics immediately - let text stay centered
    setState(() {
      _isInitialized = true;
    });
  }

  // Event handlers for control panel interactions
  void _handleSpeedChange(double newSpeed) {
    _controlState = ControlPanelState(
      speed: newSpeed,
      fontSize: _controlState.fontSize,
      helloColor: _controlState.helloColor,
      worldColor: _controlState.worldColor,
      selectedFontIndex: _controlState.selectedFontIndex,
      isBold: _controlState.isBold,
      drawerSize: _controlState.drawerSize,
    );
    _animationController.updateSpeed(newSpeed);
  }

  void _handleFontSizeChange(double newSize) {
    _controlState = ControlPanelState(
      speed: _controlState.speed,
      fontSize: newSize,
      helloColor: _controlState.helloColor,
      worldColor: _controlState.worldColor,
      selectedFontIndex: _controlState.selectedFontIndex,
      isBold: _controlState.isBold,
      drawerSize: _controlState.drawerSize,
    );
    _updateTextConfig();
  }

  void _handleHelloColorChange(Color newColor) {
    _controlState = ControlPanelState(
      speed: _controlState.speed,
      fontSize: _controlState.fontSize,
      helloColor: newColor,
      worldColor: _controlState.worldColor,
      selectedFontIndex: _controlState.selectedFontIndex,
      isBold: _controlState.isBold,
      drawerSize: _controlState.drawerSize,
    );
    _animationController.updateTextColor(0, newColor);
  }

  void _handleWorldColorChange(Color newColor) {
    _controlState = ControlPanelState(
      speed: _controlState.speed,
      fontSize: _controlState.fontSize,
      helloColor: _controlState.helloColor,
      worldColor: newColor,
      selectedFontIndex: _controlState.selectedFontIndex,
      isBold: _controlState.isBold,
      drawerSize: _controlState.drawerSize,
    );
    _animationController.updateTextColor(1, newColor);
  }

  void _handleFontChange(int newIndex) {
    _controlState = ControlPanelState(
      speed: _controlState.speed,
      fontSize: _controlState.fontSize,
      helloColor: _controlState.helloColor,
      worldColor: _controlState.worldColor,
      selectedFontIndex: newIndex,
      isBold: _controlState.isBold,
      drawerSize: _controlState.drawerSize,
    );
    _updateTextConfig();
  }

  void _handleBoldChange(bool newBold) {
    _controlState = ControlPanelState(
      speed: _controlState.speed,
      fontSize: _controlState.fontSize,
      helloColor: _controlState.helloColor,
      worldColor: _controlState.worldColor,
      selectedFontIndex: _controlState.selectedFontIndex,
      isBold: newBold,
      drawerSize: _controlState.drawerSize,
    );
    _updateTextConfig();
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
    final textConfig = TextConfig(
      fontSize: _controlState.fontSize,
      fontFamily: ControlPanelConfig.fontOptions[_controlState.selectedFontIndex],
      isBold: _controlState.isBold,
    );
    
    // Only update the text config, don't trigger repositioning during reset
    if (!_isResetting) {
      _animationController.updateTextConfig(textConfig);
    } else {
      // During reset, just update the internal config without triggering callbacks
      _animationController.updateTextConfigSilent(textConfig);
    }
  }

  void _initializeTextWithSize(Size screenSize) {
    final textConfig = TextConfig(
      fontSize: _controlState.fontSize,
      fontFamily: ControlPanelConfig.fontOptions[_controlState.selectedFontIndex],
      isBold: _controlState.isBold,
    );

    final helloSize = TextUtils.measureText('Hello', textConfig.textStyle);
    final worldSize = TextUtils.measureText('World!', textConfig.textStyle);

    final positions = TextUtils.calculateCenteredPositions(
      screenSize: screenSize,
      helloSize: helloSize,
      worldSize: worldSize,
    );

    final textWidgets = [
      TextProperties(
        x: positions['hello_x']!,
        y: positions['hello_y']!,
        dx: 0,
        dy: 0,
        text: 'Hello',
        color: _controlState.helloColor,
      ),
      TextProperties(
        x: positions['world_x']!,
        y: positions['world_y']!,
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
  }

  void _repositionTextWithSize(Size screenSize) {
    final textConfig = TextConfig(
      fontSize: _controlState.fontSize,
      fontFamily: ControlPanelConfig.fontOptions[_controlState.selectedFontIndex],
      isBold: _controlState.isBold,
    );
    
    final helloSize = TextUtils.measureText('Hello', textConfig.textStyle);
    final worldSize = TextUtils.measureText('World!', textConfig.textStyle);
    
    final positions = TextUtils.calculateCenteredPositions(
      screenSize: screenSize,
      helloSize: helloSize,
      worldSize: worldSize,
    );
    
    // Update existing text widget positions
    if (_animationController.textWidgets.length >= 2) {
      _animationController.textWidgets[0].x = positions['hello_x']!;
      _animationController.textWidgets[0].y = positions['hello_y']!;
      _animationController.textWidgets[1].x = positions['world_x']!;
      _animationController.textWidgets[1].y = positions['world_y']!;
      
      // Force a UI update
      setState(() {});
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
    final textConfig = TextConfig(
      fontSize: _controlState.fontSize,
      fontFamily: ControlPanelConfig.fontOptions[_controlState.selectedFontIndex],
      isBold: _controlState.isBold,
    );

    return _animationController.textWidgets.map((textProps) {
      return MovingTextWidget(
        key: ValueKey('${textProps.text}-${textConfig.fontFamily}-${textConfig.fontSize}-${textConfig.isBold}'),
        textProps: textProps,
        textConfig: textConfig,
      );
    }).toList();
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
    _animationController.dispose();
    _resetAnimationController.dispose();
    _sheetController.dispose();
    _sheetSize.dispose();
    super.dispose();
  }
}
