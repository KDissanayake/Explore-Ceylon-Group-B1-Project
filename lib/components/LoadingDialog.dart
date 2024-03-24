import 'package:flutter/material.dart';

class LoadingDialog extends StatelessWidget {
  final String message;
  final IconData iconData;

  const LoadingDialog({Key? key, required this.message, required this.iconData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.0),
          color: Color(0xFF456461),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 50,
              height: 50,
              child: Icon(
                iconData,
                size: 50,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 20),
            Text(
              message,
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
