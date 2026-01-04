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

class _IndoorMapScreenState extends State<IndoorMapScreen> {
  // SVG dimensions from viewBox (viewBox="0 0 800 1000")
  static const double svgWidth = 800.0;
  static const double svgHeight = 1000.0;

  // Hardcoded user location (x, y) - coordinates in percentage (0.0 to 1.0)
  // x: 0 = left, 1 = right
  // y: 0 = top, 1 = bottom
  double userX = 0.481; // Entrance (385, 900)
  double userY = 0.900; // Entrance (385, 900)

  // Navigation route - Hall A to Hall B
  List<MapDestination> navigationRoute = [
    // Hall A Points
    MapDestination(name: 'Entrance', x: 0.481, y: 0.900),
    MapDestination(name: 'Hall A Center', x: 0.506, y: 0.880),
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
    MapDestination(name: 'Hall B Entry', x: 0.156, y: 0.780),

    // Hall B Points
    MapDestination(name: 'Hall B Center', x: 0.156, y: 0.650),
    MapDestination(name: 'Hall B Left', x: 0.125, y: 0.650),
    MapDestination(name: 'Hall B End', x: 0.156, y: 0.618),
  ];

  bool showRoute = true;
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Museum Floor Map'),
        actions: [
          IconButton(
            icon: Icon(showRoute ? Icons.route : Icons.route_outlined),
            tooltip: showRoute ? 'Hide Route' : 'Show Route',
            onPressed: () {
              setState(() {
                showRoute = !showRoute;
              });
            },
          ),
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
      body: Column(
        children: [
          // User coordinates display
          // Route info banner
          if (showRoute && navigationRoute.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingMd),
              color: AppColors.accentGold,
              child: Row(
                children: [
                  const Icon(Icons.route,
                    color: AppColors.darkBrown,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Route: ${navigationRoute.map((d) => d.name).join(' → ')}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBrown,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
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

                        // Navigation Route Overlay
                        if (showRoute && routePoints.isNotEmpty)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: NavigationRoutePainter(
                                routePoints: routePoints,
                              ),
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

  NavigationRoutePainter({required this.routePoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (routePoints.length < 2) return;

    // Draw the navigation path
    final pathPaint = Paint()
      ..color = AppColors.accentGold.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outer border for the path (for better visibility)
    final borderPaint = Paint()
      ..color = AppColors.darkBrown.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Dashed line paint for visual effect
    final dashedPaint = Paint()
      ..color = AppColors.primaryBrown
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

    // Draw path through all destinations
    for (int i = 1; i < routePoints.length; i++) {
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

    // Draw direction arrows along the path
    for (int i = 0; i < routePoints.length - 1; i++) {
      final start = Offset(
        routePoints[i].x * size.width,
        routePoints[i].y * size.height,
      );
      final end = Offset(
        routePoints[i + 1].x * size.width,
        routePoints[i + 1].y * size.height,
      );

      // Draw arrow at midpoint
      final midPoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );

      _drawArrow(canvas, start, end, midPoint);
    }

    // Draw dashed line overlay for better visibility
    _drawDashedPath(canvas, path, dashedPaint, size);
  }

  void _drawArrow(Canvas canvas, Offset start, Offset end, Offset position) {
    final paint = Paint()
      ..color = AppColors.darkBrown
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

  @override
  bool shouldRepaint(NavigationRoutePainter oldDelegate) {
    return oldDelegate.routePoints != routePoints;
  }
}

class MapDestination {
  final String name;
  final double x;
  final double y;

  MapDestination({
    required this.name,
    required this.x,
    required this.y,
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
