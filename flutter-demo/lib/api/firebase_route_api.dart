import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_data_model.dart';

class FirebaseRouteApi {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  // Fetch all route data
  Stream<QuerySnapshot> getAllRouteData() {
    return db.collection('route_data').snapshots();
  }

  // Fetch route data for a specific user
  Stream<QuerySnapshot> getRouteDataByUser(String userId) {
    return db
        .collection('route_data')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Add route data
  Future<String> addRouteData(RouteData routeData) async {
    try {
      // Validate the data
      if (routeData.routeDistance < 0) {
        return "Route distance must be positive.";
      }
      if (routeData.travelTime < 0) {
        return "Travel time must be positive.";
      }
      if (routeData.climateIndex < 0 || routeData.climateIndex > 1) {
        return "Climate index must be between 0 and 1.";
      }

      // Add to Firestore
      await db.collection('route_data').add(routeData.toJson());
      return "Successfully added route data!";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // Add route data with user ID
  Future<String> addRouteDataWithUser(RouteData routeData, String userId) async {
    try {
      // Validate the data
      if (routeData.routeDistance < 0) {
        return "Route distance must be positive.";
      }
      if (routeData.travelTime < 0) {
        return "Travel time must be positive.";
      }
      if (routeData.climateIndex < 0 || routeData.climateIndex > 1) {
        return "Climate index must be between 0 and 1.";
      }

      // Create data with user ID
      Map<String, dynamic> data = routeData.toJson();
      data['userId'] = userId;

      // Add to Firestore
      await db.collection('route_data').add(data);
      return "Successfully added route data!";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // Update route data
  Future<String> updateRouteData(String id, RouteData routeData) async {
    try {
      // Validate the data
      if (routeData.routeDistance < 0) {
        return "Route distance must be positive.";
      }
      if (routeData.travelTime < 0) {
        return "Travel time must be positive.";
      }
      if (routeData.climateIndex < 0 || routeData.climateIndex > 1) {
        return "Climate index must be between 0 and 1.";
      }

      await db.collection('route_data').doc(id).update(routeData.toJson());
      return "Successfully updated route data!";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // Delete route data
  Future<String> deleteRouteData(String id) async {
    try {
      await db.collection('route_data').doc(id).delete();
      return "Successfully deleted route data!";
    } catch (e) {
      return "Error: ${e.toString()}";
    }
  }

  // Get route data by date range
  Future<List<RouteData>> getRouteDataByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? userId,
  }) async {
    try {
      Query query = db
          .collection('route_data')
          .where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String());

      if (userId != null) {
        query = query.where('userId', isEqualTo: userId);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => RouteData.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception("Error fetching route data: ${e.toString()}");
    }
  }

  // Get latest route data for a user
  Future<RouteData?> getLatestRouteData(String userId) async {
    try {
      final snapshot = await db
          .collection('route_data')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return RouteData.fromFirestore(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception("Error fetching latest route data: ${e.toString()}");
    }
  }
}
