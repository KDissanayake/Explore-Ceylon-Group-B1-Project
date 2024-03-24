// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:useraccount/pages/Bot.dart';
// import 'package:useraccount/pages/BudgetTracker.dart'; // Import your BudgetTrackerPage
// import 'package:useraccount/pages/Chat.dart';
// import 'package:useraccount/pages/CurrencyConv.dart';
// import 'package:useraccount/pages/Emergency.dart';
// import 'package:useraccount/pages/Home.dart';
// import 'package:useraccount/pages/TravelPlanner.dart';
// import 'package:useraccount/pages/UserProfile.dart';
// import 'package:useraccount/pages/weather.dart';

// class CustomBottomNavigationBar extends StatefulWidget {
//   final int currentIndex;
//   final Function(int) onTap;

//   CustomBottomNavigationBar({
//     required this.currentIndex,
//     required this.onTap,
//   });

//   @override
//   _CustomBottomNavigationBarState createState() =>
//       _CustomBottomNavigationBarState();
// }

// class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
//   double _height = 60.0;
//   Color backgroundColor = Color(0xFF182727); // Set the desired background color

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 300),
//       height: _height,
//       decoration: BoxDecoration(
//         color: backgroundColor, // Use the state variable for background color
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.5),
//             spreadRadius: 3,
//             blurRadius: 10,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: BottomNavigationBar(
//         currentIndex: widget.currentIndex,
//         onTap: (index) {
//           if (index != 2) {
//             // Check if the current index is the same as the tapped index
//             if (index != widget.currentIndex) {
//               widget.onTap(index);
//               setState(() {
//                 _height = 60.0; // Reset height after tap
//               });
//             }
//           }

//           if (index == 0) {
//             // Check if already on the Home page
//             if (widget.currentIndex != 0) {
//               Navigator.pushReplacement(
//                 context,
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) =>
//                       HomePage(
//                     currentUserId: FirebaseAuth.instance.currentUser!.uid,
//                   ),
//                   transitionsBuilder:
//                       (context, animation, secondaryAnimation, child) {
//                     const begin = Offset(1.0, 0.0);
//                     const end = Offset.zero;
//                     const curve = Curves.ease;
//                     var tween = Tween(begin: begin, end: end)
//                         .chain(CurveTween(curve: curve));
//                     var offsetAnimation = animation.drive(tween);

//                     return SlideTransition(
//                       position: offsetAnimation,
//                       child: child,
//                     );
//                   },
//                 ),
//               );
//             }
//           } else if (index == 3) {
//             // Check if already on the Chat page
//             if (widget.currentIndex != 3) {
//               Navigator.pushReplacement(
//                 context,
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) =>
//                       BlogChatPage(
//                     currentUserId: FirebaseAuth.instance.currentUser!.uid,
//                   ),
//                   transitionsBuilder:
//                       (context, animation, secondaryAnimation, child) {
//                     const begin = Offset(1.0, 0.0);
//                     const end = Offset.zero;
//                     const curve = Curves.ease;
//                     var tween = Tween(begin: begin, end: end)
//                         .chain(CurveTween(curve: curve));
//                     var offsetAnimation = animation.drive(tween);

//                     return SlideTransition(
//                       position: offsetAnimation,
//                       child: child,
//                     );
//                   },
//                 ),
//               );
//             }
//           } else if (index == 4) {
//             // Check if already on the UserProfile page
//             if (widget.currentIndex != 4) {
//               Navigator.pushReplacement(
//                 context,
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) =>
//                       UserProfilePage(
//                     userProfile: FirebaseAuth.instance.currentUser,
//                   ),
//                   transitionsBuilder:
//                       (context, animation, secondaryAnimation, child) {
//                     const begin = Offset(3.0, 0.0);
//                     const end = Offset.zero;
//                     const curve = Curves.ease;
//                     var tween = Tween(begin: begin, end: end)
//                         .chain(CurveTween(curve: curve));
//                     var offsetAnimation = animation.drive(tween);

//                     return SlideTransition(
//                       position: offsetAnimation,
//                       child: child,
//                     );
//                   },
//                 ),
//               );
//             }
//           } else if (index == 1) {
//             // Check if already on the Go-to page
//             if (widget.currentIndex != 1) {
//               Navigator.pushReplacement(
//                 context,
//                 PageRouteBuilder(
//                   pageBuilder: (context, animation, secondaryAnimation) =>
//                       TravelPlanScreen(), // Replace 'GoToPage' with your actual page
//                   transitionsBuilder:
//                       (context, animation, secondaryAnimation, child) {
//                     const begin = Offset(1.0, 0.0);
//                     const end = Offset.zero;
//                     const curve = Curves.ease;
//                     var tween = Tween(begin: begin, end: end)
//                         .chain(CurveTween(curve: curve));
//                     var offsetAnimation = animation.drive(tween);

//                     return SlideTransition(
//                       position: offsetAnimation,
//                       child: child,
//                     );
//                   },
//                 ),
//               );
//             }
//           } else {
//             // Show bottom sheet when "App Drawer" icon is tapped
//             showModalBottomSheet(
//               context: context,
//               isScrollControlled: true,
//               builder: (BuildContext context) {
//                 return SingleChildScrollView(
//                   child: Container(
//                     width: MediaQuery.of(context).size.width,
//                     padding: EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       color: backgroundColor, // Set background color
//                       borderRadius: BorderRadius.only(
//                         topLeft: Radius.circular(20),
//                         topRight: Radius.circular(20),
//                       ),
//                     ),
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Text(
//                           'App Drawer',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18.0,
//                             color: Colors.white, // Set text color
//                           ),
//                         ),
//                         SizedBox(height: 8.0),
//                         // Add navbar items inside the sheet
//                         buildBottomSheetItem(
//                             Icons.account_balance_wallet, 'Budget Tracker', () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   BudgetTrackerPage(), // Replace with your BudgetTrackerPage
//                             ),
//                           );
//                           // Close the bottom sheet
//                         }),
//                         buildBottomSheetItem(
//                             Icons.smart_toy, 'Travel Companion', () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   ChatBotScreen(), // Replace with your BudgetTrackerPage
//                             ),
//                           );
//                         }),
//                         buildBottomSheetItem(Icons.wb_sunny, 'Weather', () {
//                           // Add your onTap logic for "Weather" item
//                           // For example, navigate to the Weather page
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) => WeatherPage(),
//                             ),
//                           );
//                         }),
//                         buildBottomSheetItem(
//                             Icons.attach_money, 'Currency Converter', () {
//                           Navigator.pop(context); // Close the bottom sheet

//                           showModalBottomSheet(
//                             context: context,
//                             isScrollControlled: true,
//                             builder: (BuildContext context) {
//                               return SingleChildScrollView(
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal: 20, vertical: 40),
//                                   decoration: BoxDecoration(
//                                     color: Color(
//                                         0xFF182727), // Change the background color here
//                                     borderRadius: BorderRadius.vertical(
//                                       top: Radius.circular(20),
//                                     ),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.stretch,
//                                     children: [
//                                       Text(
//                                         'Currency Converter',
//                                         textAlign: TextAlign.center,
//                                         style: TextStyle(
//                                           fontSize: 24,
//                                           fontWeight: FontWeight.bold,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                       SizedBox(height: 20),
//                                       CurrencyConv(), // Add CurrencyConv widget here
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             },
//                           );
//                         }),
//                         buildBottomSheetItem(
//                             Icons.local_hospital, 'Emergency Contact', () {
//                           Navigator.pushReplacement(
//                             context,
//                             MaterialPageRoute(
//                               builder: (context) =>
//                                   EmergencyContacts(), // Replace with your BudgetTrackerPage
//                             ),
//                           );
//                         }),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             );
//           }
//         },
//         backgroundColor: Colors.transparent, // Set transparent for fixed type
//         selectedItemColor: Colors.orange, // Set selected item color
//         unselectedItemColor: Colors.white, // Set unselected item color
//         // Choose one of the following options:

//         // Option 1: Set type to fixed for consistent background color
//         type: BottomNavigationBarType.fixed, // Uncomment for fixed type

//         // Option 2: Manage background color manually (uncomment if preferred)
//         // type: BottomNavigationBarType.shifting, // Uncomment for shifting type

//         items: [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.checklist_outlined),
//             label: 'Go-to',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.apps_rounded),
//             label: 'App Drawer',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.chat),
//             label: 'Chat',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Profile',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget buildBottomSheetItem(
//       IconData icon, String title, void Function()? onTap) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.white), // Set icon color
//       title:
//           Text(title, style: TextStyle(color: Colors.white)), // Set text color
//       onTap: onTap,
//     );
//   }
// }
