import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../data/repositories/ride_repository_impl.dart';
import '../repositories/ride_repository.dart';
import 'ride_tracking_state.dart';

final rideRepositoryProvider = Provider<RideRepository>((ref) {
  return RideRepositoryImpl();
});

final rideTrackingNotifierProvider =
    NotifierProvider<RideTrackingNotifier, RideTrackingState>(
      RideTrackingNotifier.new,
    );

class RideTrackingNotifier extends Notifier<RideTrackingState> {
  StreamSubscription<LatLng>? _locationSubscription;

  @override
  RideTrackingState build() {
    final repository = ref.read(rideRepositoryProvider);

    _initialize(repository);

    ref.onDispose(() {
      _locationSubscription?.cancel();
    });

    return const RideTrackingState();
  }

  Future<void> _initialize(RideRepository repository) async {
    try {
      final driver = await repository.getDriverDetails();
      final fare = await repository.getFareDetails();
      final routePoints = await repository.getRoutePoints();
      final durationSeconds = await repository.getEstimatedDurationSeconds();
      final initialMinutes = (durationSeconds / 60).round();

      state = state.copyWith(
        driver: driver,
        fare: fare,
        routePoints: routePoints,
        isLoading: false,
        remainingMinutes: initialMinutes,
      );

      _startTracking(repository, initialMinutes);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _startTracking(RideRepository repository, int initialMinutes) {
    _locationSubscription?.cancel();
    _locationSubscription = repository.streamDriverLocation().listen(
      (newLocation) {
        final isLastPoint =
            state.routePoints.isNotEmpty &&
            newLocation == state.routePoints.last;

        int remaining = initialMinutes;
        if (state.routePoints.isNotEmpty) {
          final index = state.routePoints.indexOf(newLocation);
          if (index != -1 && state.routePoints.length > 1) {
            final double progress = index / (state.routePoints.length - 1);
            remaining = (initialMinutes * (1.0 - progress)).round();
          }
        }

        state = state.copyWith(
          currentLocation: newLocation,
          isTripCompleted: isLastPoint,
          remainingMinutes: isLastPoint ? 0 : remaining,
        );
      },
      onDone: () {
        if (state.routePoints.isNotEmpty) {
          state = state.copyWith(
            currentLocation: state.routePoints.last,
            isTripCompleted: true,
            remainingMinutes: 0,
          );
        }
      },
    );
  }
}
