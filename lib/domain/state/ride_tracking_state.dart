import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../entities/driver.dart';
import '../entities/fare.dart';

class RideTrackingState {
  final Driver? driver;
  final Fare? fare;
  final List<LatLng> routePoints;
  final LatLng? currentLocation;
  final bool isTripCompleted;
  final bool isLoading;
  final int remainingMinutes;

  const RideTrackingState({
    this.driver,
    this.fare,
    this.routePoints = const [],
    this.currentLocation,
    this.isTripCompleted = false,
    this.isLoading = true,
    this.remainingMinutes = 30,
  });

  RideTrackingState copyWith({
    Driver? driver,
    Fare? fare,
    List<LatLng>? routePoints,
    LatLng? currentLocation,
    bool? isTripCompleted,
    bool? isLoading,
    int? remainingMinutes,
  }) {
    return RideTrackingState(
      driver: driver ?? this.driver,
      fare: fare ?? this.fare,
      routePoints: routePoints ?? this.routePoints,
      currentLocation: currentLocation ?? this.currentLocation,
      isTripCompleted: isTripCompleted ?? this.isTripCompleted,
      isLoading: isLoading ?? this.isLoading,
      remainingMinutes: remainingMinutes ?? this.remainingMinutes,
    );
  }
}
