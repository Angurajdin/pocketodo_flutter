import 'package:flutter/material.dart';
import 'package:pocketodo/shared/constants.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPurple,
      appBar: AppBar(
          backgroundColor: mediumPurple,
          title: Image.asset(
            'images/Logo.jpg',
            height: 40,
        ),
        centerTitle: true,
      ),
      body: Scrollbar(
        isAlwaysShown: true,
        child: SingleChildScrollView(
          child: Align(
            alignment: Alignment.center,
            child: Column(
              children: <Widget>[
                Text(
                  "My Profile",
                  style: TextStyle(
                      fontSize: 20.0,
                      letterSpacing: 0.42,
                      fontWeight: FontWeight.bold,
                      color: mediumPurple
                  ),
                ),
                SizedBox(height: 50.0,),
                Text(
                  "My Profile",
                  style: TextStyle(
                      fontSize: 20.0,
                      letterSpacing: 0.42,
                      fontWeight: FontWeight.bold,
                      color: mediumPurple
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
