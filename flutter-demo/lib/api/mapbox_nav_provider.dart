// mapbox_route_provider.dart
// Flutter ChangeNotifier provider that hardcodes a Mapbox Directions API
// call (driving-traffic) from UP Diliman to Ateneo de Manila University,
// requests route + alternatives, decodes polyline6 geometries, samples
// coordinates every 100 meters, and exposes total distance and ETA.

import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

// --- Models -----------------------------------------------------------------
class LatLng {
  final double lat;
  final double lng;
  LatLng(this.lat, this.lng);

  @override
  String toString() => 'LatLng($lat, $lng)';
}

class RouteInfo {
  final double distanceMeters;
  final double durationSeconds;
  final List<LatLng> geometry; // decoded polyline points
  final List<LatLng> sampledEvery100m;

  RouteInfo({
    required this.distanceMeters,
    required this.durationSeconds,
    required this.geometry,
    required this.sampledEvery100m,
  });
}

// --- Provider ----------------------------------------------------------------
class MapboxRouteProvider with ChangeNotifier {
  // Replace with your Mapbox access token. Do NOT commit a secret token to
  // public source control. This placeholder must be replaced with a valid
  // token for the network call to succeed.
  final String mapboxAccessToken = 'pk.eyJ1IjoiZGV2Y3J5ZGFlIiwiYSI6ImNtZmRtd2Q3NjBidW8ycnBjbzgybjN0MmUifQ.nqzlKFMK10ThO8bVZrKbOQ';

  // Hardcoded coordinates (origin -> destination). Mapbox expects
  // coordinates as lon,lat in the request path.
  // These are approximate and can be changed as needed.
  // UP Diliman (approx): lat 14.652907, lon 121.058680
  // Ateneo de Manila Univ (approx): lat 14.662314, lon 121.052514
  final double _originLat = 14.652907;
  final double _originLng = 121.058680;
  final double _destLat = 14.662314;
  final double _destLng = 121.052514;

  bool _isLoading = false;
  String? _error;
  List<RouteInfo> _routes = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<RouteInfo> get routes => List.unmodifiable(_routes);

  Future<void> fetchRoutes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final coords = '$_originLng,$_originLat;$_destLng,$_destLat';
      final url = Uri.parse(
        'https://api.mapbox.com/directions/v5/mapbox/driving-traffic/$coords?alternatives=true&geometries=polyline6&overview=full&steps=false&access_token=$mapboxAccessToken',
      );

      final res = await http.get(url);
      if (res.statusCode != 200) {
        _error = 'Mapbox API error: ${res.statusCode} ${res.reasonPhrase}';
        _routes = [];
        _isLoading = false;
        notifyListeners();
        return;
      }

      final Map<String, dynamic> body = json.decode(res.body);
      final List<dynamic> routesJson = body['routes'] ?? [];

      final List<RouteInfo> parsed = [];

      for (final r in routesJson) {
        final double distance = (r['distance'] as num).toDouble();
        final double duration = (r['duration'] as num).toDouble();
        final String geometryEncoded = r['geometry'] as String;

        final List<LatLng> decoded = _decodePolyline6(geometryEncoded);
        final List<LatLng> sampled = _sampleAlongPolyline(decoded, 100.0);

        parsed.add(RouteInfo(
          distanceMeters: distance,
          durationSeconds: duration,
          geometry: decoded,
          sampledEvery100m: sampled,
        ));
      }

      _routes = parsed;
    } catch (e, st) {
      _error = 'Failed to fetch or parse routes: $e\n$st';
      _routes = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ------------------------------------------------------------------------
  // Polyline6 decoder (precision 1e6). This is a Dart adaptation of the
  // encoded polyline algorithm (the Mapbox "polyline6" variant uses 6-digit
  // precision).
  List<LatLng> _decodePolyline6(String encoded) {
    final List<LatLng> coords = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int shift = 0;
      int result = 0;
      int byte = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final int deltaLat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      final int deltaLng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      coords.add(LatLng(lat / 1e6, lng / 1e6));
    }

    return coords;
  }

  // ------------------------------------------------------------------------
  // Haversine distance in meters between two LatLng points.
  double _haversineDistance(LatLng a, LatLng b) {
    const R = 6371000.0; // earth radius in meters
    final dLat = _degToRad(b.lat - a.lat);
    final dLon = _degToRad(b.lng - a.lng);
    final lat1 = _degToRad(a.lat);
    final lat2 = _degToRad(b.lat);

    final sinDlat = sin(dLat / 2);
    final sinDlon = sin(dLon / 2);
    final aa = sinDlat * sinDlat + sinDlon * sinDlon * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(aa), sqrt(1 - aa));
    return R * c;
  }

  double _degToRad(double deg) => deg * pi / 180.0;

  // ------------------------------------------------------------------------
  // Linearly interpolate (by fraction) between two LatLng points. For short
  // urban distances this gives acceptable accuracy for sampling every 100m.
  LatLng _interpolate(LatLng a, LatLng b, double fraction) {
    final lat = a.lat + (b.lat - a.lat) * fraction;
    final lng = a.lng + (b.lng - a.lng) * fraction;
    return LatLng(lat, lng);
  }

  // ------------------------------------------------------------------------
  // Sample points along a polyline (list of LatLng) every `intervalMeters`.
  // The function includes the start point and attempts to include a final
  // point at the route end (if the last sample distance falls exactly on it
  // it will be included anyway).
  List<LatLng> _sampleAlongPolyline(List<LatLng> poly, double intervalMeters) {
    final samples = <LatLng>[];
    if (poly.isEmpty) return samples;

    // Precompute segment lengths and total length
    final segmentLengths = <double>[];
    double total = 0.0;
    for (int i = 0; i < poly.length - 1; i++) {
      final seg = _haversineDistance(poly[i], poly[i + 1]);
      segmentLengths.add(seg);
      total += seg;
    }

    if (total == 0) {
      // degenerate: all points identical
      samples.add(poly.first);
      return samples;
    }

    // Generate target distances: 0, 100, 200, ..., <= total
    int steps = (total / intervalMeters).floor();
    // Always include start
    samples.add(poly.first);

    double currentTarget = intervalMeters; // first target > 0
    int segIndex = 0;
    double segAccum = 0.0; // length traveled until start of segIndex

    while (currentTarget < total && segIndex < segmentLengths.length) {
      final segLen = segmentLengths[segIndex];

      // If target is within this segment
      if (currentTarget <= segAccum + segLen) {
        final distanceIntoSeg = currentTarget - segAccum;
        final frac = (segLen == 0) ? 0.0 : (distanceIntoSeg / segLen);
        final point = _interpolate(poly[segIndex], poly[segIndex + 1], frac);
        samples.add(point);
        currentTarget += intervalMeters;
      } else {
        // move to next segment
        segAccum += segLen;
        segIndex++;
      }
    }

    // Optionally include final point if not already added
    final last = poly.last;
    final lastSample = samples.isNotEmpty ? samples.last : null;
    if (lastSample == null || (lastSample.lat - last.lat).abs() > 1e-7 || (lastSample.lng - last.lng).abs() > 1e-7) {
      samples.add(last);
    }

    return samples;
  }
}

// --- Usage note (not part of provider file):
//
// 1) Add `http` and `provider` to your pubspec.yaml.
// 2) Replace `YOUR_MAPBOX_ACCESS_TOKEN_HERE` with your Mapbox token.
// 3) Provide MapboxRouteProvider via ChangeNotifierProvider in your app and
//    call `await provider.fetchRoutes()` (e.g. in initState or via a button).
// 4) Inspect `provider.routes` to get distance/duration and sampled coords.
