import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pjdsc_project/components/percentage.dart';
import 'package:pjdsc_project/components/safety_messages.dart';

class Safety_Screen extends StatefulWidget {
  const Safety_Screen({super.key});

  @override
  State<Safety_Screen> createState() => _Safety_ScreenState();
}

class _Safety_ScreenState extends State<Safety_Screen> {
  //depend on backend values for this, to be passed to alert
  bool heatHazard = true;
  bool airQualityHazard = true;
  bool floodHazard = true;

  // final TextEditingController _currentController = TextEditingController(
  //   text: "Current Address Initial Value",
  // );
  // final TextEditingController _destinationController = TextEditingController();
  // //FirebaseAuthAPI authService = FirebaseAuthAPI

  @override
  void dispose() {
    super.dispose();
    // _currentController.dispose();
    // _destinationController.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 243, 112, 60),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            );
          },
        ),
      ),
      body: _createBody(),
    );
  }

  Widget _createBody() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsetsGeometry.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: _createActiveAlerts(
                showHeatWarning: heatHazard,
                showAirQualityAlert: airQualityHazard,
                showFloodRisk: floodHazard,
              ),
            ),
            Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: _createOptimalWorkingHours(),
            ),
            Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: _createSafetyRecommendations(),
            ),
          ],
        ),
      ),
    );
  }

  _createActiveAlerts({
    required bool showHeatWarning,
    required bool showAirQualityAlert,
    required bool showFloodRisk,
  }) {
    return Card(
      child: Container(
        width: 450,
        decoration: boxDecor(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text(
                "Active Alerts",
                style: TextStyle(
                  fontFamily: "Lexend",
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 58, 58, 58),
                ),
              ),
            ),
            if (showHeatWarning)
              _buildAlertTile(
                color: Colors.red,
                title: "Extreme Heat Warning",
                timestamp: "2 minutes ago",
                messages: [
                  "Temperature exceeding 35°C with high humidity. Take immediate precautions.",
                  "Consider wearing a mask.",
                ],
              ),
            if (showAirQualityAlert)
              _buildAlertTile(
                color: Colors.amber,
                title: "Air Quality Alert",
                timestamp: "15 minutes ago",
                messages: [
                  "Unhealthy air quality levels detected on your route.",
                  "Consider wearing a mask.",
                ],
              ),
            if (showFloodRisk)
              _buildAlertTile(
                color: Colors.blue,
                title: "Flood Risk Update",
                timestamp: "1 hour ago",
                messages: [
                  "Moderate flood risk in low-lying areas.",
                  "Avoid Quezon Ave underpass.",
                ],
              ),
          ],
        ),
      ),
    );
  }

  _buildAlertTile({
    required Color color,
    required String title,
    required String timestamp,
    required List<String> messages,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color, width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: "Lexend",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Spacer(),
              Text(
                timestamp,
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
          SizedBox(height: 6),
          ...messages.map(
            (msg) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "• $msg",
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _createOptimalWorkingHours() {
    return Card(
      child: Container(
        width: 450,

        decoration: boxDecor(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsetsGeometry.fromLTRB(10, 10, 10, 0),
              child: Row(
                children: [
                  Icon(
                    Icons.gps_fixed,
                    color: Color.fromARGB(255, 243, 112, 60),
                    size: 24.0,
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Route Planning",
                    style: TextStyle(
                      fontFamily: "Lexend",
                      fontSize: 20,
                      color: const Color.fromARGB(255, 58, 58, 58),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //show safety recommendations based on hazards
  _createSafetyRecommendations() {
    final safetyMessages = _generateSafetyMessages();

    return Card(
      child: Container(
        width: 450,
        decoration: boxDecor(),
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Optimal Working Hours",
              style: TextStyle(
                fontFamily: "Lexend",
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 58, 58, 58),
              ),
            ),
            SizedBox(height: 10),
            ...safetyMessages.map(
              (msg) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        msg,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //get safety messages from dart file
  List<String> _generateSafetyMessages() {
    List<String> messages = [];

    if (heatHazard) {
      messages.addAll(hazardSafetyMessages["heat"]!);
    }
    if (airQualityHazard) {
      messages.addAll(hazardSafetyMessages["airQuality"]!);
    }
    if (floodHazard) {
      messages.addAll(hazardSafetyMessages["flood"]!);
    }

    if (messages.isEmpty) {
      messages.add("No active hazards. Stay safe and alert!");
    }

    return messages;
  }

  boxDecor() {
    return BoxDecoration(
      color: Color.fromARGB(255, 255, 251, 237),
      border: const GradientBoxBorder(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 206, 62, 27),
            Color.fromARGB(255, 243, 112, 60),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        width: 4,
      ),
      borderRadius: BorderRadius.circular(10),
    );
  }
}
