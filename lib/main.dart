import 'dart:async';
import 'package:pocketodo/screens/Authentication/login.dart';
import 'package:pocketodo/screens/home/CategoryPage.dart';
import 'package:pocketodo/screens/home/addtask.dart';
import 'package:pocketodo/screens/home/categoryTask.dart';
import 'package:pocketodo/screens/home/completedTask.dart';
import 'package:pocketodo/screens/home/groups.dart';
import 'package:pocketodo/screens/home/notificationPage.dart';
import 'package:pocketodo/screens/home/home.dart';
import 'package:pocketodo/screens/home/taskPage.dart';
import 'package:pocketodo/screens/home/todayTask.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:pocketodo/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import './screens/Authentication/login.dart';
import './screens/Authentication/signup.dart';
import 'initPage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  AwesomeNotifications().initialize(
    null,
      [
        NotificationChannel(
          channelKey: 'pocketodo',
          channelName: 'Pocketodo Application',
          channelDescription: 'Notification for Pocketodo Application',
          defaultColor: mediumPurple,
          ledColor: Colors.white,
          playSound: true,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        )
      ]
  );

  runApp(Wrapper());

}

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (BuildContext context, snapshot) {
        if (snapshot.hasError) {
          return Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        // print("data =    ${snapshot.data}");
        // print("data =    ${snapshot.hasData}");

        if(snapshot.hasData==false || snapshot.data==null){
          return initPage();
        }
        else{

          return new Builder(builder: (context) {

            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: ThemeData(fontFamily: 'rubik'),
              home: TodoList(),
              routes: {
                '/initpage': (context) => initPage(),
                '/signup': (context) => Signup(),
                '/login': (context) => Login(),
                '/loading': (context) => Loading(),
                '/todolist': (context) => TodoList(),
                '/addtask': (context) => AddTask(),
                '/category': (context) => CategoryPage(),
                '/notification': (context) => NotificationPage(),
                '/today': (context) => TodayTask(),
                '/completed': (context) => CompletedTask(),
                '/categorytask': (context) => CategoryTask(),
                '/taskpage': (context) => TaskPage(),
                '/groups': (context) => Groups(),
              },
            );
          });
        }
      },
    );
  }
}
