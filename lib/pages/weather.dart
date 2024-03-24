import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:useraccount/components/appbar.dart';


class WeatherPage extends StatefulWidget {
  @override
  _WeatherPageState createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  TextEditingController _cityController = TextEditingController();
  String _apiKey = '7a9397ce00896a393e326fbbfa615959';
  String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  String _forecastUrl = 'https://api.openweathermap.org/data/2.5/forecast';

  WeatherData? _colomboWeatherData;
  WeatherData? _kandyWeatherData;
  WeatherData? _searchedWeatherData;
  List<WeatherData>? _hourlyForecast;

  @override
  void initState() {
    super.initState();
    _fetchInitialWeather('Colombo');
    _fetchInitialWeather('Kandy');
  }

  Future<void> _fetchInitialWeather(String city) async {
    try {
      final response =
          await http.get(Uri.parse('$_baseUrl?q=$city&appid=$_apiKey'));

      if (response.statusCode == 200) {
        final weatherData = WeatherData.fromJson(json.decode(response.body));
        setState(() {
          if (city == 'Colombo') {
            _colomboWeatherData = weatherData;
          } else if (city == 'Kandy') {
            _kandyWeatherData = weatherData;
          }
        });
      } else {
        throw Exception('Failed to load initial weather data for $city');
      }
    } catch (e) {
      print('Error fetching initial weather data: $e');
    }
  }

  Future<void> _getWeather(String city) async {
    try {
      // Clear previous data for Colombo and Kandy
      setState(() {
        _colomboWeatherData = null;
        _kandyWeatherData = null;
        _searchedWeatherData = null;
        _hourlyForecast = null;
      });

      final response =
          await http.get(Uri.parse('$_baseUrl?q=$city&appid=$_apiKey'));

      if (response.statusCode == 200) {
        final weatherData = WeatherData.fromJson(json.decode(response.body));
        setState(() {
          _searchedWeatherData = weatherData;
        });

        final forecastResponse =
            await http.get(Uri.parse('$_forecastUrl?q=$city&appid=$_apiKey'));

        if (forecastResponse.statusCode == 200) {
          setState(() {
            _hourlyForecast =
                (json.decode(forecastResponse.body)['list'] as List)
                    .map((e) => WeatherData.fromJson(e, isHourly: true))
                    .toList();
          });
        } else {
          throw Exception('Failed to load forecast data for $city');
        }
      } else {
        throw Exception('Failed to load weather data for $city');
      }
    } catch (e) {
      print('Error fetching weather data for $city: $e');
    }
  }

  IconData _getWeatherIcon(WeatherData weatherData) {
    if (weatherData.weather == null) {
      return Icons.error_outline;
    }

    switch (weatherData.weather![0].description.toLowerCase()) {
      case 'clear sky':
        return Icons.wb_sunny;
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
        return Icons.cloud;
      case 'overcast shadow':
        return Icons.filter_drama;
      case 'shower rain':
      case 'rain':
      case 'light rain':
        return Icons.grain;
      case 'light intensity shower rain':
        return Icons.cloudy_snowing;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'snow':
        return Icons.ac_unit;
      default:
        return Icons.error_outline;
    }
  }

  String _getBackgroundImage(WeatherData weatherData) {
    if (weatherData.weather == null || weatherData.weather!.isEmpty) {
      return 'assets/images/weather/default.jpeg';
    }

    switch (weatherData.weather![0].description.toLowerCase()) {
      case 'clear sky':
        return 'assets/images/weather/sunny.jpeg';
      case 'few clouds':
      case 'scattered clouds':
      case 'broken clouds':
        return 'assets/images/weather/cloudy.jpeg';
      case 'shower rain':
      case 'rain':
      case 'light rain':
        return 'assets/images/weather/rainy.jpeg';
      case 'thunderstorm':
        return 'assets/images/weather/thunder.jpeg';
      case 'snow':
        return 'assets/images/weather/snow.png';
      default:
        return 'assets/images/weather/2.png';
    }
  }

  Widget _buildWeatherCard(WeatherData weatherData) {
    return Container(
      width: 300.0,
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: const Color.fromARGB(255, 253, 253, 253),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            _getWeatherIcon(weatherData),
            size: 64.0,
            color: Colors.orange,
          ),
          SizedBox(height: 16.0),
          Text(
            'Weather in ${weatherData.name}',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Text(
            '${weatherData.weather![0].description}',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 8.0),
          Text(
            'Temperature: ${weatherData.main!.temp.toString()}°C',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildHourlyForecastBox(WeatherData forecast) {
    final hour = DateFormat.Hm()
        .format(DateTime.fromMillisecondsSinceEpoch(forecast.dt * 1000));

    return Container(
      width: 100.0,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            hour,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.0),
          Icon(
            _getWeatherIcon(forecast),
            size: 32.0,
            color: const Color.fromARGB(255, 255, 123, 0),
          ),
          SizedBox(height: 8.0),
          Text(
            '${forecast.weather![0].description}',
            style: TextStyle(
                fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.0),
          Text(
            'Temp: ${forecast.main!.temp.toString()}°C',
            style: TextStyle(
                fontSize: 12, color: const Color.fromARGB(255, 0, 0, 0)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight * 1.5),
        child: CustomAppBarWithProfile(
          context: context,
          height: kToolbarHeight * 1.5, // Define the height of the app bar
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(_getBackgroundImage(_searchedWeatherData ??
                _colomboWeatherData ??
                _kandyWeatherData ??
                WeatherData(name: '', main: null, weather: null, dt: 0))),
            fit: BoxFit.cover,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _cityController,
              style: TextStyle(
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
              decoration: InputDecoration(
                labelText: 'Enter city',
                labelStyle: TextStyle(
                  color: const Color.fromARGB(255, 0, 0, 0),
                ),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color.fromARGB(255, 240, 240, 240),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _getWeather(_cityController.text);
                    FocusScope.of(context).unfocus();
                  },
                ),
              ),
            ),
            SizedBox(height: 16.0),
            _colomboWeatherData != null
                ? _buildWeatherCard(_colomboWeatherData!)
                : Container(),
            SizedBox(height: 16.0),
            _kandyWeatherData != null
                ? _buildWeatherCard(_kandyWeatherData!)
                : Container(),
            SizedBox(height: 16.0),
            _searchedWeatherData != null
                ? _buildWeatherCard(_searchedWeatherData!)
                : Container(),
            SizedBox(height: 16.0),
            _hourlyForecast != null
                ? Container(
                    height: 200.0, // Increase the height as needed
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _hourlyForecast!.map((forecast) {
                          return _buildHourlyForecastBox(forecast);
                        }).toList(),
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
      // bottomNavigationBar: CustomBottomNavigationBar(
      //   currentIndex: 2, // Set the current index for the Weather page
      //   onTap: (index) {
      //     // Handle onTap event for the bottom navigation bar
      //     // You can add your logic here if needed
      //     print('Tapped index: $index');
      //   },
      // ),
    );
  }
}

class WeatherData {
  final String name;
  final Main? main;
  final List<Weather>? weather;
  final int dt;

  WeatherData({required this.name, this.main, this.weather, required this.dt});

  factory WeatherData.fromJson(Map<String, dynamic> json,
      {bool isHourly = false}) {
    if (isHourly) {
      return WeatherData(
        name: '',
        main: Main.fromJson(json['main']),
        weather:
            (json['weather'] as List).map((e) => Weather.fromJson(e)).toList(),
        dt: json['dt'],
      );
    } else {
      return WeatherData(
        name: json['name'],
        main: Main.fromJson(json['main']),
        weather:
            (json['weather'] as List).map((e) => Weather.fromJson(e)).toList(),
        dt: json['dt'],
      );
    }
  }
}

class Main {
  final double temp;

  Main({required this.temp});

  factory Main.fromJson(Map<String, dynamic> json) {
    return Main(
      temp: json['temp'].toDouble(),
    );
  }
}

class Weather {
  final String description;

  Weather({required this.description});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      description: json['description'],
    );
  }
}
