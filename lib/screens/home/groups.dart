import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter/material.dart';
import 'bottomFloatingNav.dart';


class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {

  dynamic taskDoc, notificationChangeUser;

  @override
  void initState() {
    initDynamicLinks();
    super.initState();
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
    if (separatedString[1] == "taskpage") {
      taskDoc = await FirebaseFirestore.instance.collection('tasks').doc(separatedString[2]).get();
      if(taskDoc.data()['permission']=="public" || taskDoc.data()['members'].contains(FirebaseAuth.instance.currentUser!.email)){
        Navigator.of(context).pushNamed('/taskpage', arguments: separatedString[2]);
      }
      else {
        await showAlertMessage(context, taskDoc.data()['permission'], separatedString[2]);
      }
    }
  }

  Future<void> sendRequest(String id) async{
    notificationChangeUser = await FirebaseFirestore.instance.collection('users').doc(taskDoc.data()['createdBy']).get();

    await FirebaseFirestore.instance.collection('users').doc(taskDoc.data()['createdBy']).update(
        {
          "notifications": [
            {
              "type": "request",
              "emailid": await FirebaseAuth.instance.currentUser!.email,
              "userName": await FirebaseAuth.instance.currentUser!.displayName,
              "taskId": taskDoc.data()['id'],
              "taskName": taskDoc.data()['title'],
              "dateTime": DateTime.now()
            }, ...notificationChangeUser.data()['notifications']
          ]}
    );

  }

  Future<dynamic> showAlertMessage(context, String permission, String id) async {
    if(permission=="private"){
      return CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        text: "it's private, you don't have permission to view this task",
        confirmBtnText: 'cancel',
        confirmBtnColor: mediumPurple,
      );
    }
    else{
      CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        text: 'You need the permission to view this task',
        confirmBtnText: 'Request',
        onConfirmBtnTap: () async {
          Navigator.of(context, rootNavigator: true).pop();
          showToast('Request has been sent',
              context: context,
              animation: StyledToastAnimation.scale,
              reverseAnimation: StyledToastAnimation.fade,
              position: StyledToastPosition.top,
              animDuration: Duration(seconds: 1),
              duration: Duration(seconds: 4),
              curve: Curves.elasticOut,
              reverseCurve: Curves.linear);
          sendRequest(id);
        },
        confirmBtnColor: mediumPurple,
        cancelBtnText: 'Cancel',
        cancelBtnTextStyle: TextStyle(color: Colors.grey[700]),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context)=> Scaffold(
        appBar: AppBar(
          backgroundColor: mediumPurple,
          title: Image.asset(
            'images/Logo.jpg',
            height: 40,
          ),
          centerTitle: true,
          actions: <IconButton>[
            IconButton(
                onPressed: (){
                  PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          child: Text("First"),
                          value: 1,
                        ),
                        PopupMenuItem(
                          child: Text("Second"),
                          value: 2,
                        )
                      ]
                  );
                },
                icon: Icon(
                  Icons.filter_alt,
                  color: Colors.white,
                  size: 30,
                )
            )
          ],
        ),
        drawer: DrawerPage(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/addtask');
          },
          backgroundColor: Color(0xFF9088D3),
          elevation: 0.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
              side: BorderSide(
                  color: Colors.white,
                  width: 4.0
              )
          ),
          child: Icon(Icons.add),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: bottomFloatingNav(currentIndex: 2,),
        body: Text("Groups"),
      ),
    );
  }
}
