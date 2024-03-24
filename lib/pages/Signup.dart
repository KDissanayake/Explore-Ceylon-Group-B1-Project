import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:useraccount/components/LoadingDialog.dart';
import 'package:useraccount/main.dart';
import 'package:useraccount/pages/Signin.dart';
import 'package:firebase_performance/firebase_performance.dart';

class SignUpForm extends StatefulWidget {
  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _firestore = FirebaseFirestore.instance;

  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  bool _passwordsMatch = true;
  bool _validPasswordLength = true;
  List<Map<String, dynamic>> _selectedPreferences = [];

  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  @override
  void initState() {
    super.initState();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validatePasswords() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
      _validPasswordLength = _passwordController.text.length >= 6;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/forest.jpg'),
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
                    SizedBox(height: 50),
                    // Image instead of welcome text
                    Image.asset(
                      'assets/images/logo-removebg-preview.png', // Change image path
                      width: 100, // Adjust width as needed
                      height: 150, // Adjust height as needed
                    ),
                    SizedBox(height: 50),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email address.';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address.';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _email = newValue!,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        errorText: !_validPasswordLength
                            ? 'Password must be at least 6 characters long.'
                            : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password.';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _password = newValue!,
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'Confirm Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(40.0),
                        ),
                        errorText:
                            !_passwordsMatch ? 'Passwords do not match.' : null,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password.';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match.';
                        }
                        return null;
                      },
                      onSaved: (newValue) => _confirmPassword = newValue!,
                    ),
                    SizedBox(height: 30),
                    Text(
                      'Why are you visiting Sri Lanka?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 10,
                      children: _buildPreferenceChips(),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _signUpWithEmailPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF182727),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: BorderSide(color: Colors.white, width: 2)),
                      ),
                      child: Text(
                        'Create',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _signUpWithGoogle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF182727),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: BorderSide(color: Colors.white, width: 2)),
                      ),
                      child: Text(
                        'Sign Up with Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 50),
                    Container(
                      height: 1,
                      color: Color.fromARGB(110, 255, 255, 255),
                      margin: EdgeInsets.symmetric(horizontal: 20),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => SigninForm()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF456461),
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(40),
                          side: BorderSide(color: Colors.white),
                        ),
                      ),
                      child: Text(
                        'Already have an account? \n Login here',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Loading dialog
          if (_loading)
            LoadingDialog(message: _loadingMessage, iconData: _loadingIconData),
        ],
      ),
    );
  }

  List<Widget> _buildPreferenceChips() {
    return [
      SizedBox(height: 10),
      StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('preferences').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }
          List<Map<String, dynamic>> preferences =
              snapshot.data!.docs.map((doc) {
            return {
              'name': doc['name'] as String,
              'color': doc['color'] as String,
            };
          }).toList();

          return Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            children: preferences.map((preference) {
              bool isSelected = _selectedPreferences
                  .any((element) => element['name'] == preference['name']);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedPreferences.removeWhere(
                          (element) => element['name'] == preference['name']);
                    } else {
                      _selectedPreferences.add(preference);
                    }
                  });
                },
                child: Chip(
                  label: Text(preference['name']),
                  backgroundColor: isSelected ? Colors.green : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    ];
  }

  bool _loading = false;
  String _loadingMessage = '';
  IconData _loadingIconData = Icons.hourglass_empty;

  void _signUpWithEmailPassword() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _loading = true;
        _loadingMessage = 'Creating account...';
        _loadingIconData = Icons.account_circle;
      });

      try {
        final userCredential = await _auth.createUserWithEmailAndPassword(
          email: _email,
          password: _password,
        );

        _savePreferences(userCredential.user!.uid);

        // Redirect to UserProfile page upon successful sign-up
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
        );
      } catch (e) {
        // Handle sign-up errors
        setState(() {
          _loading = false;
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Account Creation Failed"),
                content: Text("Failed to create an account. Please try again."),
                actions: [
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
        });
      }
    }
  }

  void _savePreferences(String userId) {
    List<Map<String, dynamic>> preferencesData = [];
    for (int i = 0; i < _selectedPreferences.length; i++) {
      preferencesData.add({
        'preference': _selectedPreferences[i]['name'],
        'color': _selectedPreferences[i]
            ['color'], // Placeholder for color, not retrieved from Firestore
      });
    }

    _firestore.collection('userPreferences').doc(userId).set({
      'preferences': preferencesData,
    }).then((value) {
      print('User preferences saved successfully');
    }).catchError((error) {
      print('Failed to save user preferences: $error');
    });
  }

  void _signUpWithGoogle() async {
    setState(() {
      _loading = true;
      _loadingMessage = 'Creating account...';
      _loadingIconData = Icons.account_circle;
    });

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      if (userCredential.additionalUserInfo!.isNewUser) {
        print(
            'New user signed up with Google: ${userCredential.user!.displayName}');
        _savePreferences(userCredential
            .user!.uid); // Save preferences for new Google sign-up users
      } else {
        print(
            'Existing user signed in with Google: ${userCredential.user!.displayName}');
      }

      // Redirect to UserProfile page upon successful sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen()),
      );
    } catch (e) {
      print(e);
      setState(() {
        _loading = false;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Account Creation Failed"),
              content: Text("Failed to create an account. Please try again."),
              actions: [
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
      });
    }
  }
void _showLoadingDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text(
              _loadingMessage,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    },
  );
}
}

void main() {
  runApp(MaterialApp(
    home: SignUpForm(),
  ));
}
