import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BottomEmergencyContacts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Color(0xFF182727), // Adjusted color
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Emergency Contacts',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            _buildEmergencyContact(
              context,
              contactName: 'Police',
              phoneNumber: '118 / 119',
            ),
            SizedBox(height: 10.0),
            _buildEmergencyContact(
              context,
              contactName: 'Ambulance / Fire & rescue',
              phoneNumber: '110',
            ),
            SizedBox(height: 10.0),
            _buildEmergencyContact(
              context,
              contactName: 'Tourist Police',
              phoneNumber: '011-2421052',
            ),
            SizedBox(height: 10.0),
            _buildEmergencyContact(
              context,
              contactName: 'Accident Service-General Hospital-Colombo',
              phoneNumber: '011-2691111',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContact(
    BuildContext context, {
    required String contactName,
    required String phoneNumber,
  }) {
    return GestureDetector(
      onTap: () => _launchDialer(phoneNumber),
      child: Container(
        padding: EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Color(0xFF30444D),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                contactName,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.phone,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  _launchDialer(String dialCode) async {
    final url = 'tel:$dialCode';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('Could not launch $url');
    }
  }
}
