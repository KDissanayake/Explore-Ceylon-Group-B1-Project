
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5), // Change duration as needed
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    )..addListener(() {
        setState(() {});
      });
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr, // Adjust text direction as needed
      child: Scaffold(
        body: Stack(
          children: [
            // Background with zooming and blurring effect
            Transform.scale(
              scale: 1 + _animation.value * 0.5, // Zoom effect
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/images/forest.jpg'), // Replace with your background image
                    fit: BoxFit.cover,
                  ),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: _animation.value * 5,
                      sigmaY: _animation.value * 5), // Blurring effect
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.5), // Adjust opacity as needed
                  ),
                ),
              ),
            ),
            // Logo in the middle
            Center(
              child: Image.asset(
                'assets/images/logo-removebg-preview.png', // Replace with your logo image
                width: 200, // Adjust size as needed
                height: 200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
