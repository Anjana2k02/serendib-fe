import 'dart:ui';

class MapPosition {
  final Offset position;
  final double? heading;
  final double? accuracy;
  final DateTime timestamp;

  MapPosition({
    required this.position,
    this.heading,
    this.accuracy,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  double get x => position.dx;
  double get y => position.dy;

  double distanceTo(MapPosition other) {
    final dx = x - other.x;
    final dy = y - other.y;
    return (dx * dx + dy * dy) * 0.5; // Approximate distance
  }

  factory MapPosition.fromJson(Map<String, dynamic> json) {
    return MapPosition(
      position: Offset(
        (json['x'] as num).toDouble(),
        (json['y'] as num).toDouble(),
      ),
      heading: json['heading'] as double?,
      accuracy: json['accuracy'] as double?,
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'heading': heading,
      'accuracy': accuracy,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  MapPosition copyWith({
    Offset? position,
    double? heading,
    double? accuracy,
    DateTime? timestamp,
  }) {
    return MapPosition(
      position: position ?? this.position,
      heading: heading ?? this.heading,
      accuracy: accuracy ?? this.accuracy,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapPosition &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          timestamp == other.timestamp;

  @override
  int get hashCode => Object.hash(position, timestamp);
}
