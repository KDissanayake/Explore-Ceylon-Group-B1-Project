import 'dart:async';
import 'dart:convert';

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:useraccount/components/LoadingDialog.dart';
import 'package:useraccount/main.dart';
import 'package:useraccount/pages/Home.dart';
import 'package:useraccount/pages/Signup.dart';
import 'package:useraccount/pages/UserProfile.dart'; // Import the UserProfile.dart file
import 'package:firebase_performance/firebase_performance.dart'; // Import Firebase Performance Monitoring

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  late Map<String, String> _localizedStrings;

  Future<bool> load() async {
    // Load the language JSON file
    String jsonString = await rootBundle
        .loadString('assets/translations/${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings =
        jsonMap.map((key, value) => MapEntry(key, value.toString()));
    return true;
  }

  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'ru'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

class SigninForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SigninForm> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  String _email = '';
  String _password = '';
  String _selectedLanguage = 'en'; // Default language code

  bool _isLoading = false;

  // Define supported languages with their corresponding language codes
  final List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en'},
    {'name': 'Russian', 'code': 'ru'},
    // Add more languages as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/forest.jpg'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                color: Colors.black.withOpacity(0),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 0),
                    // Image instead of welcome text
                    Image.asset(
                      'assets/images/logo-removebg-preview.png', // Replace with your image path
                      width: 100, // Adjust width as needed
                      height: 150, // Adjust height as needed
                    ),
                    SizedBox(height: 60),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.translate('email'),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('email_error_message');
                        }
                        return null;
                      },
                      onSaved: (newValue) => _email = newValue!,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText:
                            AppLocalizations.of(context)!.translate('password'),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!
                              .translate('password_error_message');
                        }
                        return null;
                      },
                      onSaved: (newValue) => _password = newValue!,
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signInWithEmailPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF182727),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: BorderSide(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                width: 2)),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator() // Show loading indicator
                          : Text(
                              AppLocalizations.of(context)!.translate('login'),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signInWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF182727),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: BorderSide(
                                color: const Color.fromARGB(255, 255, 255, 255),
                                width: 2)),
                      ),
                      child: _isLoading
                          ? CircularProgressIndicator() // Show loading indicator
                          : Text(
                              AppLocalizations.of(context)!
                                  .translate('sign_in_with_google'),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                color: Colors.white,
                              ),
                            ),
                    ),
                    SizedBox(height: 50),
                    // Divider line
                    Container(
                      height: 1,
                      color: Color.fromARGB(110, 255, 255, 255),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SignUpForm()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF456461),
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!
                            .translate('new_user_question'),
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sign-in with email and password method
  void _signInWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });
      _showLoadingDialog(context); // Show loading dialog
      try {
        final FirebasePerformance performance = FirebasePerformance.instance;
        final Trace trace = performance.newTrace('signin_with_email_password');
        trace.start(); // Start performance trace
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        // If sign-in successful, navigate to UserProfile
        Navigator.pop(context); // Close the loading dialog
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
        trace.stop(); // Stop performance trace
      } catch (e) {
        Navigator.pop(context);
        // Handle sign-in error
        // Show error message to the user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Color(0xFF182727),
              title: Text(
                  AppLocalizations.of(context)!.translate('login_failed'),
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.0)),
              content: Text(
                  "Login failed. Please check your email and password and try again.",
                  style: TextStyle(color: Colors.white)),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Sign-in with Google method
  void _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });
    _showLoadingDialog(context); // Show loading dialog
    try {
      final FirebasePerformance performance = FirebasePerformance.instance;
      final Trace trace = performance.newTrace('signin_with_google');
      trace.start(); // Start performance trace
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User user = userCredential.user!;

        // Handle successful sign-in with Google
        // Navigate to UserProfile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
        trace.stop(); // Stop performance trace
      } else {
        // Handle case where googleUser is null
        // For example, show an error message
      }
    } catch (e) {
      print(e);
      // Handle Google sign-in error
      // Show error message to the user
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF182727), // Set background color
            title: Text(
              "Login Failed. Please try again",
              style: TextStyle(
                color: Colors.white, // Set title text color
                fontWeight: FontWeight.bold, // Set title font weight
                fontSize: 18.0, // Set title font size
              ),
            ),
            content: Text(AppLocalizations.of(context)!
                .translate('login_failed_message_google')),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'OK',
                  style: TextStyle(
                    color: Colors.white, // Set button text color
                    fontSize: 16.0, // Set button font size
                  ),
                ),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return LoadingDialog(
          message: 'Logging you in...',
          iconData: Icons.account_circle,
        );
      },
    );
  }
}
