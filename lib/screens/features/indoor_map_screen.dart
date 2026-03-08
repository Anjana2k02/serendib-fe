import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

class IndoorMapScreen extends StatefulWidget {
  const IndoorMapScreen({super.key});

  @override
  State<IndoorMapScreen> createState() => _IndoorMapScreenState();
}

class _IndoorMapScreenState extends State<IndoorMapScreen> with TickerProviderStateMixin {
  // SVG dimensions from viewBox (viewBox="0 0 800 1000")
  static const double svgWidth = 800.0;
  static const double svgHeight = 1000.0;

  // Hardcoded user location (x, y) - coordinates in percentage (0.0 to 1.0)
  // x: 0 = left, 1 = right
  // y: 0 = top, 1 = bottom
  double userX = 0.481; // Entrance (385, 900)
  double userY = 0.900; // Entrance (385, 900)

  // Navigation route - Starting from user location (Entrance) to Hall B
  // User location at (0.481, 0.900) is the starting point
  List<MapDestination> navigationRoute = [
    // Hall A Points (from entrance)
    MapDestination(
      name: 'Hall A Center',
      x: 0.506,
      y: 0.880,
      isSpecial: true,
      artifactName: 'Golden Crown',
    ), // Special Point 1
    MapDestination(name: 'Hall A Right', x: 0.556, y: 0.880),
    MapDestination(name: 'Hall A Right Up', x: 0.588, y: 0.848),

    // Hall A Left Side Points
    MapDestination(name: 'Hall A Left', x: 0.431, y: 0.880),
    MapDestination(name: 'Hall A Left Up', x: 0.430, y: 0.830),
    MapDestination(name: 'Hall A Left Turn', x: 0.350, y: 0.880),

    // Path to Hall B
    MapDestination(name: 'Path Start', x: 0.281, y: 0.880),
    MapDestination(name: 'Path Turn 1', x: 0.281, y: 0.800),
    MapDestination(name: 'Path Turn 2', x: 0.238, y: 0.800),
    MapDestination(name: 'Path Turn 3', x: 0.238, y: 0.780),
    MapDestination(
      name: 'Hall B Entry',
      x: 0.156,
      y: 0.780,
      isSpecial: true,
      artifactName: 'Dadigama Pahana',
    ), // Special Point 2

    // Hall B Points
    MapDestination(name: 'Hall B Center', x: 0.156, y: 0.650),
    MapDestination(name: 'Hall B Left', x: 0.125, y: 0.650),
    MapDestination(
      name: 'Hall B End',
      x: 0.156,
      y: 0.618,
      isSpecial: true,
      artifactName: 'Gems',
    ), // Special Point 3 (Final)
  ];

  bool showRoute = false; // Start with route hidden
  bool isTourStarted = false;
  final TransformationController _transformationController = TransformationController();

  late AnimationController _routeAnimationController;
  late AnimationController _pulseAnimationController;
  late AnimationController _popupAnimationController;
  late Animation<double> _routeAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _popupAnimation;

  MapDestination? selectedArtifact;
  bool showPopup = false;

  @override
  void initState() {
    super.initState();

    // Route appearance animation
    _routeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _routeAnimation = CurvedAnimation(
      parent: _routeAnimationController,
      curve: Curves.easeInOut,
    );

    // Button pulse animation
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Popup animation
    _popupAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _popupAnimation = CurvedAnimation(
      parent: _popupAnimationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _routeAnimationController.dispose();
    _pulseAnimationController.dispose();
    _popupAnimationController.dispose();
    super.dispose();
  }

  void _showArtifactPopup(MapDestination destination) {
    setState(() {
      selectedArtifact = destination;
      showPopup = true;
    });
    _popupAnimationController.forward();
  }

  void _hideArtifactPopup() {
    _popupAnimationController.reverse().then((_) {
      setState(() {
        showPopup = false;
        selectedArtifact = null;
      });
    });
  }

  void _startAITour() {
    setState(() {
      showRoute = true;
      isTourStarted = true;
    });
    _routeAnimationController.forward();
    _pulseAnimationController.stop();
  }

  void _stopAITour() {
    setState(() {
      showRoute = false;
      isTourStarted = false;
    });
    _routeAnimationController.reverse();
    _pulseAnimationController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Museum Floor Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_out_map),
            tooltip: 'Reset Zoom',
            onPressed: () {
              _transformationController.value = Matrix4.identity();
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showMapInfo(context);
            },
          ),
        ],
      ),
      floatingActionButton: !isTourStarted
          ? ScaleTransition(
              scale: _pulseAnimation,
              child: FloatingActionButton.extended(
                onPressed: _startAITour,
                backgroundColor: AppColors.accentGold,
                icon: const Icon(Icons.explore, color: AppColors.darkBrown),
                label: const Text(
                  'Start AI Tour',
                  style: TextStyle(
                    color: AppColors.darkBrown,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            )
          : FloatingActionButton(
              onPressed: _stopAITour,
              backgroundColor: AppColors.error,
              child: const Icon(Icons.stop, color: Colors.white),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Column(
        children: [
          // Route info banner with animation
          if (showRoute && navigationRoute.isNotEmpty)
            AnimatedBuilder(
              animation: _routeAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, -1),
                    end: Offset.zero,
                  ).animate(_routeAnimation),
                  child: FadeTransition(
                    opacity: _routeAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(AppConstants.spacingMd),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.accentGold,
                            AppColors.accentGold.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.explore,
                            color: AppColors.darkBrown,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'AI Tour Active',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.darkBrown,
                                      ),
                                ),
                                Text(
                                  'Follow the golden path through ${navigationRoute.length} points',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppColors.darkBrown.withValues(alpha: 0.8),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          // Map view with SVG
          Expanded(
            child: Container(
              color: AppColors.background,
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Build the complete route path (user -> destinations)
                  final List<MapPoint> routePoints = [];
                  if (showRoute && navigationRoute.isNotEmpty) {
                    routePoints.add(MapPoint(x: userX, y: userY)); // Start from user
                    for (var dest in navigationRoute) {
                      routePoints.add(MapPoint(x: dest.x, y: dest.y));
                    }
                  }

                  return InteractiveViewer(
                    transformationController: _transformationController,
                    minScale: 0.5,
                    maxScale: 4.0,
                    boundaryMargin: const EdgeInsets.all(double.infinity),
                    child: Stack(
                      children: [
                        // SVG Floor Map
                        SvgPicture.asset(
                          'assets/maps/map.svg',
                          width: constraints.maxWidth,
                          height: constraints.maxHeight,
                          fit: BoxFit.contain,
                          placeholderBuilder: (context) => const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primaryBrown,
                            ),
                          ),
                        ),

                        // Navigation Route Overlay with Animation
                        if (showRoute && routePoints.isNotEmpty)
                          Positioned.fill(
                            child: AnimatedBuilder(
                              animation: _routeAnimation,
                              builder: (context, child) {
                                return FadeTransition(
                                  opacity: _routeAnimation,
                                  child: ScaleTransition(
                                    scale: Tween<double>(begin: 0.8, end: 1.0).animate(_routeAnimation),
                                    child: CustomPaint(
                                      painter: NavigationRoutePainter(
                                        routePoints: routePoints,
                                        destinations: navigationRoute,
                                        animationProgress: _routeAnimation.value,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                        // User location indicator
                        Positioned(
                          left: userX * constraints.maxWidth - 12,
                          top: userY * constraints.maxHeight - 12,
                          child: const Icon(
                            Icons.navigation,
                            color: Colors.red,
                            size: 24,
                            shadows: [
                              Shadow(
                                color: Colors.black38,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),

                        // Interactive tap areas for special points
                        if (showRoute)
                          ...navigationRoute
                              .where((dest) => dest.isSpecial)
                              .map((dest) => Positioned(
                                    left: dest.x * constraints.maxWidth - 20,
                                    top: dest.y * constraints.maxHeight - 20,
                                    child: GestureDetector(
                                      onTap: () => _showArtifactPopup(dest),
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        color: Colors.transparent,
                                      ),
                                    ),
                                  )),

                        // Artifact popup
                        if (showPopup && selectedArtifact != null)
                          Positioned(
                            left: selectedArtifact!.x * constraints.maxWidth - 75,
                            top: selectedArtifact!.y * constraints.maxHeight - 100,
                            child: AnimatedBuilder(
                              animation: _popupAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _popupAnimation.value,
                                  child: FadeTransition(
                                    opacity: _popupAnimation,
                                    child: _buildArtifactPopup(selectedArtifact!),
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),

          // SVG Coordinate Info
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingMd,
              vertical: AppConstants.spacingSm,
            ),
            color: AppColors.creamWhite,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'SVG: ${svgWidth.toStringAsFixed(0)}x${svgHeight.toStringAsFixed(0)} | '
                  'Position: (${(userX * svgWidth).toStringAsFixed(1)}, ${(userY * svgHeight).toStringAsFixed(1)})',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          // Quick location buttons for testing
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            color: AppColors.background,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildLocationButton('Top Left', 0.15, 0.15),
                _buildLocationButton('Top Center', 0.5, 0.15),
                _buildLocationButton('Top Right', 0.85, 0.15),
                _buildLocationButton('Middle Left', 0.15, 0.5),
                _buildLocationButton('Center', 0.5, 0.5),
                _buildLocationButton('Middle Right', 0.85, 0.5),
                _buildLocationButton('Bottom Left', 0.15, 0.85),
                _buildLocationButton('Bottom Center', 0.5, 0.85),
                _buildLocationButton('Bottom Right', 0.85, 0.85),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationButton(String label, double x, double y) {
    final isActive = (userX - x).abs() < 0.01 && (userY - y).abs() < 0.01;

    return ElevatedButton(
      onPressed: () {
        setState(() {
          userX = x;
          userY = y;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isActive ? AppColors.primaryBrown : AppColors.creamWhite,
        foregroundColor: isActive ? AppColors.offWhite : AppColors.primaryBrown,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        minimumSize: const Size(0, 36),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  Widget _buildArtifactPopup(MapDestination destination) {
    return GestureDetector(
      onTap: _hideArtifactPopup,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.accentGold,
              AppColors.accentGold.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Star icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkBrown.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.star,
                color: AppColors.darkBrown,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            // Artifact name
            Text(
              destination.artifactName ?? 'Artifact',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.darkBrown,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            // Location name
            Text(
              destination.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.darkBrown.withValues(alpha: 0.7),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 8),
            // Tap to close hint
            Text(
              'Tap to close',
              style: TextStyle(
                color: AppColors.darkBrown.withValues(alpha: 0.5),
                fontSize: 9,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMapInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Museum Floor Map'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Navigation Controls:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Pinch to zoom in/out'),
              const Text('• Drag to pan around'),
              const Text('• Tap "Reset Zoom" to reset view'),
              const SizedBox(height: 16),
              const Text(
                'Map Information:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Red marker shows your current location'),
              const Text('• Numbered markers show navigation waypoints'),
              const Text('• Golden line shows navigation route'),
              const SizedBox(height: 16),
              const Text(
                'SVG Coordinates:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• SVG Size: ${svgWidth.toStringAsFixed(1)} x ${svgHeight.toStringAsFixed(1)}'),
              Text('• Your Position: (${(userX * svgWidth).toStringAsFixed(1)}, ${(userY * svgHeight).toStringAsFixed(1)})'),
              const SizedBox(height: 8),
              const Text(
                'Coordinates use percentage (0.0 to 1.0):',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Text(
                '• x: 0 = left, 1 = right',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const Text(
                '• y: 0 = top, 1 = bottom',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class NavigationRoutePainter extends CustomPainter {
  final List<MapPoint> routePoints;
  final List<MapDestination> destinations;
  final double animationProgress;

  NavigationRoutePainter({
    required this.routePoints,
    required this.destinations,
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (routePoints.length < 2) return;

    // Calculate how many points to draw based on animation progress
    final int pointsToShow = (routePoints.length * animationProgress).ceil().clamp(2, routePoints.length);

    // Draw the navigation path
    final pathPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.8 * animationProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer border for the path (for better visibility)
    final borderPaint = Paint()
      ..color = AppColors.darkBrown.withValues(alpha: 0.3 * animationProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dashed line paint for visual effect
    final dashedPaint = Paint()
      ..color = AppColors.primaryBrown.withValues(alpha: animationProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final borderPath = Path();

    // Start from user location
    final startPoint = Offset(
      routePoints[0].x * size.width,
      routePoints[0].y * size.height,
    );
    path.moveTo(startPoint.dx, startPoint.dy);
    borderPath.moveTo(startPoint.dx, startPoint.dy);

    // Draw path through destinations (only up to pointsToShow)
    for (int i = 1; i < pointsToShow; i++) {
      final point = Offset(
        routePoints[i].x * size.width,
        routePoints[i].y * size.height,
      );
      path.lineTo(point.dx, point.dy);
      borderPath.lineTo(point.dx, point.dy);
    }

    // Draw the path with border first
    canvas.drawPath(borderPath, borderPaint);
    canvas.drawPath(path, pathPaint);

    // Draw direction arrows along the path (only for visible segments)
    for (int i = 0; i < pointsToShow - 1; i++) {
      final start = Offset(
        routePoints[i].x * size.width,
        routePoints[i].y * size.height,
      );
      final end = Offset(
        routePoints[i + 1].x * size.width,
        routePoints[i + 1].y * size.height,
      );

      // Draw arrow at midpoint with animation opacity
      final midPoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );

      _drawArrow(canvas, start, end, midPoint, animationProgress);
    }

    // Draw dashed line overlay for better visibility
    _drawDashedPath(canvas, path, dashedPaint, size);

    // Draw special point markers
    for (int i = 0; i < destinations.length; i++) {
      if (destinations[i].isSpecial && i + 1 < pointsToShow) {
        final point = Offset(
          destinations[i].x * size.width,
          destinations[i].y * size.height,
        );
        _drawSpecialMarker(canvas, point, i + 1, animationProgress);
      }
    }
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Offset position, double opacity) {
    final paint = Paint()
      ..color = AppColors.darkBrown.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Calculate arrow direction
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final angle = atan2(dy, dx);

    // Arrow size
    const arrowSize = 5.0;

    final arrowPath = Path();
    arrowPath.moveTo(position.dx, position.dy);
    arrowPath.lineTo(
      position.dx - arrowSize * cos(angle - pi / 6),
      position.dy - arrowSize * sin(angle - pi / 6),
    );
    arrowPath.lineTo(
      position.dx - arrowSize * cos(angle + pi / 6),
      position.dy - arrowSize * sin(angle + pi / 6),
    );
    arrowPath.close();

    canvas.drawPath(arrowPath, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint, Size size) {
    // This creates a subtle dashed effect on top of the solid line
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        const dashLength = 15.0;
        const gapLength = 10.0;

        if (distance + dashLength < metric.length) {
          final start = metric.getTangentForOffset(distance)!.position;
          final end = metric.getTangentForOffset(distance + dashLength)!.position;
          canvas.drawLine(start, end, paint);
        }

        distance += dashLength + gapLength;
      }
    }
  }

  void _drawSpecialMarker(Canvas canvas, Offset position, int number, double opacity) {
    // Outer glow circle (pulsing effect)
    final glowPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.3 * opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 20, glowPaint);

    // Middle circle (border)
    final borderPaint = Paint()
      ..color = AppColors.darkBrown.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
    canvas.drawCircle(position, 14, borderPaint);

    // Inner circle (filled)
    final fillPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, 12, fillPaint);

    // Draw number in the center
    final textPainter = TextPainter(
      text: TextSpan(
        text: number.toString(),
        style: TextStyle(
          color: AppColors.darkBrown.withValues(alpha: opacity),
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );

    // Add small star icon above the circle
    final starPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;
    _drawStar(canvas, Offset(position.dx, position.dy - 22), 6, starPaint);
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Paint paint) {
    const int points = 5;
    final path = Path();
    final double angle = (pi * 2) / points;

    for (int i = 0; i < points * 2; i++) {
      final double r = i.isEven ? radius : radius / 2;
      final double currentAngle = i * angle / 2 - pi / 2;
      final double x = center.dx + r * cos(currentAngle);
      final double y = center.dy + r * sin(currentAngle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(NavigationRoutePainter oldDelegate) {
    return oldDelegate.routePoints != routePoints ||
           oldDelegate.destinations != destinations ||
           oldDelegate.animationProgress != animationProgress;
  }
}

class MapDestination {
  final String name;
  final double x;
  final double y;
  final bool isSpecial; // Highlight special points of interest
  final String? artifactName; // Name of artifact at this location

  MapDestination({
    required this.name,
    required this.x,
    required this.y,
    this.isSpecial = false,
    this.artifactName,
  });
}

class MapPoint {
  final double x;
  final double y;

  MapPoint({required this.x, required this.y});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapPoint &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
