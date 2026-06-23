import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../theme/app_colors.dart';

class LiveMapView extends StatefulWidget {
  final List<LatLng> routePoints;
  final LatLng? currentDriverLocation;
  final bool isTripCompleted;

  const LiveMapView({
    super.key,
    required this.routePoints,
    required this.currentDriverLocation,
    required this.isTripCompleted,
  });

  @override
  State<LiveMapView> createState() => _LiveMapViewState();
}

class _LiveMapViewState extends State<LiveMapView>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;

  late final AnimationController _animationController;

  LatLng? _previousDriverPosition;
  LatLng? _targetDriverPosition;
  LatLng? _animatedDriverPosition;

  double _driverRotation = 0.0;
  double _startRotation = 0.0;
  double _targetRotation = 0.0;

  bool _isCameraLocked = true;

  int _lastUpdateMillis = 0;

  BitmapDescriptor _driverIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueAzure,
  );

  late final ValueNotifier<Set<Marker>> _markersNotifier;

  late final CameraPosition _initialCameraPosition;
  late final Set<Polyline> _polylines;
  late final Marker _pickupMarker;
  late final Marker _dropoffMarker;

  @override
  void initState() {
    super.initState();

    _markersNotifier = ValueNotifier<Set<Marker>>({});

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animationController.addListener(_onAnimationTick);

    _initialCameraPosition = CameraPosition(
      target: widget.routePoints.isNotEmpty
          ? widget.routePoints.first
          : const LatLng(23.8729, 90.3917),
      zoom: 17.5,
      tilt: 45.0,
    );

    _polylines = {
      Polyline(
        polylineId: const PolylineId('route_polyline'),
        points: widget.routePoints,
        color: AppColors.secondary,
        width: 5,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };

    _pickupMarker = Marker(
      markerId: const MarkerId('pickup'),
      position: widget.routePoints.isNotEmpty
          ? widget.routePoints.first
          : const LatLng(23.8729, 90.3917),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Pickup Location (Uttara)'),
    );

    _dropoffMarker = Marker(
      markerId: const MarkerId('dropoff'),
      position: widget.routePoints.isNotEmpty
          ? widget.routePoints.last
          : const LatLng(23.8069, 90.3685),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: const InfoWindow(title: 'Drop-off Location (Mirpur)'),
    );

    _loadMarkerIcons();
  }

  @override
  void didUpdateWidget(covariant LiveMapView oldWidget) {
    super.didUpdateWidget(oldWidget);

    final newLocation = widget.currentDriverLocation;
    if (newLocation != null && newLocation != oldWidget.currentDriverLocation) {
      if (_previousDriverPosition == null) {
        _animatedDriverPosition = newLocation;
        _previousDriverPosition = newLocation;
        _updateMarkers();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _updateCamera(newLocation, 0.0);
        });
      } else {
        _targetDriverPosition = newLocation;
        _startPosition = _animatedDriverPosition ?? _previousDriverPosition!;

        _startRotation = _driverRotation;
        _targetRotation = _calculateBearing(
          _startPosition,
          _targetDriverPosition!,
        );

        _animationController.reset();
        _animationController.forward();

        _previousDriverPosition = newLocation;
      }
    }
  }

  late LatLng _startPosition;

  @override
  void dispose() {
    _animationController.removeListener(_onAnimationTick);
    _animationController.dispose();
    _markersNotifier.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _loadMarkerIcons() async {
    try {
      final ByteData data = await rootBundle.load('assets/icons/car.png');
      final ui.Codec codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 55,
      );
      final ui.FrameInfo fi = await codec.getNextFrame();
      final ByteData? byteData = await fi.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData != null && mounted) {
        final icon = BitmapDescriptor.bytes(byteData.buffer.asUint8List());
        setState(() {
          _driverIcon = icon;
        });
        _updateMarkers();
      }
    } catch (e) {
      debugPrint(
        "Error loading custom car marker asset. Fallback to default. Error: $e",
      );
    }
  }

  void _onAnimationTick() {
    if (_targetDriverPosition == null) return;

    final double t = _animationController.value;
    final bool isLastTick = t >= 1.0;

    final int now = DateTime.now().millisecondsSinceEpoch;
    if (!isLastTick && (now - _lastUpdateMillis < 33)) {
      return;
    }
    _lastUpdateMillis = now;

    final double lat =
        _startPosition.latitude +
        (_targetDriverPosition!.latitude - _startPosition.latitude) * t;
    final double lng =
        _startPosition.longitude +
        (_targetDriverPosition!.longitude - _startPosition.longitude) * t;

    _animatedDriverPosition = LatLng(lat, lng);
    _driverRotation = _interpolateAngle(_startRotation, _targetRotation, t);

    _updateMarkers();

    if (_isCameraLocked) {
      _updateCamera(_animatedDriverPosition!, _driverRotation);
    }
  }

  void _updateCamera(LatLng position, double bearing) {
    if (_mapController == null || !_isCameraLocked) return;

    _mapController!.moveCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 17.5,
          bearing: bearing,
          tilt: 45.0,
        ),
      ),
    );
  }

  void _recenterCamera() {
    setState(() {
      _isCameraLocked = true;
    });
    if (_animatedDriverPosition != null) {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _animatedDriverPosition!,
            zoom: 17.5,
            bearing: _driverRotation,
            tilt: 45.0,
          ),
        ),
      );
    }
  }

  void _updateMarkers() {
    if (widget.routePoints.isEmpty || _animatedDriverPosition == null) return;

    _markersNotifier.value = {
      _pickupMarker,
      _dropoffMarker,
      Marker(
        markerId: const MarkerId('driver'),
        position: _animatedDriverPosition!,
        rotation: _driverRotation,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        icon: _driverIcon,
        infoWindow: const InfoWindow(title: 'Driver Kamal Hossain'),
      ),
    };
  }

  void _fitRoute(GoogleMapController controller) {
    if (widget.routePoints.isEmpty) return;

    double minLat = widget.routePoints.first.latitude;
    double maxLat = widget.routePoints.first.latitude;
    double minLng = widget.routePoints.first.longitude;
    double maxLng = widget.routePoints.first.longitude;

    for (final point in widget.routePoints) {
      if (point.latitude < minLat) minLat = point.latitude;
      if (point.latitude > maxLat) maxLat = point.latitude;
      if (point.longitude < minLng) minLng = point.longitude;
      if (point.longitude > maxLng) maxLng = point.longitude;
    }

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80.0,
      ),
    );
  }

  double _calculateBearing(LatLng start, LatLng end) {
    final double lat1 = start.latitude * pi / 180;
    final double lng1 = start.longitude * pi / 180;
    final double lat2 = end.latitude * pi / 180;
    final double lng2 = end.longitude * pi / 180;

    final double dLng = lng2 - lng1;

    final double y = sin(dLng) * cos(lat2);
    final double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);

    final double bearing = atan2(y, x) * 180 / pi;
    return (bearing + 360) % 360;
  }

  double _interpolateAngle(double start, double end, double t) {
    double difference = end - start;
    while (difference < -180) {
      difference += 360;
    }
    while (difference > 180) {
      difference -= 360;
    }
    return (start + difference * t) % 360;
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (widget.currentDriverLocation != null) {
      _updateCamera(widget.currentDriverLocation!, 0.0);
    } else {
      _fitRoute(controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        RepaintBoundary(
          child: Listener(
            onPointerDown: (event) {
              if (_isCameraLocked) {
                setState(() {
                  _isCameraLocked = false;
                });
              }
            },
            child: ValueListenableBuilder<Set<Marker>>(
              valueListenable: _markersNotifier,
              builder: (context, markers, child) {
                return GoogleMap(
                  initialCameraPosition: _initialCameraPosition,
                  markers: markers,
                  polylines: _polylines,
                  zoomControlsEnabled: false,
                  myLocationButtonEnabled: false,
                  onMapCreated: _onMapCreated,
                );
              },
            ),
          ),
        ),

        if (!_isCameraLocked)
          Positioned(
            bottom: 300,
            right: 16,
            child: AnimatedOpacity(
              opacity: !_isCameraLocked ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              child: FloatingActionButton.small(
                onPressed: _recenterCamera,
                backgroundColor: AppColors.surface,
                foregroundColor: AppColors.primary,
                shape: const CircleBorder(),
                elevation: 4,
                child: const Icon(Icons.gps_fixed),
              ),
            ),
          ),
      ],
    );
  }
}
