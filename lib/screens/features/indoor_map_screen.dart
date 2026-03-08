import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------
class _Node {
  final String key;
  final double px;
  final double py;
  const _Node(this.key, this.px, this.py);
}

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
  List<List<Offset>> routeSegments = [];
  Map<String, _Node> _nodes = {};
  Map<String, List<_NodeEdge>> _adjacency = {};
  List<_MapLocation> _locations = [];

  _Node? _startNode;
  _Node? _endNode;
  List<Offset> _shortestPath = [];

  bool isLoading = true;
  String errorMessage = '';

  // QGIS extent
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
    _loadAll();
  }

  Offset _geoToPixel(double geoX, double geoY) {
    final px = (geoX - minX) / (maxX - minX) * mapWidth;
    final py = (1 - (geoY - minY) / (maxY - minY)) * mapHeight;
    return Offset(px, py);
  }

  String _nodeKey(double px, double py) => '${px.round()}_${py.round()}';

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
    final nodes = <String, _Node>{};
    final adjacency = <String, List<_NodeEdge>>{};

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
          final p = _geoToPixel((c[0] as num).toDouble(), (c[1] as num).toDouble());
          seg.add(p);
          final key = _nodeKey(p.dx, p.dy);
          nodes.putIfAbsent(key, () => _Node(key, p.dx, p.dy));
        }
        if (seg.isNotEmpty) segments.add(seg);

        for (int i = 0; i < seg.length - 1; i++) {
          final aKey = _nodeKey(seg[i].dx, seg[i].dy);
          final bKey = _nodeKey(seg[i + 1].dx, seg[i + 1].dy);
          if (aKey == bKey) continue;
          final dx = seg[i].dx - seg[i + 1].dx;
          final dy = seg[i].dy - seg[i + 1].dy;
          final w = sqrt(dx * dx + dy * dy);
          adjacency.putIfAbsent(aKey, () => []).add(_NodeEdge(bKey, w));
          adjacency.putIfAbsent(bKey, () => []).add(_NodeEdge(aKey, w));
        }
      }
    }

    routeSegments = segments;
    _nodes = nodes;
    _adjacency = adjacency;
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

  _Node? _nearestNode(Offset tapPx) {
    _Node? best;
    double bestDist = double.infinity;
    for (final n in _nodes.values) {
      final dx = n.px - tapPx.dx;
      final dy = n.py - tapPx.dy;
      final d = dx * dx + dy * dy;
      if (d < bestDist) { bestDist = d; best = n; }
    }
    return best;
  }

  void _selectNode(_Node nearest) {
    setState(() {
      if (_startNode == null) {
        _startNode = nearest;
        _endNode = null;
        _shortestPath = [];
      } else if (_endNode == null) {
        _endNode = nearest;
        _shortestPath = _dijkstra(_startNode!.key, nearest.key);
      } else {
        _startNode = nearest;
        _endNode = null;
        _shortestPath = [];
      }
    });
  }

  void _onMapTap(TapUpDetails details) {
    if (_nodes.isEmpty) return;
    final nearest = _nearestNode(details.localPosition);
    if (nearest != null) _selectNode(nearest);
  }

  void _onLocationTap(_MapLocation loc) {
    final nearest = _nearestNode(Offset(loc.px, loc.py));
    if (nearest != null) _selectNode(nearest);
  }

  List<Offset> _dijkstra(String startKey, String endKey) {
    if (startKey == endKey) {
      final n = _nodes[startKey];
      return n != null ? [Offset(n.px, n.py)] : [];
    }

    final dist = <String, double>{startKey: 0.0};
    final prev = <String, String>{};
    final visited = <String>{};
    final queue = <_DijkstraEntry>[_DijkstraEntry(startKey, 0.0)];

    while (queue.isNotEmpty) {
      queue.sort((a, b) => a.dist.compareTo(b.dist));
      final cur = queue.removeAt(0);
      if (visited.contains(cur.key)) continue;
      visited.add(cur.key);
      if (cur.key == endKey) break;

      for (final edge in _adjacency[cur.key] ?? []) {
        if (visited.contains(edge.toKey)) continue;
        final newDist = (dist[cur.key] ?? double.infinity) + edge.weight;
        if (newDist < (dist[edge.toKey] ?? double.infinity)) {
          dist[edge.toKey] = newDist;
          prev[edge.toKey] = cur.key;
          queue.add(_DijkstraEntry(edge.toKey, newDist));
        }
      }
    }

    if (!prev.containsKey(endKey)) return [];

    final path = <Offset>[];
    String? cur = endKey;
    while (cur != null) {
      final n = _nodes[cur];
      if (n != null) path.insert(0, Offset(n.px, n.py));
      cur = prev[cur];
    }
    return path;
  }

  void _reset() {
    setState(() { _startNode = null; _endNode = null; _shortestPath = []; });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Museum Indoor Map'),
        actions: [
          if (_startNode != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Clear selection',
              onPressed: _reset,
            ),
        ],
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
              : Column(
                  children: [
                    _buildStatusBar(),
                    Expanded(
                      child: InteractiveViewer(
                        constrained: false,
                        minScale: 0.3,
                        maxScale: 5.0,
                        child: GestureDetector(
                          onTapUp: _onMapTap,
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
                                // Shortest path
                                if (_shortestPath.length >= 2)
                                  CustomPaint(
                                    size: const Size(mapWidth, mapHeight),
                                    painter: _ShortestPathPainter(path: _shortestPath),
                                  ),
                                // Location markers
                                ..._locations.map((loc) => _buildLocationMarker(loc)),
                                // Start / end pins
                                if (_startNode != null)
                                  Positioned(
                                    left: _startNode!.px - 12,
                                    top: _startNode!.py - 28,
                                    child: const Icon(Icons.location_on, color: Colors.green, size: 28),
                                  ),
                                if (_endNode != null)
                                  Positioned(
                                    left: _endNode!.px - 12,
                                    top: _endNode!.py - 28,
                                    child: const Icon(Icons.flag, color: Colors.red, size: 28),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildLocationMarker(_MapLocation loc) {
    final color = _colorFor(loc.name);
    final icon  = _iconFor(loc.name);

    return Positioned(
      left: loc.px - 14,
      top:  loc.py - 14,
      child: GestureDetector(
        onTap: () => _onLocationTap(loc),
        child: Opacity(
          opacity: 0.7,
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
      ),
    );
  }

  Widget _buildStatusBar() {
    final String msg;
    if (_startNode == null) {
      msg = 'Tap a location or the map to set start';
    } else if (_endNode == null) {
      msg = 'Now tap a location or map to set destination';
    } else if (_shortestPath.isEmpty) {
      msg = 'No path found — tap to reset';
    } else {
      msg = 'Route found  •  tap map to reset';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.blue.shade50,
      child: Text(msg, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w600)),
    );
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
class _NodeEdge {
  final String toKey;
  final double weight;
  _NodeEdge(this.toKey, this.weight);
}

class _DijkstraEntry {
  final String key;
  final double dist;
  _DijkstraEntry(this.key, this.dist);
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

class _ShortestPathPainter extends CustomPainter {
  final List<Offset> path;
  _ShortestPathPainter({required this.path});

  @override
  void paint(Canvas canvas, Size size) {
    if (path.length < 2) return;
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final p = Path()..moveTo(path[0].dx, path[0].dy);
    for (final pt in path.skip(1)) { p.lineTo(pt.dx, pt.dy); }
    canvas.drawPath(p, paint);
  }

  @override
  bool shouldRepaint(_ShortestPathPainter old) => old.path != path;
}
