import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:useraccount/components/appbar.dart';
import 'package:useraccount/components/loading.dart';
import 'package:useraccount/pages/AI_bot.dart';
import 'package:useraccount/pages/BudgetTracker.dart'; // Import the file where UserBudgetTrackerPage is defined
import 'package:useraccount/pages/Chat.dart';
import 'package:useraccount/pages/CurrencyConv.dart';
import 'package:useraccount/pages/Emergency.dart';
import 'package:useraccount/pages/Home.dart';
import 'package:useraccount/pages/TravelPlanner.dart';
import 'package:useraccount/pages/weather.dart';
import 'firebase_options.dart';
import 'package:useraccount/pages/Signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
    return FutureBuilder(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        } else if (snapshot.hasError) {
          return MaterialApp(
            home: Scaffold(
              body: Center(
                child: Text('Error: ${snapshot.error}'),
              ),
            ),
          );
        } else {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            home: SigninForm(),
            supportedLocales: [
              const Locale('en', ''), // English
              const Locale('ru', ''), // Russian
            ],
            localizationsDelegates: [
              // Add the AppLocalizations delegate here
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale?.languageCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
          );
        }
      },
    );
  }

  Future<void> _initializeApp() async {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    await Future.delayed(Duration(seconds: 1));
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    MapPage(),
    TripPlannerPage(),
    ChatPage(),
    Container(), // Placeholder for removed UserProfile
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _showAdditionalOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF182727),
      builder: (BuildContext context) {
        return ListView(
          // Change Column to ListView
          shrinkWrap: true,
          children: [
            ListTile(
              leading: Icon(
                Icons.attach_money,
                color: Colors.white,
              ),
              title:
                  Text('Budget Tracker', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserBudgetTrackerPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.smart_toy,
                color: Colors.white,
              ),
              title: Text('Travel Bot', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AIchat(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.cloud,
                color: Colors.white,
              ),
              title: Text('Weather', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeatherPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.monetization_on,
                color: Colors.white,
              ),
              title: Text('Currency Converter',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _navigateToCurrencyConverter(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.local_hospital,
                color: Colors.white,
              ),
              title: Text('Emergency Contact',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context); // Close the bottom sheet
                _showEmergencyContacts(
                    context); // Call method to show EmergencyContacts
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToCurrencyConverter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Color(0xFF182727),
      builder: (BuildContext context) {
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                FocusScope.of(context)
                    .unfocus(); // Dismiss keyboard when tapping outside text field
              },
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom +
                        40.0, // Adjust bottom padding to increase amount of movement
                  ),
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Currency Converter',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 20),
                        CurrencyConv(), // Add CurrencyConv widget here
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBody: true,
        drawer: Drawer(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DrawerHeader(
                  child: Text('Drawer Header'),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                ),
                ListTile(
                  title: Text('Budget Tracker'),
                  onTap: () {
                    // Close the drawer
                  },
                ),
                ListTile(
                  title: Text('Travel Bot'),
                  onTap: () {},
                ),
                ListTile(
                  title: Text('Weather'),
                  onTap: () {
                    // Handle weather functionality
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: Text('Currency Converter'),
                  onTap: () {
                    // Handle currency converter functionality
                    Navigator.pop(context);
                    _navigateToCurrencyConverter(context);
                  },
                ),
                ListTile(
                  title: Text('Emergency Contact'),
                  onTap: () {
                    // Handle emergency contact functionality
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: ClipRRect(
            borderRadius: BorderRadius.circular(
                20.0), // Modify this value to adjust the curvature
            child: Theme(
              data: Theme.of(context).copyWith(
                canvasColor: Color(0xFF182727), // Set the canvas color to black
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(
                      20.0), // Modify this value to adjust the curvature
                  child: BottomNavigationBar(
                    elevation: 50,
                    items: const <BottomNavigationBarItem>[
                      BottomNavigationBarItem(
                        icon: Icon(Icons.map),
                        label: 'Map',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.checklist),
                        label: 'Go To',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.chat),
                        label: 'Chat',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.menu), // Icon for additional options
                        label: 'More',
                      ),
                    ],
                    currentIndex: _selectedIndex,
                    selectedItemColor: Colors.orange,
                    onTap: (index) {
                      if (index == 3) {
                        // Show additional options when the last item is tapped
                        _showAdditionalOptions(context);
                      } else {
                        _onItemTapped(index);
                      }
                    },
                  ),
                ),
              ),
            )));
  }
}

class MapPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(),
        body: Center(
          child: HomePage(
            currentUserId: FirebaseAuth.instance.currentUser!.uid,
          ),
        ));
  }
}

class TripPlannerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: TravelPlanScreen(),
    );
  }
}

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child:
          BlogChatPage(currentUserId: FirebaseAuth.instance.currentUser!.uid),
    );
  }
}

class UserBudgetTrackerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
            BudgetTrackerPage(), // Assuming BudgetTrackerPage is the page for budget tracking functionality
      ),
    );
  }
}

void _showEmergencyContacts(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Color(0xFF182727),
    builder: (BuildContext context) {
      return BottomEmergencyContacts(); // Show EmergencyContacts as a bottom sheet
    },
  );
}
