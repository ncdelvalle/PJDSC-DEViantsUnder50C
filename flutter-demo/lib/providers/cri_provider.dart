import 'package:flutter/foundation.dart';

class ClimateRiskProvider with ChangeNotifier {
  // === HARDCODED MIN-MAX VALUES (for normalization) ===
  final Map<String, Map<String, double>> _minMax = {
    'temp_mean': {'min': 24.98, 'max': 31.5},
    'humidity_mean': {'min': 56.0, 'max': 96.0},
    'precipitation_total': {'min': 0.0, 'max': 4.488},
    'wind_speed_max': {'min': 2.29, 'max': 16.09},
    'aqi_mean': {'min': 1.0, 'max': 4.72},
  };

  // === HARDCODED SHANNON ENTROPY WEIGHTS ===
  final Map<String, double> _weights = {
    'temp_mean': 0.0624,
    'humidity_mean': 0.0914,
    'precipitation_total': 0.5129,
    'wind_speed_max': 0.0939,
    'aqi_mean': 0.2394,
  };

  // === Function to normalize an indicator ===
  double _normalize(String key, double value) {
    final minVal = _minMax[key]!['min']!;
    final maxVal = _minMax[key]!['max']!;
    final normalized = (value - minVal) / (maxVal - minVal);
    return normalized.clamp(0.0, 1.0);
  }

  // === Compute weighted CRI and influence breakdown ===
  Map<String, dynamic> computeCRI({
    required double tempMean,
    required double humidityMean,
    required double precipitationTotal,
    required double windSpeedMax,
    required double aqiMean,
  }) {
    // Step 1: Normalize all indicators
    final Map<String, double> normalized = {
      'temp_mean': _normalize('temp_mean', tempMean),
      'humidity_mean': _normalize('humidity_mean', humidityMean),
      'precipitation_total': _normalize('precipitation_total', precipitationTotal),
      'wind_speed_max': _normalize('wind_speed_max', windSpeedMax),
      'aqi_mean': _normalize('aqi_mean', aqiMean),
    };

    // Step 2: Compute weighted sum (CRI)
    double cri = 0.0;
    _weights.forEach((key, weight) {
      cri += normalized[key]! * weight;
    });

    // Step 3: Compute percentage influence per indicator
    final Map<String, double> influences = {};
    _weights.forEach((key, weight) {
      influences[key] = (normalized[key]! * weight) / cri * 100;
    });

    return {
      'cri': cri,
      'influences': influences,
    };
  }
}