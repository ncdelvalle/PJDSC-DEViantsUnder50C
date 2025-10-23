import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:pjdsc_project/components/percentage.dart';

class PullupDrawer extends StatefulWidget {
  const PullupDrawer({super.key});

  @override
  State<PullupDrawer> createState() => _PullupDrawerState();
}

class _PullupDrawerState extends State<PullupDrawer> {
  //FirebaseAuthAPI authService = FirebaseAuthAPI

  @override
  Widget build(BuildContext context) {
    return
          DraggableScrollableSheet(
            initialChildSize: 0.25,
            minChildSize: 0.25,
            maxChildSize: 0.75,
            expand: true,

            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                //this is yung drag handle, add yung draggable or like closes it when tapped
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        children: [
                          SizedBox(width: 200, height: 50),
                          Column(
                            children: [
                              // createCRI(),
                              _createCRI(),
                              // SizedBox(height: 20),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceEvenly,
                              //   children: [
                              //     createStats("Heat Stress", 20.0),
                              //     createStats("Air Quality", 20.0),
                              //   ],
                              // ),
                              // SizedBox(height: 20),
                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceEvenly,
                              //   children: [
                              //     createStats("Wind Speed", 20.0),
                              //     createStats("Rainfall", 20.0),
                              //   ],
                              // ),
                              SizedBox(height: 20),
                              createHazardExposure(),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }

  Widget createStats(String label, double stat) {
    late String attached;
    Color color;
    switch (label) {
      case "Heat Stress":
        attached = "°C";
        break;
      case "Air Quality":
        attached = "";
        break;
      case "Wind Speed":
        attached = "km/h";
        break;
      case "Rainfall":
        attached = "mm";
        break;
    }
    return Card(
      child: Container(
        width: 80,
        height: 50,
        decoration: boxDecor(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.thermostat, size: 20),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text("$stat $attached", style: TextStyle(fontSize: 20)),
                Text(label, style: TextStyle(fontSize: 10)),
              ],
            ),
          ],
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

  Widget createCRI() {
    return Card(
      child: Container(
        width: 400,
        height: 400,
        decoration: boxDecor(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.wb_cloudy_outlined,
                      color: Color.fromARGB(255, 243, 112, 60),
                      size: 24.0,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Climate Risk Index",
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
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "7.2/10",
                    style: TextStyle(
                      fontFamily: "Lexend",
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 243, 112, 60),
                    ),
                  ),
                  Text("da fucken risk"),
                ],
              ),
            ),
            Expanded(
              child: PercentageTile(label: "Heat Stress", percentage: 0.5),
            ),
            Expanded(
              child: PercentageTile(label: "Air Quality", percentage: 0.3),
            ),
            Expanded(
              child: PercentageTile(label: "Wind Impact", percentage: 0.3),
            ),
            Expanded(child: PercentageTile(label: "Rainfall", percentage: 0.3)),
          ],
        ),
      ),
    );
  }

  Widget _createCRI() {
    return Card(
      child: Container(
        width: 400,
        height: 350,
        decoration: boxDecor(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.wb_cloudy_outlined,
                      color: Color.fromARGB(255, 243, 112, 60),
                      size: 24.0,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Climate Risk Index",
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
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "7.2",
                    style: TextStyle(
                      fontSize: 75,
                      color: Color.fromARGB(255, 201, 61, 28),
                      fontFamily: "AlfaSlabOne",
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "/ 10",
                    style: TextStyle(
                      fontSize: 25,
                      color: Color.fromARGB(255, 234, 99, 68),
                      fontFamily: "AlfaSlabOne",
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _createChart(),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _createStats("Heat Stress", 20.0),
                      _createStats("Air Quality", 20.0),
                      _createStats("Wind Speed", 20.0),
                      _createStats("Rainfall", 20.0),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _createStats(String label, double stat) {
    late String attached;
    late Color color;
    late Icon icon;
    switch (label) {
      case "Heat Stress":
        attached = "°C";
        color = Color.fromARGB(255, 201, 61, 28);
        icon = Icon(Icons.thermostat, size: 30, color: color);
        break;
      case "Air Quality":
        attached = "";
        color = Color.fromARGB(255, 234, 99, 68);
        icon = Icon(Icons.looks, size: 30, color: color);
        break;
      case "Wind Speed":
        attached = "km/h";
        color = Color.fromARGB(255, 255, 155, 99);
        icon = Icon(Icons.wind_power, size: 30, color: color);
        break;
      case "Rainfall":
        attached = "mm";
        color = Color.fromARGB(255, 231, 184, 8);
        icon = Icon(Icons.water, size: 30, color: color);
        break;
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        icon,
        Text(
          " $stat $attached  ",
          style: TextStyle(fontSize: 20, fontFamily: "Economica", color: color),
        ),

        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontFamily: "Economica",
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  PieChart _createChart() {
    List<Color> sectionColors = [
      Color.fromARGB(255, 201, 61, 28),
      Color.fromARGB(255, 234, 99, 68),
      Color.fromARGB(255, 255, 155, 99),
      Color.fromARGB(255, 231, 184, 8),
    ];

    Map<String, double> dataMap = {
      "Heat Stress": 5,
      "Air Quality": 3,
      "Wind Impact": 2,
      "Rainfall": 2,
    };

    return PieChart(
      dataMap: dataMap,
      colorList: sectionColors,
      chartType: ChartType.disc,
      chartRadius: 140,
      legendOptions: LegendOptions(showLegends: false),
      chartValuesOptions: ChartValuesOptions(
        showChartValuesInPercentage: true,
        showChartValueBackground: false,
        chartValueStyle: TextStyle(
          color: Colors.white,
          fontFamily: "Lexend",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget createHazardExposure() {
    return Card(
      child: Container(
        width: 400,
        height: 300,
        decoration: boxDecor(),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.wb_cloudy_outlined,
                      color: Color.fromARGB(255, 243, 112, 60),
                      size: 24.0,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "Daily Hazard Exposure",
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
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        "7.2/10",
                        style: TextStyle(
                          fontFamily: "Lexend",
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 243, 112, 60),
                        ),
                      ),
                      Text("da fucken risk"),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "7.2/10",
                        style: TextStyle(
                          fontFamily: "Lexend",
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 243, 112, 60),
                        ),
                      ),
                      Text("da fucken risk"),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: PercentageTile(
                label: "Heat Stress Exposure",
                percentage: 0.5,
              ),
            ),
            Expanded(
              child: PercentageTile(label: "Poor Air Quality", percentage: 0.3),
            ),
            Expanded(
              child: PercentageTile(label: "Safe Conditions", percentage: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
