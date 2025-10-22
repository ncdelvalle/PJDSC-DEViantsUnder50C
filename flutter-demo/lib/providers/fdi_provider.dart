import 'package:flutter/material.dart';

// --- FDI Provider ---
class FDIProvider extends ChangeNotifier {
  // Inputs
  int _var = 0;
  double _precipitationTotal = 0.0;

  // Constants from your Python code
  final double mu = 12.546862170087977;
  final double sigma = 15.797711959587314;

  // Outputs
  double _spiNorm = 0.5;
  double _fdiValue = 0.0;
  String _fdiClass = "unlikely";

  // Getters
  double get spiNorm => _spiNorm;
  double get fdiValue => _fdiValue;
  String get fdiClass => _fdiClass;

  // Update inputs
  void updateInputs({
    required int varValue,
    required double precipitationTotal,
  }) {
    _var = varValue;
    _precipitationTotal = precipitationTotal;
    _computeSPI();
    _computeFDI();
    notifyListeners();
  }

  // --- Compute normalized SPI ---
  void _computeSPI() {
    double spi = (_precipitationTotal - mu) / sigma;
    spi = spi.clamp(-3.0, 3.0);
    _spiNorm = (spi + 3) / 6; // normalize to [0,1]
  }

  // --- Hazard fuzzification (toned down) ---
  Map<String, double> _fuzzHazard(int varVal) {
    double compressedVar = (varVal / 3).toDouble(); // linear scaling

    // scale factor < 1 to reduce influence
    const double scaleLow = 0.55; // low still smaller
    const double scaleMedium = 0.65; // medium contribution toned down
    const double scaleHigh = 0.65; // high contribution toned down

    return {
      "low": ((1 - compressedVar) * scaleLow).clamp(0.0, 1.0),
      "medium": (compressedVar * scaleMedium).clamp(0.0, 1.0),
      "high": (compressedVar * scaleHigh).clamp(0.0, 1.0),
    };
  }

  // --- SPI fuzzification ---
  Map<String, double> _fuzzSPI(double spiNorm) {
    return {
      "low": ((0.6 - spiNorm) / 0.6).clamp(0.0, 1.0),
      "medium": (1 - (spiNorm - 0.5).abs() / 0.5).clamp(0.0, 1.0),
      "high": ((spiNorm - 0.4) / 0.6).clamp(0.0, 1.0),
    };
  }

  // --- Compute FDI ---
  void _computeFDI() {
    final gamma = 0.9;
    final weights = {"low": 0.3, "medium": 0.6, "high": 1.0};

    final hazardFuzzy = _fuzzHazard(_var);
    final spiFuzzy = _fuzzSPI(_spiNorm);

    double fdi = 0.0;

    for (var level in ["low", "medium", "high"]) {
      final h = hazardFuzzy[level]!;
      final s = spiFuzzy[level]!;
      final w = weights[level]!;
      fdi += w * (gamma * (h * s) + (1 - gamma) * (h + s - h * s));
    }

    if (_precipitationTotal == 0) {
      fdi = 0;
    }

    _fdiValue = fdi;

    if (_fdiValue < 0.28) {
      _fdiClass = "unlikely";
    } else if (fdi < 0.65) {
      _fdiClass = "likely";
    } else {
      _fdiClass = "very likely";
    }
  }
}
