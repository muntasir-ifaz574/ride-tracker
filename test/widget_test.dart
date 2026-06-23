import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ridetracker/main.dart';
import 'package:ridetracker/domain/entities/driver.dart';
import 'package:ridetracker/domain/entities/fare.dart';
import 'package:ridetracker/domain/repositories/ride_repository.dart';
import 'package:ridetracker/domain/state/ride_tracking_notifier.dart';

class MockRideRepository implements RideRepository {
  @override
  Future<Driver> getDriverDetails() async {
    return const Driver(
      name: 'Kamal Hossain',
      vehicle: 'White Toyota Axio Gha-12-3456',
      rating: 4.9,
    );
  }

  @override
  Future<Fare> getFareDetails() async {
    return const Fare(estimated: 152.0, currency: 'BDT');
  }

  @override
  Future<List<LatLng>> getRoutePoints() async {
    return const [LatLng(23.8729, 90.3917), LatLng(23.8069, 90.3685)];
  }

  @override
  Future<int> getEstimatedDurationSeconds() async {
    return 1800;
  }

  @override
  Stream<LatLng> streamDriverLocation() async* {
    yield const LatLng(23.8729, 90.3917);
    yield const LatLng(23.8069, 90.3685);
  }
}

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          rideRepositoryProvider.overrideWithValue(MockRideRepository()),
        ],
        child: const RideTrackerApp(),
      ),
    );

    expect(find.text('Initializing tracking feed...'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 5));
  });
}
