import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IndoorMapScreen extends StatefulWidget {
  const IndoorMapScreen({super.key});

  @override
  State<IndoorMapScreen> createState() => _IndoorMapScreenState();
}

class _IndoorMapScreenState extends State<IndoorMapScreen> {
  List<List<Offset>> routeSegments = [];
  bool isLoading = true;
  String errorMessage = '';

  // QGIS extent values
  static const double minX = -398.762948004;
  static const double maxX = 1894.154789944;
  static const double minY = -1423.829054721;
  static const double maxY = -18.077619119;

  // PNG dimensions
  static const double mapWidth  = 1069;
  static const double mapHeight = 656;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  Offset _geoToPixel(double geoX, double geoY) {
    final px = (geoX - minX) / (maxX - minX) * mapWidth;
    final py = (1 - (geoY - minY) / (maxY - minY)) * mapHeight;
    return Offset(px, py);
  }

  Future<void> _loadRoute() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final raw = await rootBundle.loadString('assets/map-routes/routes.geojson');
      final data = jsonDecode(raw) as Map<String, dynamic>;
      final features = data['features'] as List<dynamic>;
      final segments = <List<Offset>>[];

      for (final feature in features) {
        final geometry = feature['geometry'] as Map<String, dynamic>;
        final type = geometry['type'] as String;

        if (type == 'LineString') {
          final seg = <Offset>[];
          for (final coord in geometry['coordinates'] as List<dynamic>) {
            final c = coord as List<dynamic>;
            seg.add(_geoToPixel(
              (c[0] as num).toDouble(),
              (c[1] as num).toDouble(),
            ));
          }
          if (seg.isNotEmpty) segments.add(seg);
        } else if (type == 'MultiLineString') {
          for (final line in geometry['coordinates'] as List<dynamic>) {
            final seg = <Offset>[];
            for (final coord in line as List<dynamic>) {
              final c = coord as List<dynamic>;
              seg.add(_geoToPixel(
                (c[0] as num).toDouble(),
                (c[1] as num).toDouble(),
              ));
            }
            if (seg.isNotEmpty) segments.add(seg);
          }
        }
      }

      setState(() {
        routeSegments = segments;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load route data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Museum Indoor Map'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 50),
                      const SizedBox(height: 10),
                      Text(errorMessage,
                          style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _loadRoute,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Stack(
                    children: [
                      Image.asset(
                        'assets/maps/indoor_map.png',
                        width: mapWidth,
                        height: mapHeight,
                        fit: BoxFit.contain,
                      ),
                      CustomPaint(
                        size: const Size(mapWidth, mapHeight),
                        painter: _RoutePainter(routeSegments: routeSegments),
                      ),
                    ],
                  ),
                ),
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<List<Offset>> routeSegments;

  _RoutePainter({required this.routeSegments});

  @override
  void paint(Canvas canvas, Size size) {
    if (routeSegments.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final seg in routeSegments) {
      if (seg.isEmpty) continue;
      final path = Path();
      path.moveTo(seg[0].dx, seg[0].dy);
      for (final point in seg.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_RoutePainter old) => old.routeSegments != routeSegments;
}
