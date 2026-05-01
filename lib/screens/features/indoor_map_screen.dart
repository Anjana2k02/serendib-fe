import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/dev_options_provider.dart';
import '../../providers/artifact_provider.dart';
import '../../widgets/category_artifacts_sheet.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------
class _MapLocation {
  final int id;
  final String name;
  final double px;
  final double py;
  const _MapLocation({required this.id, required this.name, required this.px, required this.py});
}

class IndoorMapScreen extends StatefulWidget {
  const IndoorMapScreen({super.key});

  @override
  State<IndoorMapScreen> createState() => _IndoorMapScreenState();
}

class _IndoorMapScreenState extends State<IndoorMapScreen> {
  static const double _minMapScale = 0.3;
  static const double _maxMapScale = 5.0;

  final TransformationController _transformationController =
      TransformationController();

  List<List<Offset>> routeSegments = [];
  List<_MapLocation> _locations = [];

  bool isLoading = true;
  String errorMessage = '';
  bool _hasInitializedMapView = false;

  // Tap detection inside InteractiveViewer
  Offset? _interactionStartFocalPoint;
  bool _isInteractionPan = false;

  // QGIS extent
  static const double minX = -398.762948004;
  static const double maxX = 1894.154789944;
  static const double minY = -1423.829054721;
  static const double maxY = -18.077619119;

  // PNG dimensions
  static const double mapWidth  = 940;
  static const double mapHeight = 1281;

  @override
  void initState() {
    super.initState();
    _loadAll();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ArtifactProvider>();
      if (provider.artifacts.isEmpty && !provider.isLoading) {
        provider.fetchArtifacts();
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Tap detection via InteractiveViewer interaction callbacks
  // -------------------------------------------------------------------------
  void _onInteractionStart(ScaleStartDetails details) {
    _interactionStartFocalPoint = details.focalPoint;
    _isInteractionPan = false;
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (details.focalPointDelta.distance > 6.0 ||
        (details.scale - 1.0).abs() > 0.02) {
      _isInteractionPan = true;
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (!_isInteractionPan && _interactionStartFocalPoint != null) {
      _handleMapTap(_interactionStartFocalPoint!);
    }
    _interactionStartFocalPoint = null;
    _isInteractionPan = false;
  }

  void _handleMapTap(Offset globalFocalPoint) {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return;

    // Convert from global screen coords → local widget coords → map coords
    final localPos = box.globalToLocal(globalFocalPoint);
    final matrix = _transformationController.value;
    final inverse = Matrix4.inverted(matrix);
    final mapPos = MatrixUtils.transformPoint(inverse, localPos);

    // Hit-test: find first artifact marker within 22 px radius
    const double hitRadius = 22.0;
    for (final loc in _locations) {
      final dx = loc.px - mapPos.dx;
      final dy = loc.py - mapPos.dy;
      if (dx * dx + dy * dy <= hitRadius * hitRadius) {
        if (_isArtifactLocation(loc.name)) {
          final artifacts = context
              .read<ArtifactProvider>()
              .getArtifactsForLocation(loc.name);
          showCategoryArtifactsSheet(context, loc.name, artifacts);
        }
        return;
      }
    }
  }

  Offset _geoToPixel(double geoX, double geoY) {
    final px = (geoX - minX) / (maxX - minX) * mapWidth;
    final py = (1 - (geoY - minY) / (maxY - minY)) * mapHeight;
    return Offset(px, py);
  }

  Future<void> _loadAll() async {
    setState(() { isLoading = true; errorMessage = ''; });
    try {
      await Future.wait([_loadRoutes(), _loadLocations()]);
      setState(() => isLoading = false);
    } catch (e) {
      setState(() { errorMessage = 'Failed to load map data: $e'; isLoading = false; });
    }
  }

  Future<void> _loadRoutes() async {
    final raw = await rootBundle.loadString('assets/map-routes/routes.geojson');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>;
    final segments = <List<Offset>>[];

    for (final feature in features) {
      final geometry = feature['geometry'] as Map<String, dynamic>;
      final type = geometry['type'] as String;

      List<List<dynamic>> lines = [];
      if (type == 'LineString') {
        lines = [geometry['coordinates'] as List<dynamic>];
      } else if (type == 'MultiLineString') {
        lines = (geometry['coordinates'] as List<dynamic>).map((l) => l as List<dynamic>).toList();
      }

      for (final line in lines) {
        final seg = <Offset>[];
        for (final coord in line) {
          final c = coord as List<dynamic>;
          seg.add(_geoToPixel((c[0] as num).toDouble(), (c[1] as num).toDouble()));
        }
        if (seg.isNotEmpty) segments.add(seg);
      }
    }

    routeSegments = segments;
  }

  Future<void> _loadLocations() async {
    final raw = await rootBundle.loadString('assets/map-routes/location.geojson');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final features = data['features'] as List<dynamic>;
    final locs = <_MapLocation>[];

    for (final feature in features) {
      final props = feature['properties'] as Map<String, dynamic>;
      final coords = (feature['geometry']['coordinates'] as List<dynamic>);
      final p = _geoToPixel((coords[0] as num).toDouble(), (coords[1] as num).toDouble());
      locs.add(_MapLocation(
        id: (props['id'] as num).toInt(),
        name: props['name'] as String,
        px: p.dx,
        py: p.dy,
      ));
    }

    _locations = locs;
  }

  void _scheduleInitialMapView(Size viewportSize) {
    if (_hasInitializedMapView ||
        viewportSize.width <= 0 ||
        viewportSize.height <= 0) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _hasInitializedMapView) return;

      final fitScale = min(
        viewportSize.width / mapWidth,
        viewportSize.height / mapHeight,
      );
      final initialScale = min(1.0, max(_minMapScale, fitScale));
      final dx = (viewportSize.width - mapWidth * initialScale) / 2;
      final dy = (viewportSize.height - mapHeight * initialScale) / 2;

      _transformationController.value = Matrix4.identity()
        ..setTranslationRaw(dx, dy, 0.0)
        ..scaleByDouble(initialScale, initialScale, 1.0, 1.0);

      _hasInitializedMapView = true;
    });
  }

  // -------------------------------------------------------------------------
  // Icon per location name
  // -------------------------------------------------------------------------
  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('entrance')) return Icons.login;
    if (n.contains('exit')) return Icons.logout;
    if (n.contains('toilet') || n.contains('wc')) return Icons.wc;
    if (n.contains('rest')) return Icons.chair;
    if (n.contains('outdoor')) return Icons.park;
    if (n.contains('gallery') || n.contains('art')) return Icons.museum;
    if (n.contains('crown') || n.contains('royal')) return Icons.workspace_premium;
    if (n.contains('coin')) return Icons.monetization_on;
    if (n.contains('cloth')) return Icons.checkroom;
    if (n.contains('statue') || n.contains('skulture')) return Icons.accessibility_new;
    if (n.contains('mask')) return Icons.theater_comedy;
    if (n.contains('weapon') || n.contains('sword') || n.contains('wepon')) return Icons.gavel;
    if (n.contains('pottery')) return Icons.emoji_food_beverage;
    return Icons.place;
  }

  Color _colorFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('entrance') || n.contains('exit')) return Colors.green.shade700;
    if (n.contains('toilet') || n.contains('rest')) return Colors.blue.shade600;
    if (n.contains('outdoor')) return Colors.teal.shade600;
    return const Color(0xFF6D4C41); // brown for artifacts
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final devOptions = context.watch<DevOptionsProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Museum Indoor Map'),
        bottom: devOptions.developerOptionsEnabled
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: _buildDevBar(devOptions),
              )
            : null,
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
                      Text(errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton(onPressed: _loadAll, child: const Text('Retry')),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    _scheduleInitialMapView(constraints.biggest);

                    return InteractiveViewer(
                      transformationController: _transformationController,
                      constrained: false,
                      minScale: _minMapScale,
                      maxScale: _maxMapScale,
                      onInteractionStart: _onInteractionStart,
                      onInteractionUpdate: _onInteractionUpdate,
                      onInteractionEnd: _onInteractionEnd,
                      child: SizedBox(
                        width: mapWidth,
                        height: mapHeight,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // PNG map
                            Image.asset(
                              'assets/maps/indoor_map.png',
                              width: mapWidth,
                              height: mapHeight,
                              fit: BoxFit.fill,
                            ),
                            // Dashed route network
                            CustomPaint(
                              size: const Size(mapWidth, mapHeight),
                              painter: _NetworkPainter(routeSegments: routeSegments),
                            ),
                            // Location markers
                            ..._locations.map((loc) => _buildLocationMarker(loc)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  bool _isArtifactLocation(String name) {
    final n = name.toLowerCase();
    return !n.contains('entrance') &&
        !n.contains('exit') &&
        !n.contains('toilet') &&
        !n.contains('wc') &&
        !n.contains('rest') &&
        !n.contains('outdoor');
  }

  Widget _buildLocationMarker(_MapLocation loc) {
    final color = _colorFor(loc.name);
    final icon  = _iconFor(loc.name);
    final isArtifact = _isArtifactLocation(loc.name);

    return Positioned(
      left: loc.px - 14,
      top:  loc.py - 14,
      child: Opacity(
        opacity: isArtifact ? 1.0 : 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Text(
                loc.name,
                style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDevBar(DevOptionsProvider devOptions) {
    const labelStyle = TextStyle(color: Colors.white70, fontSize: 11);
    const dropdownStyle = TextStyle(color: Colors.white, fontSize: 12);

    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          const Text('Loc:', style: labelStyle),
          const SizedBox(width: 4),
          DropdownButton<String>(
            value: devOptions.selectedLocation,
            isDense: true,
            dropdownColor: Colors.brown.shade800,
            style: dropdownStyle,
            underline: const SizedBox.shrink(),
            iconEnabledColor: Colors.white70,
            items: DevOptionsProvider.locations
                .map((l) => DropdownMenuItem(value: l, child: Text(l, style: dropdownStyle)))
                .toList(),
            onChanged: (v) {
              if (v != null) context.read<DevOptionsProvider>().setSelectedLocation(v);
            },
          ),
          const SizedBox(width: 16),
          const Text('Activity:', style: labelStyle),
          const SizedBox(width: 4),
          DropdownButton<String>(
            value: devOptions.selectedActivity,
            isDense: true,
            dropdownColor: Colors.brown.shade800,
            style: dropdownStyle,
            underline: const SizedBox.shrink(),
            iconEnabledColor: Colors.white70,
            items: DevOptionsProvider.activities
                .map((a) => DropdownMenuItem(value: a, child: Text(a, style: dropdownStyle)))
                .toList(),
            onChanged: (v) {
              if (v != null) context.read<DevOptionsProvider>().setSelectedActivity(v);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------
class _NetworkPainter extends CustomPainter {
  final List<List<Offset>> routeSegments;
  _NetworkPainter({required this.routeSegments});

  @override
  void paint(Canvas canvas, Size size) {
    if (routeSegments.isEmpty) return;
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.55)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (final seg in routeSegments) {
      if (seg.isEmpty) continue;
      final path = Path()..moveTo(seg[0].dx, seg[0].dy);
      for (final pt in seg.skip(1)) { path.lineTo(pt.dx, pt.dy); }
      _drawDashed(canvas, path, paint);
    }
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dash = 7.0, gap = 5.0;
    for (final m in path.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        canvas.drawPath(m.extractPath(d, (d + dash).clamp(0.0, m.length)), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_NetworkPainter old) => old.routeSegments != routeSegments;
}
