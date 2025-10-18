# Route Data Storage in Firebase

This document explains how to store route data (`route_distance`, `travel_time`, `climate_index`) in Firebase using the `route_data` collection.

## What Was Created

### 1. Route Data Model (`lib/models/route_data_model.dart`)
- Defines the structure for route data
- Includes validation and helper methods
- Fields: `routeDistance`, `travelTime`, `climateIndex`, `timestamp`, `userId`

### 2. Firebase API (`lib/api/firebase_route_api.dart`)
- Handles all Firebase operations for route data
- Methods: add, update, delete, query by date range, get latest data

### 3. Provider (`lib/providers/route_data_provider.dart`)
- Manages route data state in your app
- Provides methods to interact with route data
- Includes statistics calculation

### 4. UI Screen (`lib/screens/route_data_page.dart`)
- Complete UI for managing route data
- Add, view, delete route data entries
- Shows statistics

## How to Use

### Basic Usage - Store Route Data

```dart
// Get the provider
final routeProvider = context.read<RouteDataProvider>();

// Store route data
final result = await routeProvider.addRouteData(
  routeDistance: 15.5,  // km
  travelTime: 45.0,     // minutes
  climateIndex: 0.7,    // 0.0 to 1.0 scale
);

print(result); // "Successfully added route data!"
```

### Advanced Usage - Direct API Access

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_data_model.dart';

// Create route data object
final routeData = RouteData(
  routeDistance: 10.2,
  travelTime: 30.0,
  climateIndex: 0.5,
  timestamp: DateTime.now(),
  userId: 'user123', // optional
);

// Store directly in Firebase
final db = FirebaseFirestore.instance;
await db.collection('route_data').add(routeData.toJson());
```

### Query Route Data

```dart
// Get all route data for current user
await routeProvider.loadRouteData();
final routeDataList = routeProvider.routeDataList;

// Get route data by date range
final startDate = DateTime(2024, 1, 1);
final endDate = DateTime(2024, 12, 31);
final routesInRange = await routeProvider.getRouteDataByDateRange(startDate, endDate);

// Get latest route data
final latestRoute = await routeProvider.getLatestRouteData();
```

### Get Statistics

```dart
final stats = routeProvider.getStatistics();
print('Total Routes: ${stats['totalRoutes']}');
print('Total Distance: ${stats['totalDistance']} km');
print('Average Climate Index: ${stats['averageClimateIndex']}');
```

## Firebase Collection Structure

The data is stored in Firebase under the `route_data` collection with this structure:

```json
{
  "routeDistance": 15.5,
  "travelTime": 45.0,
  "climateIndex": 0.7,
  "timestamp": "2024-01-15T10:30:00.000Z",
  "userId": "user123"
}
```

## Navigation to Route Data Page

To navigate to the route data management page:

```dart
Navigator.pushNamed(context, '/routeData');
```

## Example Integration

Here's a complete example of how to integrate route data storage in your app:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_data_provider.dart';

class MyRouteWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        // Store route data
        final result = await context.read<RouteDataProvider>().addRouteData(
          routeDistance: 20.0,
          travelTime: 60.0,
          climateIndex: 0.8,
        );
        
        // Show result
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      },
      child: Text('Store Route Data'),
    );
  }
}
```

## Testing

You can test the functionality using the example utility:

```dart
import '../utils/route_data_example.dart';

// Add example data
RouteDataExample.storeExampleRouteData(context);

// Show statistics
RouteDataExample.showRouteStatistics(context);

// Navigate to route data page
RouteDataExample.navigateToRouteDataPage(context);
```

## Validation Rules

- `routeDistance`: Must be positive (≥ 0)
- `travelTime`: Must be positive (≥ 0)  
- `climateIndex`: Must be between 0.0 and 1.0
- `timestamp`: Automatically set to current time
- `userId`: Automatically set to current authenticated user

## Error Handling

All methods return success/error messages:

```dart
final result = await routeProvider.addRouteData(
  routeDistance: -5.0, // Invalid!
  travelTime: 30.0,
  climateIndex: 0.5,
);

// result will be: "Route distance must be positive."
```

The route data functionality is now fully integrated into your Flutter app and ready to use!
