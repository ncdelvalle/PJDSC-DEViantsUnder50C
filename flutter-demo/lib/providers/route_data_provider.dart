import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/route_data_model.dart';
import '../api/firebase_route_api.dart';

class RouteDataProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseRouteApi _api = FirebaseRouteApi();
  List<RouteData> _routeDataList = []; // Internal list of route data
  bool _isLoading = false;

  // Getters
  List<RouteData> get routeDataList => _routeDataList;
  bool get isLoading => _isLoading;

  // Load all route data for the current user
  Future<void> loadRouteData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('route_data')
          .where('userId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .get();

      // Convert documents to RouteData objects
      _routeDataList = snapshot.docs
          .map((doc) => RouteData.fromFirestore(doc))
          .toList();
    } catch (e) {
      // Error loading route data: $e
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new route data
  Future<String> addRouteData({
    required double routeDistance,
    required double travelTime,
    required double climateIndex,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return "User not authenticated.";

    final routeData = RouteData(
      routeDistance: routeDistance,
      travelTime: travelTime,
      climateIndex: climateIndex,
      timestamp: DateTime.now(),
      userId: uid,
    );

    try {
      final result = await _api.addRouteDataWithUser(routeData, uid);
      
      if (result.contains("Successfully")) {
        // Add to local list
        _routeDataList.insert(0, routeData.copyWith(id: DateTime.now().millisecondsSinceEpoch.toString()));
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      return "Error adding route data: ${e.toString()}";
    }
  }

  // Update route data
  Future<String> updateRouteData(String id, RouteData routeData) async {
    try {
      final result = await _api.updateRouteData(id, routeData);
      
      if (result.contains("Successfully")) {
        // Update local list
        final index = _routeDataList.indexWhere((item) => item.id == id);
        if (index != -1) {
          _routeDataList[index] = routeData.copyWith(id: id);
          notifyListeners();
        }
      }
      
      return result;
    } catch (e) {
      return "Error updating route data: ${e.toString()}";
    }
  }

  // Delete route data
  Future<String> deleteRouteData(String id) async {
    try {
      final result = await _api.deleteRouteData(id);
      
      if (result.contains("Successfully")) {
        // Remove from local list
        _routeDataList.removeWhere((item) => item.id == id);
        notifyListeners();
      }
      
      return result;
    } catch (e) {
      return "Error deleting route data: ${e.toString()}";
    }
  }

  // Get route data by date range
  Future<List<RouteData>> getRouteDataByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    try {
      return await _api.getRouteDataByDateRange(startDate, endDate, userId: uid);
    } catch (e) {
      // Error getting route data by date range: $e
      return [];
    }
  }

  // Get latest route data
  Future<RouteData?> getLatestRouteData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    try {
      return await _api.getLatestRouteData(uid);
    } catch (e) {
      // Error getting latest route data: $e
      return null;
    }
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    if (_routeDataList.isEmpty) {
      return {
        'totalRoutes': 0,
        'totalDistance': 0.0,
        'totalTime': 0.0,
        'averageClimateIndex': 0.0,
        'averageDistance': 0.0,
        'averageTime': 0.0,
      };
    }

    final totalDistance = _routeDataList.fold(0.0, (total, item) => total + item.routeDistance);
    final totalTime = _routeDataList.fold(0.0, (total, item) => total + item.travelTime);
    final totalClimateIndex = _routeDataList.fold(0.0, (total, item) => total + item.climateIndex);

    return {
      'totalRoutes': _routeDataList.length,
      'totalDistance': totalDistance,
      'totalTime': totalTime,
      'averageClimateIndex': totalClimateIndex / _routeDataList.length,
      'averageDistance': totalDistance / _routeDataList.length,
      'averageTime': totalTime / _routeDataList.length,
    };
  }

  // Clear all route data (for testing or reset purposes)
  void clearRouteData() {
    _routeDataList.clear();
    notifyListeners();
  }
}
