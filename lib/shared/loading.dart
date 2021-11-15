import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'rubik'),
      home: Scaffold(
        backgroundColor: Color(0xFFE7E6F4),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SpinKitFoldingCube(
                color: Color(0xFF9088D3),
                size: 50.0,
              ),
              SizedBox(height: 50.0,),
              Text(
                "Just a moment...",
                style: TextStyle(
                    color: Color(0xFF706897),
                    fontSize: 35.0,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 1.0
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}