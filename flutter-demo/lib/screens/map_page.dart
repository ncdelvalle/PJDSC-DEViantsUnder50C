import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:pjdsc_project/components/drawer.dart';
import 'package:pjdsc_project/components/pullup_drawer.dart';

// REFERENCE: https://www.youtube.com/watch?v=UafQ8rw1V-Y

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MapPage> {

  // controls map basically
  mp.MapboxMap? mapboxMapController;

  // keeps track of user location
  StreamSubscription? userPositionStream;

  // initializing and disposing data
  @override
  void initState() {
    super.initState();
    _setupPositionTracking();
  }

  @override
  void dispose() {
    userPositionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(), 
            icon: const Icon(Icons.menu, color: Colors.deepOrange)))
      ),
      body: Stack(
        children: [
          Center(child:
            mp.MapWidget(
              onMapCreated: _onMapCreated,
              styleUri: mp.MapboxStyles.STANDARD
          )),
          PullupDrawer()
        ],
      )
    );
  }

  

  // helper function just for user automatic location tracker
  void _onMapCreated(mp.MapboxMap controller) async {
    setState(() {
      mapboxMapController = controller;
    });

    mapboxMapController?.location.updateSettings(
      mp.LocationComponentSettings(
        enabled: true,
        pulsingEnabled: true,     
      )
    );

    // for marker
    final pointAnnotationManager = await mapboxMapController?.annotations.createPointAnnotationManager();

    // for marker image
    final Uint8List imageData1 = await loadHQMarkerImage1();
    mp.PointAnnotationOptions pointAnnotationOptions =
      mp.PointAnnotationOptions(
        image: imageData1,
        iconSize: 0.3,
        geometry: mp.Point(
          coordinates: mp.Position(121.074593, 14.642448)
        )
      );

      pointAnnotationManager?.create(pointAnnotationOptions);

    final Uint8List imageData2 = await loadHQMarkerImage2();
    mp.PointAnnotationOptions pointAnnotationOptions2 =
      mp.PointAnnotationOptions(
        image: imageData2,
        iconSize: 0.3,
        geometry: mp.Point(
          coordinates: mp.Position(121.071134, 14.647441)
        )
      );

      pointAnnotationManager?.create(pointAnnotationOptions2);
  }
  

  Future<void> _setupPositionTracking() async {
    bool serviceEnabled;
    gl.LocationPermission permission;

    serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    // getting permissions from user
    permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        return Future.error("Location permissions are denied.");
      }
    }

    // if denied permissions forever, express error that will not work
    if (permission == gl.LocationPermission.deniedForever) {
      return Future.error(
        "Location permissions are permanently denied, we cannot request permissions.");
    }

    gl.LocationSettings locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 100);

    // makes the phone camera (screen) follow where the user is
    userPositionStream?.cancel();
    userPositionStream = gl.Geolocator.getPositionStream(
      locationSettings: locationSettings).listen
      (
        (gl.Position? position) {
          if (position != null && mapboxMapController != null) {
            mapboxMapController?.setCamera(
              mp.CameraOptions(
                center: mp.Point(
                  coordinates: mp.Position(
                    position.longitude,
                    position.latitude ))));
          }
        },
      ); 
  }

  // basically for loading image for marker
  Future<Uint8List> loadHQMarkerImage1() async {
    var byteData = await rootBundle.load("assets/icons/green_marker.png");
    return byteData.buffer.asUint8List();
  }

  Future<Uint8List> loadHQMarkerImage2() async {
    var byteData = await rootBundle.load("assets/icons/orange_marker.png");
    return byteData.buffer.asUint8List();
  }

}
 