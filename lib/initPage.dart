import 'package:pocketodo/screens/Authentication/login.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class initPage extends StatelessWidget {
  const initPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => Login(),
      },
      home: Scaffold(
      backgroundColor: const Color(0xFF9088D3),
      body: Builder(
        builder: (context)=> Center(
          child: Column(
            children: <Widget>[
              Spacer(flex: 3,),
              Image.asset(
                'assets/Logo.jpg',
                height: 50.0,
                width: 400.0,
              ),
              Spacer(),
              Text(
                'Hi welcome !',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 20,
                  color: const Color(0xfffdfdfd),
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.left,
              ),
              Spacer(),
              Text(
                'Explore the app and make to do\nwith Pocketodo',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 20,
                  color: const Color(0xfffdfdfd),
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.center,
              ),
              Spacer(),
              Image.asset(
                "assets/welcome.jpg",
                height: 300.0,
                width: 300.0,
              ),
              Spacer(),
              Text(
                'Don\'t miss your tasks',
                style: TextStyle(
                  fontFamily: 'Rubik',
                  fontSize: 20,
                  color: const Color(0xfffdfdfd),
                  fontWeight: FontWeight.w300,
                ),
                textAlign: TextAlign.left,
              ),
              Spacer(),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 12),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),),),
                child: Text(
                  'GET STARTED',
                  style: TextStyle(
                    fontSize: 24,
                    color: mediumPurple,
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
              Spacer(flex: 2,),
            ],
          ),
        ),
      )
    ),
    );
  }
}
