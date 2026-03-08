import 'dart:math';

class RouteNode {
  final String key;
  final double geoX;
  final double geoY;

  const RouteNode({required this.key, required this.geoX, required this.geoY});
}

class RouteEdge {
  final String toKey;
  final double weight;

  const RouteEdge({required this.toKey, required this.weight});
}

class GeoBBox {
  final double minX, maxX, minY, maxY;

  const GeoBBox({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  double get width => maxX - minX;
  double get height => (maxY - minY).abs();
}

class RouteGraph {
  final Map<String, RouteNode> nodes;
  final Map<String, List<RouteEdge>> adjacency;

  const RouteGraph({required this.nodes, required this.adjacency});

  bool get isEmpty => nodes.isEmpty;

  /// Find the nearest node to a geo-space coordinate.
  RouteNode? nearestNode(double geoX, double geoY) {
    RouteNode? nearest;
    double bestDist = double.infinity;

    for (final node in nodes.values) {
      final dx = node.geoX - geoX;
      final dy = node.geoY - geoY;
      final dist = sqrt(dx * dx + dy * dy);
      if (dist < bestDist) {
        bestDist = dist;
        nearest = node;
      }
    }

    return nearest;
  }

  /// Run Dijkstra from [startKey] to [endKey].
  /// Returns an ordered list of nodes forming the shortest path, or [] if unreachable.
  List<RouteNode> dijkstra(String startKey, String endKey) {
    if (startKey == endKey) {
      final n = nodes[startKey];
      return n != null ? [n] : [];
    }

    final dist = <String, double>{startKey: 0.0};
    final prev = <String, String>{};
    final visited = <String>{};

    // Simple priority queue using sorted list
    final queue = _PriorityQueue<_DNode>((a, b) => a.dist.compareTo(b.dist));
    queue.add(_DNode(startKey, 0.0));

    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      if (visited.contains(current.key)) continue;
      visited.add(current.key);

      if (current.key == endKey) break;

      final edges = adjacency[current.key] ?? [];
      for (final edge in edges) {
        if (visited.contains(edge.toKey)) continue;
        final newDist = (dist[current.key] ?? double.infinity) + edge.weight;
        if (newDist < (dist[edge.toKey] ?? double.infinity)) {
          dist[edge.toKey] = newDist;
          prev[edge.toKey] = current.key;
          queue.add(_DNode(edge.toKey, newDist));
        }
      }
    }

    if (!prev.containsKey(endKey) && startKey != endKey) return [];

    // Reconstruct path
    final path = <RouteNode>[];
    String? cur = endKey;
    while (cur != null) {
      final node = nodes[cur];
      if (node != null) path.insert(0, node);
      cur = prev[cur];
    }

    return path;
  }
}

class _DNode {
  final String key;
  final double dist;
  _DNode(this.key, this.dist);
}

class _PriorityQueue<T> {
  final List<T> _items = [];
  final Comparator<T> _cmp;

  _PriorityQueue(this._cmp);

  void add(T item) {
    _items.add(item);
    _items.sort(_cmp);
  }

  T removeFirst() => _items.removeAt(0);

  bool get isNotEmpty => _items.isNotEmpty;
}
