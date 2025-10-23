import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '/providers/cri_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/route_data_provider.dart';
import 'screens/home_page.dart';
import 'screens/signup_page.dart';
import 'screens/route_data_page.dart';
import 'screens/map_page.dart';

import 'screens/routes_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

// Entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializes Firebase with default options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setup();

  // Wraps the app in providers to manage app-wide state
  runApp(
    MultiProvider(
      providers: [
        // Provider for authentication state
        ChangeNotifierProvider(create: (_) => UserAuthProvider()),
        ChangeNotifierProvider(create: (_) => ClimateRiskProvider()),
        // Provider for route data state
        ChangeNotifierProvider(create: (_) => RouteDataProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> setup() async {
  await dotenv.load(
    fileName: ".env",
  );
  MapboxOptions.setAccessToken(dotenv.env["MAPBOX_ACCESS_TOKEN"]!);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PJDSC Project',
      theme: ThemeData(primarySwatch: Colors.blue),

      home: const HomePage(),

      routes: {
        '/signUp': (context) => const SignUp(), // Route to Sign Up screen
        '/routeData': (context) =>
            const RouteDataPage(), // Route to Route Data screen
        '/routes': (context) => const Routes_Screen(),
        '/map': (context) => MapPage()
      },
    );
  }
}
