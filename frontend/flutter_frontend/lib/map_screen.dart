import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:dio/dio.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final List<Marker> markers = [];
  final List<Map<String, dynamic>> markerData = []; // Store marker data here
  final Dio dio = Dio();
  final String apiUrl = "http://127.0.0.1:8000"; // Django backend URL

  @override
  void initState() {
    super.initState();
    fetchMarkers();
  }

  // Fetch markers from the backend
  Future<void> fetchMarkers() async {
    try {
      Response response = await dio.get("$apiUrl/get_markers/");
      List<dynamic> data = response.data;

      setState(() {
        markers.clear();
        markerData.clear(); // Clear previous marker data
        markers.addAll(data.map((marker) {
          markerData.add({
            'id': marker['id'],
            'name': marker['name'],
            'latitude': marker['latitude'],
            'longitude': marker['longitude'],
          });
          return Marker(
            width: 80.0,
            height: 80.0,
            point: LatLng(marker['latitude'], marker['longitude']),
            child: const Icon(Icons.location_on, color: Colors.teal),
          );
        }).toList());

        // Sort the markers to show the most recent first
        markerData.sort((a, b) => b['id'].compareTo(a['id'])); // Sort by 'id' or creation date
      });
    } catch (e) {
      print("Error fetching markers: $e");
    }
  }

  // Add a new marker to the map
  Future<void> addMarker(LatLng position) async {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Enter Marker Name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Marker Name"),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  try {
                    await dio.post("$apiUrl/add_marker/", data: {
                      "name": nameController.text,
                      "lat": position.latitude,
                      "lng": position.longitude,
                    });
                    fetchMarkers(); // Refresh the marker list
                  } catch (e) {
                    print("Error adding marker: $e");
                  }
                  Navigator.of(ctx).pop();
                } else {
                  // Show error message if the name is empty
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a name for the marker')),
                  );
                }
              },
              child: const Text("Save"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Edit an existing marker
  Future<void> editMarker(int markerId, String name, LatLng position) async {
    try {
      await dio.put("$apiUrl/edit_marker/$markerId/", data: {
        "name": name,
        "lat": position.latitude,
        "lng": position.longitude,
      });
      fetchMarkers();
    } catch (e) {
      print("Error editing marker: $e");
    }
  }

  // Delete a marker from the map
  Future<void> deleteMarker(int markerId) async {
    try {
      await dio.delete("$apiUrl/delete_marker/$markerId/");
      fetchMarkers();
    } catch (e) {
      print("Error deleting marker: $e");
    }
  }

  // Show the update dialog for a marker
  void _showEditDialog(int markerId, String initialName, LatLng position) {
    final nameController = TextEditingController(text: initialName);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Edit Marker"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                editMarker(markerId, nameController.text, position);
                Navigator.of(ctx).pop();
              },
              child: const Text("Update"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  // Show the delete confirmation dialog
  void _showDeleteDialog(int markerId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Delete Marker"),
          content: const Text("Are you sure you want to delete this marker?"),
          actions: [
            TextButton(
              onPressed: () {
                deleteMarker(markerId);
                Navigator.of(ctx).pop();
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      appBar: AppBar(
        title: const Text(
          "Map with CRUD Markers",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          // The FlutterMap widget for displaying the map
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(36.8065, 10.1815),
                initialZoom: 10,
                onTap: (tapPosition, point) {
                  addMarker(point); // Add marker on tap
                },
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(markers: markers),
              ],
            ),
          ),

          // List of markers with update and delete buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.teal, // Same as AppBar color
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: markerData.length, // Use markerData for ListView
                itemBuilder: (ctx, index) {
                  final marker = markerData[index];
                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      title: Text(
                        marker['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Latitude: ${marker['latitude']}, Longitude: ${marker['longitude']}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _showEditDialog(
                                marker['id'],
                                marker['name'],
                                LatLng(marker['latitude'], marker['longitude']),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteDialog(marker['id']);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
