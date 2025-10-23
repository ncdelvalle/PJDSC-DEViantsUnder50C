class RouteData {
  final String? id;
  final double routeDistance;    // Distance of the route
  final double travelTime;       // Travel time in minutes
  final double climateIndex;     // Climate index value
  final DateTime timestamp;      // When this data was recorded
  final String? userId;          // Optional: associate with user

  // Constructor to initialize all fields
  RouteData({
    this.id,
    required this.routeDistance,
    required this.travelTime,
    required this.climateIndex,
    required this.timestamp,
    this.userId,
  });

  // Convert RouteData to JSON for Firebase storage
  Map<String, dynamic> toJson() => {
        'routeDistance': routeDistance,
        'travelTime': travelTime,
        'climateIndex': climateIndex,
        'timestamp': timestamp.toIso8601String(),
        'userId': userId,
      };

  // Factory constructor to create a RouteData object from a Firestore document
  factory RouteData.fromFirestore(dynamic doc) {
    final data = doc.data(); // Extract data from the document
    return RouteData(
      id: doc.id, // Use Firestore document ID as route data ID
      routeDistance: data['routeDistance']?.toDouble() ?? 0.0,
      travelTime: data['travelTime']?.toDouble() ?? 0.0,
      climateIndex: data['climateIndex']?.toDouble() ?? 0.0,
      timestamp: DateTime.parse(data['timestamp']),
      userId: data['userId'],
    );
  }

  // Creates a copy of the RouteData with a new or existing ID (used for immutability)
  RouteData copyWith({
    String? id,
    double? routeDistance,
    double? travelTime,
    double? climateIndex,
    DateTime? timestamp,
    String? userId,
  }) =>
      RouteData(
        id: id ?? this.id,
        routeDistance: routeDistance ?? this.routeDistance,
        travelTime: travelTime ?? this.travelTime,
        climateIndex: climateIndex ?? this.climateIndex,
        timestamp: timestamp ?? this.timestamp,
        userId: userId ?? this.userId,
      );

  // Helper method to get formatted route distance
  String get formattedDistance => '${routeDistance.toStringAsFixed(2)} km';

  // Helper method to get formatted travel time
  String get formattedTravelTime {
    if (travelTime < 60) {
      return '${travelTime.toStringAsFixed(0)} min';
    } else {
      final hours = (travelTime / 60).floor();
      final minutes = (travelTime % 60).round();
      return '${hours}h ${minutes}m';
    }
  }

  // Helper method to get climate index description
  String get climateDescription {
    if (climateIndex < 0.3) return 'Low Impact';
    if (climateIndex < 0.6) return 'Medium Impact';
    return 'High Impact';
  }
}
