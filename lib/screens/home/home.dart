import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:pocketodo/screens/home/bottomFloatingNav.dart';
import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/screens/home/taskList.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:awesome_notifications/awesome_notifications.dart';


class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {

  var isDialOpen = ValueNotifier<bool>(false);

  @override
  void initState() {
    // initDynamicLinks();
    super.initState();
  }

  @override
  void dispose() {
    isDialOpen.dispose();
    super.dispose();
  }

  Future<void> initDynamicLinks() async {
    final PendingDynamicLinkData? data =
    await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      handleDynamicLink(deepLink);
    }
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
          final Uri? deepLink = dynamicLink?.link;

          if (deepLink != null) {
            handleDynamicLink(deepLink);
          }
        }, onError: (OnLinkErrorException e) async {
      print(e.message);
    });
  }

  Future<void> handleDynamicLink(Uri url) async{
    List<String> separatedString = [];
    separatedString.addAll(url.path.split('/'));
    print(" data =  $separatedString");
    if (separatedString[1] == "task") {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(separatedString[2])
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          // print('Document exists on the database');
          Navigator.pushNamed(context, '/taskpage',
              arguments: documentSnapshot.data());
        }
        else{
          print('Document not exists on the database');
        }
      });

    }
  }


  @override
  Widget build(BuildContext context) {

    AwesomeNotifications().isNotificationAllowed().then(
          (isAllowed) {
        if (!isAllowed) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Allow Notifications'),
              content: Text('Our app would like to send you notifications'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Don\'t Allow',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () => AwesomeNotifications()
                      .requestPermissionToSendNotifications()
                      .then((_) => Navigator.pop(context)),
                  child: Text(
                    'Allow',
                    style: TextStyle(
                      color: Colors.teal,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );


    AwesomeNotifications().actionStream.listen(
            (receivedNotification) async{

              if(receivedNotification.buttonKeyPressed == 'MARK_DONE'){
                await FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(receivedNotification.payload!['id'])
                    .update({"completed": true});

                await AwesomeNotifications().cancelNotificationsByGroupKey(receivedNotification.payload!['id'] ?? "");
                await AwesomeNotifications().cancelSchedulesByGroupKey(receivedNotification.payload!['id'] ?? "");

              }
              else{
                await FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(receivedNotification.payload!['id'])
                    .get()
                    .then((DocumentSnapshot documentSnapshot) {
                  if (documentSnapshot.exists) {
                    // print('Document exists on the database');
                    Navigator.pushNamed(context, '/taskpage',
                        arguments: documentSnapshot.data());
                  }
                  else{
                    print('Document not exists on the database');
                  }
                });
              }
        }
    );


    return Builder(
      builder: (context)=> WillPopScope(
        onWillPop: () async {
          if (isDialOpen.value) {
            isDialOpen.value = false;
            return false;
          }
          return true;
        },
        child: Scaffold(
          appBar: appBarLogo,
          drawer: DrawerPage(),
          floatingActionButton: SpeedDial(
            icon: Icons.add,
            activeIcon: Icons.close,
            backgroundColor: mediumPurple,
            elevation: 0.0,
            spacing: 7.0,
            spaceBetweenChildren: 7.0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
                side: BorderSide(
                    color: Colors.white,
                    width: 2.0
                )
            ),
            children: <SpeedDialChild>[
              SpeedDialChild(
                  child: Icon(Icons.mail),
                  label: "Task",
                  onTap: (){
                    Navigator.pushNamed(context, '/addtask');
                  }
              ),SpeedDialChild(
                  child: Icon(Icons.copy),
                  label: "Note",
                  onTap: (){}
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: bottomFloatingNav(currentIndex: 0,),
          body: TaskList(queryString: "home", dataNullMsge: "No todo has created till now, Create new one by pressing the below + button",category: "",),
        ),
      )
    );
  }
}