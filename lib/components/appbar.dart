import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:useraccount/pages/UserProfile.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;

  const CustomAppBar({
    Key? key,
    this.height = kToolbarHeight * 1.5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Color(0xFF182727),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logo-removebg-preview.png',
              height: height * 0.6,
              fit: BoxFit.fitHeight,
            ),
            SizedBox(
                width:
                    10), // Add some spacing between the logo and profile icon
            Align(
              alignment: Alignment.bottomCenter,
              child: IconButton(
                icon: const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color.fromARGB(0, 33, 149, 243),
                  child: Icon(
                    Icons.person,
                    size: 30,
                    color: Colors.white,
                  ),
                ),
                color: Colors.white,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => UserProfilePage(
                        userProfile: FirebaseAuth.instance.currentUser,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}

class CustomAppBarWithProfile extends StatelessWidget {
  final BuildContext context;
  final double height; // Define height here

  const CustomAppBarWithProfile({
    Key? key,
    required this.context,
    required this.height, // Include height as a parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Color(0xFF182727),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Image.asset(
              'assets/images/logo-removebg-preview.png',
              height: height * 0.6,
              fit: BoxFit.fitHeight,
            ),
            IconButton(
              icon: Icon(Icons.person),
              color: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(
                        userProfile: FirebaseAuth.instance.currentUser),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
