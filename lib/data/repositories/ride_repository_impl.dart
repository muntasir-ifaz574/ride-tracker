import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../domain/entities/driver.dart';
import '../../domain/entities/fare.dart';
import '../../domain/repositories/ride_repository.dart';
import '../datasources/google_directions_datasource.dart';
import '../models/driver_model.dart';
import '../models/fare_model.dart';

final String googleMapsApiKey = dotenv.get('MAPS_API_KEY');

class RideRepositoryImpl implements RideRepository {
  final GoogleDirectionsService _directionsService = GoogleDirectionsService();

  static const LatLng _pickupLatLng = LatLng(23.8729, 90.3917);
  static const LatLng _dropoffLatLng = LatLng(23.8069, 90.3685);

  late final List<LatLng> _fallbackRoutePoints;
  List<LatLng>? _resolvedRoutePoints;
  int? _resolvedDurationSeconds;

  final Map<String, dynamic> _driverData = const {
    'name': 'Kamal Hossain',
    'vehicle': 'White Toyota Axio Gha-12-3456',
    'rating': 4.9,
  };

  final Map<String, dynamic> _fareData = const {
    'estimated': 152.0,
    'currency': 'BDT',
  };

  RideRepositoryImpl() {
    _fallbackRoutePoints = _expandPoints(const [
      _pickupLatLng,
      _dropoffLatLng,
    ], 899);
  }

  List<LatLng> _expandPoints(List<LatLng> points, int stepsPerSegment) {
    final List<LatLng> expanded = [];
    if (points.isEmpty) return expanded;

    expanded.add(points.first);
    for (int i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      for (int step = 1; step <= stepsPerSegment; step++) {
        final double t = step / stepsPerSegment;
        final double lat = start.latitude + (end.latitude - start.latitude) * t;
        final double lng =
            start.longitude + (end.longitude - start.longitude) * t;
        expanded.add(LatLng(lat, lng));
      }
    }
    return expanded;
  }

  @override
  Future<Driver> getDriverDetails() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return DriverModel.fromJson(_driverData);
  }

  @override
  Future<Fare> getFareDetails() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return FareModel.fromJson(_fareData);
  }

  @override
  Future<List<LatLng>> getRoutePoints() async {
    if (_resolvedRoutePoints != null) {
      return _resolvedRoutePoints!;
    }

    try {
      final directions = await _directionsService.getDirections(
        _pickupLatLng,
        _dropoffLatLng,
        googleMapsApiKey,
      );

      if (directions.points.isNotEmpty) {
        _resolvedDurationSeconds = directions.durationSeconds;
        final int targetPoints = (_resolvedDurationSeconds! / 2).round();
        final int segments = directions.points.length - 1;
        final int stepsPerSegment = segments > 0
            ? max(1, (targetPoints / segments).round())
            : 1;
        _resolvedRoutePoints = _expandPoints(
          directions.points,
          stepsPerSegment,
        );
        return _resolvedRoutePoints!;
      }
    } catch (e) {
      debugPrint(
        "Directions API failed/unconfigured. Falling back to high-fidelity predefined route. Error: $e",
      );
    }

    _resolvedDurationSeconds = 1800;
    _resolvedRoutePoints = _fallbackRoutePoints;
    return _resolvedRoutePoints!;
  }

  @override
  Future<int> getEstimatedDurationSeconds() async {
    if (_resolvedDurationSeconds == null) {
      await getRoutePoints();
    }
    return _resolvedDurationSeconds!;
  }

  @override
  Stream<LatLng> streamDriverLocation() async* {
    final List<LatLng> points = _resolvedRoutePoints ?? await getRoutePoints();

    yield points.first;
    for (int i = 1; i < points.length; i++) {
      await Future.delayed(const Duration(seconds: 2));
      yield points[i];
    }
  }
}
