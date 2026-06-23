import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DirectionsResult {
  final List<LatLng> points;
  final int durationSeconds;
  final String durationText;

  const DirectionsResult({
    required this.points,
    required this.durationSeconds,
    required this.durationText,
  });
}

class GoogleDirectionsService {
  final HttpClient _httpClient = HttpClient();

  Future<DirectionsResult> getDirections(
    LatLng origin,
    LatLng destination,
    String apiKey,
  ) async {
    if (apiKey.trim().isEmpty) {
      throw Exception("API Key is empty.");
    }

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&key=$apiKey',
    );

    try {
      final request = await _httpClient
          .getUrl(url)
          .timeout(const Duration(seconds: 5));
      final response = await request.close();

      if (response.statusCode != 200) {
        throw Exception(
          "Server responded with HTTP status code ${response.statusCode}",
        );
      }

      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> json =
          jsonDecode(responseBody) as Map<String, dynamic>;

      if (json['status'] != 'OK') {
        throw Exception("Directions API error status: ${json['status']}");
      }

      final routes = json['routes'] as List;
      if (routes.isEmpty) {
        throw Exception("No routes found in the Directions API response.");
      }

      final overviewPolyline =
          routes[0]['overview_polyline']['points'] as String;
      final points = decodePolyline(overviewPolyline);

      final legs = routes[0]['legs'] as List;
      int durationSeconds = 1800;
      String durationText = "30 mins";

      if (legs.isNotEmpty) {
        final durationMap = legs[0]['duration'] as Map<String, dynamic>;
        durationSeconds = (durationMap['value'] as num).toInt();
        durationText = durationMap['text'] as String;
      }

      return DirectionsResult(
        points: points,
        durationSeconds: durationSeconds,
        durationText: durationText,
      );
    } catch (e) {
      debugPrint("Error loading directions from Google API: $e");
      rethrow;
    }
  }

  List<LatLng> decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    final int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
}
