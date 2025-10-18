import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_data_provider.dart';

/// Example utility class showing how to use the route data functionality
class RouteDataExample {
  
  /// Example: Store route data programmatically
  static Future<void> storeExampleRouteData(BuildContext context) async {
    final routeProvider = context.read<RouteDataProvider>();
    
    // Example data
    final routeDistance = 15.5; // km
    final travelTime = 45.0;    // minutes
    final climateIndex = 0.7;   // 0.0 to 1.0 scale
    
    // Store the data
    final result = await routeProvider.addRouteData(
      routeDistance: routeDistance,
      travelTime: travelTime,
      climateIndex: climateIndex,
    );
    
    // Show result to user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: result.contains('Successfully') 
              ? Colors.green 
              : Colors.red,
        ),
      );
    }
  }
  
  /// Example: Store multiple route data entries
  static Future<void> storeMultipleRouteData(BuildContext context) async {
    final routeProvider = context.read<RouteDataProvider>();
    
    // Example data for multiple routes
    final routes = [
      {'distance': 10.2, 'time': 30.0, 'climate': 0.5},
      {'distance': 25.8, 'time': 60.0, 'climate': 0.8},
      {'distance': 5.5, 'time': 15.0, 'climate': 0.3},
    ];
    
    for (final route in routes) {
      final result = await routeProvider.addRouteData(
        routeDistance: route['distance'] as double,
        travelTime: route['time'] as double,
        climateIndex: route['climate'] as double,
      );
      
      if (!result.contains('Successfully')) {
        // Error storing route: $result
        break;
      }
    }
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Multiple route data entries added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  
  /// Example: Get and display statistics
  static void showRouteStatistics(BuildContext context) {
    final routeProvider = context.read<RouteDataProvider>();
    final stats = routeProvider.getStatistics();
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Route Statistics'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Routes: ${stats['totalRoutes']}'),
              Text('Total Distance: ${stats['totalDistance'].toStringAsFixed(2)} km'),
              Text('Total Time: ${stats['totalTime'].toStringAsFixed(0)} minutes'),
              Text('Average Climate Index: ${stats['averageClimateIndex'].toStringAsFixed(2)}'),
              Text('Average Distance: ${stats['averageDistance'].toStringAsFixed(2)} km'),
              Text('Average Time: ${stats['averageTime'].toStringAsFixed(0)} minutes'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
  
  /// Example: Navigate to route data page
  static void navigateToRouteDataPage(BuildContext context) {
    Navigator.pushNamed(context, '/routeData');
  }
}

/// Example widget that can be used to test route data functionality
class RouteDataTestWidget extends StatelessWidget {
  const RouteDataTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Route Data Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => RouteDataExample.storeExampleRouteData(context),
              child: const Text('Add Example Route Data'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => RouteDataExample.storeMultipleRouteData(context),
              child: const Text('Add Multiple Route Data'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => RouteDataExample.showRouteStatistics(context),
              child: const Text('Show Statistics'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => RouteDataExample.navigateToRouteDataPage(context),
              child: const Text('Go to Route Data Page'),
            ),
          ],
        ),
      ),
    );
  }
}
