import 'package:flutter/material.dart';
import '../../models/map_route.dart';
import '../../core/theme/app_colors.dart';

class RouteOverlay extends StatefulWidget {
  final MapRoute route;

  const RouteOverlay({super.key, required this.route});

  @override
  State<RouteOverlay> createState() => _RouteOverlayState();
}

class _RouteOverlayState extends State<RouteOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(1000, 800),
      painter: _RoutePainter(
        route: widget.route,
        animation: _animationController,
      ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final MapRoute route;
  final Animation<double> animation;

  _RoutePainter({required this.route, required this.animation})
      : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (route.waypoints.length < 2) return;

    final paint = Paint()
      ..color = AppColors.accentGold
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final shadowPaint = Paint()
      ..color = AppColors.darkBrown.withOpacity(0.3)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final shadowPath = Path();

    path.moveTo(route.waypoints.first.position.dx,
        route.waypoints.first.position.dy);
    shadowPath.moveTo(route.waypoints.first.position.dx,
        route.waypoints.first.position.dy);

    for (int i = 1; i < route.waypoints.length; i++) {
      final current = route.waypoints[i - 1].position;
      final next = route.waypoints[i].position;

      final controlPoint1 = Offset(
        current.dx + (next.dx - current.dx) * 0.3,
        current.dy,
      );
      final controlPoint2 = Offset(
        current.dx + (next.dx - current.dx) * 0.7,
        next.dy,
      );

      path.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        next.dx,
        next.dy,
      );

      shadowPath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        next.dx,
        next.dy,
      );
    }

    canvas.drawPath(shadowPath, shadowPaint);
    canvas.drawPath(path, paint);

    _drawArrows(canvas, route);
  }

  void _drawArrows(Canvas canvas, MapRoute route) {
    final arrowPaint = Paint()
      ..color = AppColors.accentGold
      ..style = PaintingStyle.fill;

    for (int i = 0; i < route.waypoints.length - 1; i++) {
      final start = route.waypoints[i].position;
      final end = route.waypoints[i + 1].position;

      final midpoint = Offset(
        (start.dx + end.dx) / 2,
        (start.dy + end.dy) / 2,
      );

      final angle = (end.dy - start.dy) / (end.dx - start.dx);
      final rotation = angle.isFinite ? angle : 0.0;

      canvas.save();
      canvas.translate(midpoint.dx, midpoint.dy);
      canvas.rotate(rotation);

      final arrowPath = Path()
        ..moveTo(0, -5)
        ..lineTo(8, 0)
        ..lineTo(0, 5)
        ..close();

      canvas.drawPath(arrowPath, arrowPaint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_RoutePainter oldDelegate) {
    return oldDelegate.route != route;
  }
}
