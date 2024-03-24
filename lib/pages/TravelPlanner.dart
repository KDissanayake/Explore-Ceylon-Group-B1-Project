import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:useraccount/components/LoadingDialog.dart';
import 'package:useraccount/components/appbar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

import 'package:firebase_performance/firebase_performance.dart';
import 'package:useraccount/functions/PermissionHandler.dart';

class TravelPlanScreen extends StatefulWidget {
  @override
  _TravelPlanScreenState createState() => _TravelPlanScreenState();
}

class _TravelPlanScreenState extends State<TravelPlanScreen> {
  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1E5;
      double longitude = lng / 1E5;
      points.add(LatLng(latitude, longitude));
    }
    return points;
  }

  late User? _currentUser;
  late Trace _loadingTrace;
  List<Map<String, dynamic>> _locations = [];

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadingTrace =
        FirebasePerformance.instance.newTrace('loading_travel_plans');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      backgroundColor: Color(0xFF456461),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('travel_plans')
            .where('userId', isEqualTo: _currentUser!.uid)
            .orderBy('index', descending: false)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          _loadingTrace.start();

          final travelPlans = snapshot.data!.docs;

          if (travelPlans.isEmpty) {
            _loadingTrace.stop();
            return Center(child: Text('No travel plans yet.'));
          }

          _loadingTrace.stop();

          _locations = travelPlans.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final double latitude = data['latitude'] ?? 0.0;
            final double longitude = data['longitude'] ?? 0.0;
            return {'latitude': latitude, 'longitude': longitude};
          }).toList();

          return ReorderableListView(
            onReorder: (oldIndex, newIndex) =>
                _reorderItems(oldIndex, newIndex),
            children: [
              for (final doc in travelPlans) _buildTravelPlanItem(context, doc),
            ],
          );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton(
          onPressed: () async {
            bool permissionGranted =
                await LocationPermissionHandler.requestPermission(context);
            if (permissionGranted) {
              _showLoadingDialog(context); // Show loading dialog
              final currentLocation = await _getCurrentLocation();
              if (currentLocation != null) {
                _showDirections(currentLocation);
              } else {
                Navigator.pop(
                    context); // Dismiss loading dialog if unable to fetch location
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Unable to fetch current location."),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
          child: Icon(Icons.directions),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(
          message: 'Loading map....',
          iconData: Icons.map,
        );
      },
    );
  }

  Future<void> _reorderItems(int oldIndex, int newIndex) async {
    final Trace reorderTrace =
        FirebasePerformance.instance.newTrace('reordering_items');
    reorderTrace.start();

    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final snapshot = await FirebaseFirestore.instance
        .collection('travel_plans')
        .where('userId', isEqualTo: _currentUser!.uid)
        .orderBy('index', descending: false)
        .get();

    final travelPlans = snapshot.docs;

    final item = travelPlans.removeAt(oldIndex);
    travelPlans.insert(newIndex, item);

    for (int i = 0; i < travelPlans.length; i++) {
      final doc = travelPlans[i];
      await doc.reference.update({'index': i});
    }

    reorderTrace.stop();
  }

  Widget _buildTravelPlanItem(BuildContext context, DocumentSnapshot doc) {
    if (!doc.exists || doc.data() == null) {
      return SizedBox.shrink();
    }

    final data = doc.data() as Map<String, dynamic>;

    // Ensure 'completed' field exists and set it to false if not
    if (!data.containsKey('completed')) {
      doc.reference.update({'completed': false});
    }

    return Dismissible(
      key: Key(doc.id),
      background: Container(
        color: Colors.red,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Confirm"),
              content: Text("Are you sure you want to delete this item?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("CANCEL"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("DELETE"),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        final Trace deleteTrace =
            FirebasePerformance.instance.newTrace('deleting_item');
        deleteTrace.start();

        await doc.reference.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Item deleted successfully."),
            duration: Duration(seconds: 2),
          ),
        );

        deleteTrace.stop();
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        color: Color(0xFF182727),
        child: ListTile(
          leading: Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 32,
          ),
          title: Text(
            data['locationName'],
            style: TextStyle(
              fontFamily: 'Poppins',
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: data['completed'] ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    FirebaseFirestore.instance
                        .collection('travel_plans')
                        .doc(doc.id)
                        .update({'completed': value});
                  });
                },
                checkColor: Colors.white,
                fillColor: MaterialStateProperty.resolveWith((states) {
                  return Color.fromARGB(255, 48, 70, 68);
                }),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              IconButton(
                icon: Icon(Icons.directions),
                color: Colors.white,
                onPressed: () {
                  _openMaps(data['locationName']);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openMaps(String locationName) async {
    // Construct the URL for Google Maps with the provided locationName
    final url = 'https://www.google.com/maps/search/?api=1&query=$locationName';

    // Launch the URL
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<Position?> _getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
    } catch (e) {
      print("Error getting current location: $e");
      return null;
    }
  }

  void _showDirections(Position currentLocation) async {
    final directions = await _getDirections(currentLocation);
    if (directions != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            locations: _locations,
            directions: directions,
            currentLocation: currentLocation,
          ),
        ),
      ).then((value) {
        // Dismiss the loading dialog when returning from the map screen
        Navigator.pop(context);
      });
    } else {
      Navigator.pop(
          context); // Dismiss loading dialog if failed to get directions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to get directions."),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<List<LatLng>?> _getDirections(Position currentLocation) async {
    try {
      final List<LatLng> directions = [];
      LatLng previousLocation =
          LatLng(currentLocation.latitude, currentLocation.longitude);

      for (final location in _locations) {
        final String url =
            'https://maps.googleapis.com/maps/api/directions/json?origin=${previousLocation.latitude},${previousLocation.longitude}&destination=${location['latitude']},${location['longitude']}&key=AIzaSyBmsouuN42Dw52CXxXkb1QO_aktu7cL5iI&mode=driving';
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body);
          final List steps = decoded['routes'][0]['legs'][0]['steps'];
          for (final step in steps) {
            final encodedPolyline = step['polyline']['points'];
            final List<LatLng> decodedPolyline = _decodePoly(encodedPolyline);
            directions.addAll(decodedPolyline);
            previousLocation = decodedPolyline.last;
          }
        } else {
          print('Failed to fetch directions');
          return null;
        }
      }
      return directions;
    } catch (e) {
      print('Error getting directions: $e');
      return null;
    }
  }
}

class MapScreen extends StatelessWidget {
  final List<Map<String, dynamic>> locations;
  final List<LatLng>? directions;
  final Position currentLocation;

  const MapScreen({
    Key? key,
    required this.locations,
    this.directions,
    required this.currentLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF182727),
        centerTitle: true,
        title: Image.asset(
          'assets/images/logo-removebg-preview.png', // Adjust the path to your logo image
          height: 40, // Adjust the height as needed
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white), // Set back icon color to white
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.directions,
                color: Colors.white), // Set direction icon color to white
            onPressed: () {
              _startTripWithGoogleMaps();
            },
          ),
        ],
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(7.8731, 80.7718), // Center of Sri Lanka
          zoom: 8, // Adjust the zoom level as needed
        ),
        markers: _buildMarkers(),
        polylines: _buildPolylines(),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return locations.map((location) {
      final double latitude = location['latitude'];
      final double longitude = location['longitude'];
      return Marker(
        markerId: MarkerId('$latitude,$longitude'),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(title: 'Location'),
      );
    }).toSet();
  }

  Set<Polyline> _buildPolylines() {
    if (directions == null) return {};

    final polylineId = PolylineId("route");
    final polyline = Polyline(
      polylineId: polylineId,
      color: Colors.blue,
      points: directions!,
      width: 3,
    );

    return {polyline};
  }

  void _startTripWithGoogleMaps() async {
    final StringBuffer url =
        StringBuffer('https://www.google.com/maps/dir/?api=1');

    url.write(
        '&origin=${currentLocation.latitude},${currentLocation.longitude}');

    // Add stops for each location except the last one
    for (int i = 0; i < locations.length - 1; i++) {
      final double latitude = locations[i]['latitude'];
      final double longitude = locations[i]['longitude'];
      url.write('&waypoints=$latitude,$longitude');
    }

    // Add the last location as the final destination
    final double lastLatitude = locations.last['latitude'];
    final double lastLongitude = locations.last['longitude'];
    url.write('&destination=$lastLatitude,$lastLongitude');

    if (await canLaunch(url.toString())) {
      await launch(url.toString());
    } else {
      throw 'Could not launch $url';
    }
  }
}
