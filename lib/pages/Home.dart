import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:useraccount/components/preference_slider.dart';
import 'package:useraccount/pages/place_details_page.dart';
import 'package:firebase_performance/firebase_performance.dart';

void main() {
  runApp(MaterialApp(
    home: HomePage(currentUserId: 'user_id'),
    debugShowCheckedModeBanner: false,
  ));
}

class HomePage extends StatelessWidget {
  final String currentUserId;

  const HomePage({required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorObservers: [
        NavigatorObserver(),
      ],
      home: Scaffold(
        body: MapPage(currentUserId: currentUserId),
      ),
    );
  }
}

class MapPage extends StatefulWidget {
  final String currentUserId;

  const MapPage({Key? key, required this.currentUserId}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Set<Marker> markers = {};
  CameraPosition initialCameraPosition =
      const CameraPosition(target: LatLng(7.8731, 80.7718), zoom: 7.5);
  late List<String> allPreferences;
  late List<String> selectedPreferences;
  late Map<String, Color> preferenceColors;
  String selectedProvince = 'All Provinces';
  LatLngBounds? selectedProvinceBounds;

  @override
  void initState() {
    super.initState();
    _fetchMarkers();
    _fetchUserPreferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: initialCameraPosition,
              markers: markers,
              onTap: (_) {
                _closeMarkerDetails();
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: Padding(
        padding:
            const EdgeInsets.only(bottom: 70), // Adjust this value as needed
        child: FloatingActionButton(
          onPressed: () {
            _showPreferenceSlider();
          },
          backgroundColor: Color(0xFF456461),
          child: Icon(Icons.filter_list,
              color: Color.fromARGB(255, 255, 255, 255)),
        ),
      ),
    );
  }

  void _fetchMarkers() async {
    final Trace trace = FirebasePerformance.instance.newTrace('fetch_markers');
    trace.start();

    final markersSnapshot =
        await FirebaseFirestore.instance.collection('markers').get();

    final List<Marker> markersList = [];

    markersSnapshot.docs.forEach((DocumentSnapshot document) {
      final data = document.data() as Map<String, dynamic>;
      final locationName = data['locationName'] ?? '';
      final description = data['description'] ?? '';
      final images = List<String>.from(data['images'] ?? []);

      final coordinates = data['coordinates'];
      if (coordinates != null && coordinates is GeoPoint) {
        final latitude = coordinates.latitude;
        final longitude = coordinates.longitude;

        final List<dynamic>? preferencesData = data['preferences'];
        final List<String> preferences = preferencesData != null
            ? List<String>.from(preferencesData.map((pref) => pref['name']))
            : [];

        if (_markerMatchesPreferences(preferences) &&
            _markerIsInSelectedProvince(latitude, longitude)) {
          // Get the color associated with the first preference of the marker
          final String firstPreference =
              preferences.isNotEmpty ? preferences.first : '';
          final Color? markerColor = preferenceColors[firstPreference];

          // Create a marker icon with the color
          final BitmapDescriptor markerIcon =
              BitmapDescriptor.defaultMarkerWithHue(markerColor != null
                  ? _getColorHue(markerColor)
                  : BitmapDescriptor.hueRed);

          final Marker marker = Marker(
            markerId: MarkerId(locationName),
            position: LatLng(latitude, longitude),
            icon: markerIcon, // Set the marker icon
            onTap: () {
              _onMarkerTapped(
                  locationName, description, images, latitude, longitude);
            },
          );

          markersList.add(marker);
        }
      }
    });

    setState(() {
      markers = Set<Marker>.from(markersList);
    });

    trace.stop();
  }

// Helper function to convert Color to Hue value
  double _getColorHue(Color color) {
    HSVColor hsvColor = HSVColor.fromColor(color);
    return hsvColor.hue;
  }

  bool _markerMatchesPreferences(List<String> markerPreferences) {
    // Check if any of the marker's preferences are in the selected preferences list
    return markerPreferences
        .any((preference) => selectedPreferences.contains(preference));
  }

  bool _markerIsInSelectedProvince(double latitude, double longitude) {
    if (selectedProvince == 'All Provinces') {
      // If 'All Provinces' is selected, all markers are considered to be in selected province
      return true;
    }

    // Check if the marker's coordinates are within the bounds of the selected province
    if (selectedProvinceBounds != null) {
      final LatLng markerPosition = LatLng(latitude, longitude);
      return selectedProvinceBounds!.contains(markerPosition);
    }

    // Return false if selected province bounds are not defined
    return false;
  }

  void _fetchUserPreferences() async {
    final userPreferencesTrace =
        FirebasePerformance.instance.newTrace('fetch_user_preferences');
    userPreferencesTrace.start();

    final userPreferencesSnapshot = await FirebaseFirestore.instance
        .collection('userPreferences')
        .doc(widget.currentUserId)
        .get();

    final dynamic userPreferencesData =
        userPreferencesSnapshot.data()?['preferences'];

    if (userPreferencesData != null) {
      final List<Map<String, dynamic>> preferencesList =
          List<Map<String, dynamic>>.from(userPreferencesData);

      setState(() {
        allPreferences = preferencesList
            .map<String>((pref) => pref['preference'] as String)
            .toList();
        selectedPreferences = List<String>.from(allPreferences);
        preferenceColors = {};
        for (final pref in preferencesList) {
          final String preference = pref['preference'];
          final String colorHex = pref['color'];
          preferenceColors[preference] =
              Color(int.parse(colorHex.replaceAll('#', '0xFF')));
        }
      });
    }

    userPreferencesTrace.stop();
  }

  void _onMarkerTapped(String locationName, String description,
      List<String> images, double latitude, double longitude) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final int maxDescriptionLength = 50;
        String shortenedDescription = description;

        if (description.split(' ').length > maxDescriptionLength) {
          final List<String> words = description.split(' ');
          shortenedDescription =
              words.sublist(0, maxDescriptionLength).join(' ');
          shortenedDescription += '...';
        }

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  locationName,
                  style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins'),
                ),
                SizedBox(height: 8.0),
                Text(
                  shortenedDescription,
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey[800],
                      fontFamily: 'Poppins'),
                ),
                SizedBox(height: 16.0),
                Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlaceDetailsPage(
                            locationName: locationName,
                            description: description,
                            images: images,
                            latitude: latitude,
                            longitude: longitude,
                          ),
                        ),
                      );
                    },
                    child: Text(
                      'Read More',
                      style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16.0,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPreferenceSlider() {
    // Calculate the initial camera position to show the entire map of Sri Lanka

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          color: Color(0xFF456461),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Preferences',
                style: TextStyle(color: Colors.white, fontSize: 18.0),
              ),
              SizedBox(height: 16.0),
              Text(
                'Select Province:',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
              DropdownButton<String>(
                value: selectedProvince,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedProvince = newValue!;
                    _updateCameraPosition();
                    _fetchMarkers();
                  });
                },
                items: <String>[
                  'All Provinces',
                  'Western Province',
                  'Central Province',
                  'Southern Province',
                  'Northern Province',
                  'Eastern Province',
                  'North Western Province',
                  'North Central Province',
                  'Uva Province',
                  'Sabaragamuwa Province',
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              Text(
                'Select Preferences:',
                style: TextStyle(color: Colors.white, fontSize: 16.0),
              ),
              PreferenceSlider(
                allPreferences: allPreferences,
                selectedPreferences: selectedPreferences,
                onPreferencesChanged: (selectedPrefs) {
                  setState(() {
                    selectedPreferences = selectedPrefs;
                  });
                  _fetchMarkers();
                },
                preferenceColors:
                    preferenceColors, // Pass the preferenceColors map here
              ),
            ],
          ),
        );
      },
    );
  }

  void _closeMarkerDetails() {
    print('Marker details closed');
  }

  void _updateCameraPosition() {
    // Define camera positions and bounds for each province
    switch (selectedProvince) {
      case 'Western Province':
        initialCameraPosition =
            CameraPosition(target: LatLng(6.9271, 79.8612), zoom: 8);
        selectedProvinceBounds = LatLngBounds(
            southwest: LatLng(6.6565, 79.7432),
            northeast: LatLng(7.2439, 80.0693));
        break;
      case 'Central Province':
        initialCameraPosition =
            CameraPosition(target: LatLng(7.2906, 80.6337), zoom: 8);
        selectedProvinceBounds = LatLngBounds(
            southwest: LatLng(6.7557, 80.3972),
            northeast: LatLng(7.7868, 81.1605));
        break;
      case 'Southern Province':
        initialCameraPosition =
            CameraPosition(target: LatLng(6.1871, 80.9182), zoom: 8);
        selectedProvinceBounds = LatLngBounds(
            southwest: LatLng(5.9546, 80.4592),
            northeast: LatLng(6.6255, 81.4564));
        break;
      case 'Northern Province':
        initialCameraPosition =
            CameraPosition(target: LatLng(9.6627, 80.0250), zoom: 8);
        selectedProvinceBounds = LatLngBounds(
            southwest: LatLng(8.7364, 79.6835),
            northeast: LatLng(10.3401, 80.5565));
        break;
      case 'Eastern Province':
        initialCameraPosition =
            CameraPosition(target: LatLng(7.8754, 81.0030), zoom: 8);
        selectedProvinceBounds = LatLngBounds(
            southwest: LatLng(7.1475, 80.4928),
            northeast: LatLng(8.6965, 81.4507));
        break;
      case 'North Western Province':
        initialCameraPosition =
            CameraPosition(target: LatLng(7.4876, 80.3636), zoom: 8);
        selectedProvinceBounds = LatLngBounds(
            southwest: LatLng(7.0536, 79.9594),
            northeast: LatLng(7.8585, 80.8535));
        break;
      case 'North Central Province':
        initialCameraPosition =
            CameraPosition(target: LatLng(8.0632, 80.8810), zoom: 8);
        selectedProvinceBounds = LatLngBounds(
            southwest: LatLng(7.4256, 80.2701),
            northeast: LatLng(8.6663, 81.3529));
        break;
      case 'Uva Province':
        initialCameraPosition =
            CameraPosition(target: LatLng(6.8860, 81.0587), zoom: 8);
        selectedProvinceBounds = LatLngBounds(
            southwest: LatLng(6.4171, 80.5276),
            northeast: LatLng(7.1931, 81.5895));
        break;
      case 'Sabaragamuwa Province':
        initialCameraPosition =
            CameraPosition(target: LatLng(6.7470, 80.6386), zoom: 8);
        selectedProvinceBounds = LatLngBounds(
            southwest: LatLng(6.3798, 80.2862),
            northeast: LatLng(7.1137, 81.0738));
        break;
      default:
        initialCameraPosition =
            CameraPosition(target: LatLng(7.8731, 80.7718), zoom: 7);
        selectedProvinceBounds = null;
    }
  }
}
