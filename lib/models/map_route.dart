import 'point_of_interest.dart';

class MapRoute {
  final String id;
  final List<PointOfInterest> waypoints;
  final double totalDistance;
  final DateTime createdAt;

  MapRoute({
    required this.id,
    required this.waypoints,
    required this.totalDistance,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PointOfInterest get start => waypoints.first;
  PointOfInterest get end => waypoints.last;
  int get stepCount => waypoints.length;

  bool get isValid => waypoints.length >= 2;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'waypoints': waypoints.map((poi) => poi.toJson()).toList(),
      'totalDistance': totalDistance,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MapRoute copyWith({
    String? id,
    List<PointOfInterest>? waypoints,
    double? totalDistance,
    DateTime? createdAt,
  }) {
    return MapRoute(
      id: id ?? this.id,
      waypoints: waypoints ?? this.waypoints,
      totalDistance: totalDistance ?? this.totalDistance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapRoute && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
