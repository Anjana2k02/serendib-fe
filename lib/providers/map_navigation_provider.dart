import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/point_of_interest.dart';
import '../models/map_route.dart';
import '../models/map_position.dart';
import '../services/pathfinding_service.dart';

class MapNavigationProvider with ChangeNotifier {
  final PathfindingService _pathfindingService = PathfindingService();

  List<PointOfInterest> _pois = [];
  List<PointOfInterest> _filteredPOIs = [];
  PointOfInterest? _selectedPOI;
  MapRoute? _activeRoute;
  MapPosition? _userPosition;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  List<PointOfInterest> get pois => _pois;
  List<PointOfInterest> get filteredPOIs => _filteredPOIs;
  PointOfInterest? get selectedPOI => _selectedPOI;
  MapRoute? get activeRoute => _activeRoute;
  MapPosition? get userPosition => _userPosition;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  bool get isNavigating => _activeRoute != null;

  Map<String, PointOfInterest> get poiMap {
    return {for (var poi in _pois) poi.id: poi};
  }

  Future<void> loadMapData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final String jsonString =
          await rootBundle.loadString('assets/maps/pois.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      _pois = (jsonData['pois'] as List)
          .map((poiJson) => PointOfInterest.fromJson(poiJson))
          .toList();

      _filteredPOIs = _pois;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load map data: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchPOIs(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredPOIs = _pois;
    } else {
      final lowerQuery = query.toLowerCase();
      _filteredPOIs = _pois.where((poi) {
        return poi.name.toLowerCase().contains(lowerQuery) ||
            poi.category.toLowerCase().contains(lowerQuery) ||
            (poi.description?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    }

    notifyListeners();
  }

  void selectPOI(String? poiId) {
    if (poiId == null) {
      _selectedPOI = null;
    } else {
      _selectedPOI = poiMap[poiId];
    }
    notifyListeners();
  }

  Future<bool> calculateRoute(String startId, String endId) async {
    _error = null;
    notifyListeners();

    try {
      final start = poiMap[startId];
      final end = poiMap[endId];

      if (start == null || end == null) {
        _error = 'Invalid start or end location';
        notifyListeners();
        return false;
      }

      final waypoints = _pathfindingService.findRoute(start, end, poiMap);

      if (waypoints.isEmpty) {
        _error = 'No route found between these locations';
        notifyListeners();
        return false;
      }

      double totalDistance = 0.0;
      for (int i = 0; i < waypoints.length - 1; i++) {
        final dx = waypoints[i + 1].position.dx - waypoints[i].position.dx;
        final dy = waypoints[i + 1].position.dy - waypoints[i].position.dy;
        totalDistance += (dx * dx + dy * dy);
      }

      _activeRoute = MapRoute(
        id: '${start.id}_to_${end.id}_${DateTime.now().millisecondsSinceEpoch}',
        waypoints: waypoints,
        totalDistance: totalDistance,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Failed to calculate route: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearRoute() {
    _activeRoute = null;
    notifyListeners();
  }

  void updateUserPosition(MapPosition position) {
    _userPosition = position;
    notifyListeners();
  }

  void clearUserPosition() {
    _userPosition = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredPOIs = _pois;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
