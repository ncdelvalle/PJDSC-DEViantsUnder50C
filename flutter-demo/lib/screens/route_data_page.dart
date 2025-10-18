import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_data_provider.dart';

class RouteDataPage extends StatefulWidget {
  const RouteDataPage({super.key});

  @override
  State<RouteDataPage> createState() => _RouteDataPageState();
}

class _RouteDataPageState extends State<RouteDataPage> {
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _climateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Load route data when the page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RouteDataProvider>().loadRouteData();
    });
  }

  @override
  void dispose() {
    _distanceController.dispose();
    _timeController.dispose();
    _climateController.dispose();
    super.dispose();
  }

  void _showAddRouteDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Route Data'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _distanceController,
                  decoration: const InputDecoration(
                    labelText: 'Route Distance (km)',
                    hintText: 'e.g., 5.5',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter route distance';
                    }
                    final distance = double.tryParse(value);
                    if (distance == null || distance < 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _timeController,
                  decoration: const InputDecoration(
                    labelText: 'Travel Time (minutes)',
                    hintText: 'e.g., 30',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter travel time';
                    }
                    final time = double.tryParse(value);
                    if (time == null || time < 0) {
                      return 'Please enter a valid positive number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _climateController,
                  decoration: const InputDecoration(
                    labelText: 'Climate Index (0.0 - 1.0)',
                    hintText: 'e.g., 0.7',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter climate index';
                    }
                    final index = double.tryParse(value);
                    if (index == null || index < 0 || index > 1) {
                      return 'Please enter a value between 0.0 and 1.0';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _distanceController.clear();
                _timeController.clear();
                _climateController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final distance = double.parse(_distanceController.text);
                  final time = double.parse(_timeController.text);
                  final climate = double.parse(_climateController.text);

                  final result = await context.read<RouteDataProvider>().addRouteData(
                    routeDistance: distance,
                    travelTime: time,
                    climateIndex: climate,
                  );

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result),
                        backgroundColor: result.contains('Successfully') 
                            ? Colors.green 
                            : Colors.red,
                      ),
                    );

                    if (result.contains('Successfully')) {
                      _distanceController.clear();
                      _timeController.clear();
                      _climateController.clear();
                      Navigator.of(context).pop();
                    }
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Route Data',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Consumer<RouteDataProvider>(
        builder: (context, routeProvider, child) {
          if (routeProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final routeDataList = routeProvider.routeDataList;
          final statistics = routeProvider.getStatistics();

          return Column(
            children: [
              // Statistics Card
              Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Statistics',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Total Routes: ${statistics['totalRoutes']}'),
                      Text('Total Distance: ${statistics['totalDistance'].toStringAsFixed(2)} km'),
                      Text('Total Time: ${statistics['totalTime'].toStringAsFixed(0)} min'),
                      Text('Average Climate Index: ${statistics['averageClimateIndex'].toStringAsFixed(2)}'),
                    ],
                  ),
                ),
              ),
              // Route Data List
              Expanded(
                child: routeDataList.isEmpty
                    ? const Center(
                        child: Text(
                          'No route data found.\nClick the + button to add some!',
                          textAlign: TextAlign.center,
                        ),
                      )
                    : ListView.builder(
                        itemCount: routeDataList.length,
                        itemBuilder: (context, index) {
                          final routeData = routeDataList[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 4,
                            ),
                            child: ListTile(
                              title: Text(
                                'Route ${index + 1}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Distance: ${routeData.formattedDistance}'),
                                  Text('Time: ${routeData.formattedTravelTime}'),
                                  Text('Climate: ${routeData.climateIndex.toStringAsFixed(2)} (${routeData.climateDescription})'),
                                  Text(
                                    'Date: ${routeData.timestamp.day}/${routeData.timestamp.month}/${routeData.timestamp.year}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  final result = await routeProvider.deleteRouteData(routeData.id!);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result),
                                        backgroundColor: result.contains('Successfully') 
                                            ? Colors.green 
                                            : Colors.red,
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddRouteDataDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
