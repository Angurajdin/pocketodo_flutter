import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
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

  @override
  _TodoListState createState() => _TodoListState();
}

class _TodoListState extends State<TodoList>{

  var isDialOpen = ValueNotifier<bool>(false);
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

      print(taskDoc.data()['deleted']);

      if(taskDoc.data()['deleted']==true){
        await showAlertMessage(context, "deleted", separatedString[2]);
      }
      else{
        if(taskDoc.data()['permission']=="public" || taskDoc.data()['members'].contains(FirebaseAuth.instance.currentUser!.email)){
          Navigator.of(context).pushNamed('/taskpage', arguments: separatedString[2]);
        }
        else if(taskDoc.data()['requested'].contains(FirebaseAuth.instance.currentUser!.email)){
          await showAlertMessage(context, "AlreadyRequested", separatedString[2]);
        }
        else {
          await showAlertMessage(context, taskDoc.data()['permission'], separatedString[2]);
        }
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

    await FirebaseFirestore.instance.collection('tasks').doc(taskDoc.data()['id']).update({
      "requested": [ FirebaseAuth.instance.currentUser!.email, ...taskDoc.data()['requested']]
    });

  }

  Future<dynamic> showAlertMessage(context, String statusType, String id) async {

    if(statusType=="deleted"){
      return CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        text: "You are trying to access a deleted task.",
        confirmBtnText: 'Okay',
        confirmBtnColor: mediumPurple,
      );
    }

    else if(statusType=="private"){
      return CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        text: "it's private, you don't have permission to view this task.",
        confirmBtnText: 'cancel',
        confirmBtnColor: mediumPurple,
      );
    }

    else if(statusType=="AlreadyRequested"){
      return CoolAlert.show(
        context: context,
        type: CoolAlertType.error,
        text: "It is a private task/n Access denied",
        confirmBtnText: 'Okay',
        confirmBtnColor: mediumPurple,
      );
    }

    else{
      CoolAlert.show(
        context: context,
        type: CoolAlertType.warning,
        text: 'You need the permission to view this task.',
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

    AwesomeNotifications().isNotificationAllowed().then(
          (isAllowed) {
        if (!isAllowed) {
          showDialog(
            context: context,
            builder: (context) =>
                AlertDialog(
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
                      onPressed: () =>
                          AwesomeNotifications()
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
          (receivedNotification) async {
            if (receivedNotification.buttonKeyPressed == 'MARK_DONE') {
              await FirebaseFirestore.instance
                  .collection('tasks')
                  .doc(receivedNotification.payload!['id'])
                  .update({"completed": true});

              await AwesomeNotifications().cancelNotificationsByGroupKey(
                  receivedNotification.payload!['id'] ?? "");
              await AwesomeNotifications().cancelSchedulesByGroupKey(
                  receivedNotification.payload!['id'] ?? "");
            }
            else {
            Navigator.pushNamed(context, '/taskpage',
                arguments: {"id": receivedNotification.payload!['id']});
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
          appBar: AppBar(
            backgroundColor: mediumPurple,
            title: Image.asset(
              'images/Logo.jpg',
              height: 40,
            ),
            centerTitle: true,
            actions: [
              PopupMenuButton(
                  icon: Icon(
                    Icons.filter_alt,
                    color: Colors.white,
                    size: 30,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: TextButton.icon(
                          onPressed: null,
                          icon: Icon(Icons.navigate_before_outlined),
                          label: Text(
                              "Sort by",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.0
                            ),
                          )
                      ),
                      value: 1,
                      onTap: null,
                    ),
                    PopupMenuItem(
                      child: Text("Tags"),
                      value: 2,
                      onTap: null,
                    )
                  ]
              )
            ],
          ),
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
                  child: Icon(
                    Icons.add_task,
                  ),
                  label: "Task",
                  onTap: (){
                    Navigator.pushNamed(context, '/addtask');
                  }
              ),SpeedDialChild(
                  child: Icon(
                    Icons.note_add,
                  ),
                  label: "Note",
                  onTap: (){}
              ),
            ],
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: bottomFloatingNav(currentIndex: 0,),
          body: TaskList(queryString: "home", dataNullMsge: "Wow! No task due soon,\n Create one to schedule, track and collaborate with people.",category: "",),
        ),
      ),
    );
  }

}