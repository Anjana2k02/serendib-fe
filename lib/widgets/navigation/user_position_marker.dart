import 'package:flutter/material.dart';
import '../../models/map_position.dart';
import '../../core/theme/app_colors.dart';

class UserPositionMarker extends StatefulWidget {
  final MapPosition position;

  const UserPositionMarker({super.key, required this.position});

  @override
  State<UserPositionMarker> createState() => _UserPositionMarkerState();
}

class _UserPositionMarkerState extends State<UserPositionMarker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.x - 25,
      top: widget.position.y - 25,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 50 + (_pulseController.value * 20),
                height: 50 + (_pulseController.value * 20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.2 * (1 - _pulseController.value)),
                ),
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue.withOpacity(0.3),
                  border: Border.all(
                    color: Colors.white,
                    width: 3,
                  ),
                ),
              ),
              Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
              ),
              if (widget.position.heading != null)
                Transform.rotate(
                  angle: (widget.position.heading! * 3.14159) / 180,
                  child: CustomPaint(
                    size: const Size(30, 30),
                    painter: _DirectionArrowPainter(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DirectionArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(size.width / 2 - 5, 10)
      ..lineTo(size.width / 2 + 5, 10)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_DirectionArrowPainter oldDelegate) => false;
}
