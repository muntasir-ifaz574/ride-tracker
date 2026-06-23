import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../entities/driver.dart';
import '../entities/fare.dart';

abstract class RideRepository {
  Future<Driver> getDriverDetails();

  Future<Fare> getFareDetails();

  Future<List<LatLng>> getRoutePoints();

  Future<int> getEstimatedDurationSeconds();

  Stream<LatLng> streamDriverLocation();
}
