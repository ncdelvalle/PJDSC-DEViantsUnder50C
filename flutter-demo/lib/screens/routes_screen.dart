import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:pjdsc_project/components/percentage.dart';

class Routes_Screen extends StatefulWidget {
  const Routes_Screen({super.key});

  @override
  State<Routes_Screen> createState() => _Routes_ScreenState();
}

class _Routes_ScreenState extends State<Routes_Screen> {
  final TextEditingController _currentController = TextEditingController(
    text: "Current Address Initial Value",
  );
  final TextEditingController _destinationController = TextEditingController();
  //FirebaseAuthAPI authService = FirebaseAuthAPI

  @override
  void dispose() {
    super.dispose();
    _currentController.dispose();
    _destinationController.dispose();
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
              child: _createRoutePlanning(),
            ),
            Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: _createRoute("Recommended"),
            ),
            Padding(
              padding: EdgeInsetsGeometry.all(10),
              child: _createRoute("Fastest"),
            ),
          ],
        ),
      ),
    );
  }

  _createRoutePlanning() {
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
            _createLocation("Current", "Input Address Here"),
            _createLocation("Destination", "Input Destination here"),
          ],
        ),
      ),
    );
  }

  _createLocation(String label, String address) {
    late Color color;
    switch (label) {
      case "Current":
        color = Colors.green;
        break;
      case "Destination":
        color = Color.fromARGB(255, 206, 62, 27);
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 10, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(Icons.motorcycle, color: color, size: 24.0),
                SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: "Lexend",
                    fontSize: 20,
                    color: const Color.fromARGB(255, 58, 58, 58),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: label == "Current"
                ? TextField(
                    controller: _currentController,
                    readOnly: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 62, 27),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 62, 27),
                        ),
                      ),
                    ),
                  )
                : TextField(
                    controller: _destinationController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromARGB(255, 206, 62, 27),
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  _createRoute(String label) {
    Color color = Color.fromARGB(255, 206, 62, 27);
    Color color1 = Color.fromARGB(255, 243, 112, 60);
    return Card(
      child: Container(
        width: 400,
        decoration: boxDecor(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 20, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$label Route",
                    style: TextStyle(
                      fontFamily: "Lexend",
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  Card(),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      Icon(Icons.view_array_sharp),
                      Text(
                        "10.8 km",
                        style: TextStyle(
                          fontFamily: "Lexend",
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color1,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Icon(Icons.hourglass_empty),
                      Text(
                        "22 min",
                        style: TextStyle(
                          fontFamily: "Lexend",
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color1,
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Icon(Icons.electric_bolt_sharp),
                      Text(
                        " 6 min faster",
                        style: TextStyle(
                          fontFamily: "Lexend",
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: color1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            PercentageTile(label: "Climate Risk", percentage: 0.3),
            Text("Route Hazards: "),

            //include list here
            _createSelectRouteButton(context),
          ],
        ),
      ),
    );
  }

  Widget _createSelectRouteButton(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 243, 112, 60),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.alt_route, color: Colors.white),
              Text(
                "Select Route",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: "Lexend",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
