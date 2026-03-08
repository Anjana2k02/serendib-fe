import 'dart:async';
import 'dart:ui';
import '../models/map_position.dart';

class LocationService {
  StreamController<MapPosition>? _positionController;
  MapPosition? _currentPosition;
  Timer? _simulationTimer;

  Stream<MapPosition> get positionStream {
    _positionController ??= StreamController<MapPosition>.broadcast();
    return _positionController!.stream;
  }

  MapPosition? get currentPosition => _currentPosition;

  void setCurrentPosition(Offset position, {double? heading}) {
    _currentPosition = MapPosition(
      position: position,
      heading: heading,
      accuracy: 2.0,
    );
    _positionController?.add(_currentPosition!);
  }

  void simulateWalkingRoute(List<Offset> waypoints, {
    Duration stepDuration = const Duration(milliseconds: 100),
    int stepsPerSegment = 20,
  }) {
    _simulationTimer?.cancel();

    if (waypoints.length < 2) return;

    int currentSegment = 0;
    int currentStep = 0;

    _simulationTimer = Timer.periodic(stepDuration, (timer) {
      if (currentSegment >= waypoints.length - 1) {
        timer.cancel();
        return;
      }

      final start = waypoints[currentSegment];
      final end = waypoints[currentSegment + 1];

      final t = currentStep / stepsPerSegment;
      final interpolatedX = start.dx + (end.dx - start.dx) * t;
      final interpolatedY = start.dy + (end.dy - start.dy) * t;

      final heading = _calculateHeading(start, end);

      setCurrentPosition(
        Offset(interpolatedX, interpolatedY),
        heading: heading,
      );

      currentStep++;

      if (currentStep > stepsPerSegment) {
        currentSegment++;
        currentStep = 0;
      }
    });
  }

  double _calculateHeading(Offset from, Offset to) {
    final dx = to.dx - from.dx;
    final dy = to.dy - from.dy;
    return (dy != 0 || dx != 0) ? (180 / 3.14159) * (dy.sign * (3.14159 / 2) - (dx != 0 ? (dy / dx).sign * (3.14159 / 2 - (dy / dx).abs().clamp(0, 1)) : 0)) : 0.0;
  }

  void stopSimulation() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  void clearPosition() {
    _currentPosition = null;
    stopSimulation();
  }

  void dispose() {
    _simulationTimer?.cancel();
    _positionController?.close();
  }
}
