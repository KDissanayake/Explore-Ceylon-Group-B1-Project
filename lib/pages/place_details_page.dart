import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:useraccount/components/LoadingDialog.dart';
import 'package:useraccount/components/appbar.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_performance/firebase_performance.dart';
import 'package:useraccount/functions/PermissionHandler.dart';

class PlaceDetailsPage extends StatefulWidget {
  final String locationName;
  final String description;
  final List<String> images;
  final double latitude;
  final double longitude;

  PlaceDetailsPage({
    required this.locationName,
    required this.description,
    required this.images,
    required this.latitude,
    required this.longitude,
  });

  @override
  _PlaceDetailsPageState createState() => _PlaceDetailsPageState();
}

class _PlaceDetailsPageState extends State<PlaceDetailsPage> {
  bool isExpanded = false;
  bool isLoadingMap = false; // Track whether the map is loading

  @override
  Widget build(BuildContext context) {
    final int maxLength = 270;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight * 1.5),
        child: CustomAppBarWithProfile(
          context: context,
          height: kToolbarHeight * 1.5, // Define the height of the app bar
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CarouselSlider(
              items: widget.images.map((url) {
                return Container(
                  margin: EdgeInsets.only(
                      left: 1.0, right: 1.0, bottom: 10.0, top: 20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    image: DecorationImage(
                      image: NetworkImage(url),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 250.0,
                enlargeCenterPage: true,
                autoPlay: true,
                aspectRatio: 16 / 9,
                autoPlayCurve: Curves.fastOutSlowIn,
                enableInfiniteScroll: true,
                autoPlayAnimationDuration: Duration(milliseconds: 800),
                viewportFraction: 0.85,
              ),
            ),
            SizedBox(height: 10),
            Container(
              margin: EdgeInsets.only(left: 25.0, right: 25.0),
              decoration: BoxDecoration(
                color: Color(0xFF182727),
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.only(
                  top: 16.0, bottom: 16.0, left: 25.0, right: 25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.locationName,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    widget.description.length <= maxLength
                        ? widget.description
                        : (isExpanded
                            ? widget.description
                            : '${widget.description.substring(0, maxLength)}...'),
                    style: TextStyle(
                      fontSize: 16.0,
                      fontFamily: 'Poppins',
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  if (!isExpanded && widget.description.length > maxLength)
                    SizedBox(height: 10),
                  if (!isExpanded && widget.description.length > maxLength)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded = true;
                        });
                      },
                      child: Text(
                        'Read More',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () {
                    launchUber(
                      widget.locationName,
                      widget.latitude,
                      widget.longitude,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF182727),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  ),
                  icon: Icon(
                    Icons.directions_car,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  iconSize: 24,
                ),
                SizedBox(width: 35),
                IconButton(
                  onPressed: () async {
                    bool permissionGranted =
                        await LocationPermissionHandler.requestPermission(
                            context);
                    if (permissionGranted) {
                      _showLoadingDialog(
                          context); // Show loading dialog when pressed
                      _getAndLaunchDirections(
                          widget.latitude, widget.longitude);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF182727),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  ),
                  icon: Icon(
                    Icons.directions,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  iconSize: 24,
                ),
                SizedBox(width: 35),
                IconButton(
                  onPressed: () {
                    addToTravelPlan(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF182727),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    elevation: 5,
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  ),
                  icon: Icon(
                    Icons.favorite_border,
                    color: Colors.red,
                  ),
                  iconSize: 24,
                ),
              ],
            ),
            SizedBox(height: 20),
            if (isLoadingMap)
              LoadingDialog(message: 'Loading Map...', iconData: Icons.map),
          ],
        ),
      ),
      backgroundColor: Color(0xFF456461),
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

  Future<void> _getAndLaunchDirections(
      double destinationLatitude, double destinationLongitude) async {
    final FirebasePerformance performance = FirebasePerformance.instance;
    final Trace trace = performance.newTrace('PlaceDetails_Directions');

    trace.start();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    double userLatitude = position.latitude;
    double userLongitude = position.longitude;

    final response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$userLatitude,$userLongitude&destination=$destinationLatitude,$destinationLongitude&key=AIzaSyBmsouuN42Dw52CXxXkb1QO_aktu7cL5iI'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<LatLng> points;
      try {
        if (data.containsKey('routes') && data['routes'].isNotEmpty) {
          points =
              _decodePoly(data['routes'][0]['overview_polyline']['points']);

          // Creating the Google Maps polyline
          Set<Polyline> polylines = {};
          polylines.add(Polyline(
            polylineId: PolylineId('Route'),
            points: points,
            color: Colors.blue,
            width: 5,
          ));

          // Opening Google Maps within the app
          setState(() {
            isLoadingMap = true; // Set loading flag to true
          });
          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: Text('Map'), // Adjust the app bar title as needed
              ),
              body: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(7.8731, 80.7718), // Center of Sri Lanka
                  zoom: 8, // Adjust the zoom level as needed
                ),
                markers: {
                  Marker(
                    markerId: MarkerId('Destination'),
                    position: LatLng(destinationLatitude, destinationLongitude),
                    infoWindow: InfoWindow(title: 'Destination'),
                  ),
                },
                polylines: polylines,
                onMapCreated: (GoogleMapController controller) {
                  // Once map is created, dismiss loading dialog
                  setState(() {
                    isLoadingMap = false;
                  });
                },
              ),
            );
          })).then((_) {
            // Dismiss loading dialog when map screen is popped
            Navigator.pop(context);
          });
        } else {
          // Handle the case when no routes are found
          throw 'No routes found';
        }
      } catch (e) {
        // Handle any errors
        _showErrorDialog(context, "Failed to create route. Please try again.");
        print('Error: $e');
      }

      trace.stop();
    } else {
      // Handle error if the HTTP request fails
      _showErrorDialog(context, "Failed to load directions. Please try again.");
      throw 'Failed to load directions';
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

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

  Future<void> addToTravelPlan(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final travelPlanRef =
          FirebaseFirestore.instance.collection('travel_plans');
      final querySnapshot =
          await travelPlanRef.where('userId', isEqualTo: user.uid).get();
      final int index = querySnapshot.docs.length;

      await travelPlanRef.add({
        'locationName': widget.locationName,
        'description': widget.description,
        'latitude': widget.latitude,
        'longitude': widget.longitude,
        'userId': user.uid,
        'index': index + 1,
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Added to Travel Plan')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please login to add to Travel Plan')));
    }
  }

  void launchUber(
      String locationName, double latitude, double longitude) async {
    final url =
        "https://m.uber.com/ul/?client_id=0KWrX_G46pj2vTlfLozvaHOHKpcRgYSD&action=setPickup&pickup=my_location&dropoff[latitude]=$latitude&dropoff[longitude]=$longitude&dropoff[nickname]=$locationName";
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print("Could not launch Uber");
      }
    } catch (e) {
      print("Error launching Uber: $e");
    }
  }
}
