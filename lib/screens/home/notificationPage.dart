import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter/material.dart';
import 'package:pocketodo/shared/loading.dart';
import 'bottomFloatingNav.dart';
import 'package:timeago/timeago.dart' as timeago;


class NotificationPage extends StatelessWidget {
  const NotificationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Builder(
        builder: (context) => Scaffold(
          appBar: AppBar(
            backgroundColor: mediumPurple,
            title: Text(
              "Notifications",
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.w600
              ),
            ),
            centerTitle: true,
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
          bottomNavigationBar: bottomFloatingNav(currentIndex: 3,),
          body: NotificationPageData(),
        ),
    );
  }
}


class NotificationPageData extends StatefulWidget {
  const NotificationPageData({Key? key}) : super(key: key);

  @override
  _NotificationPageDataState createState() => _NotificationPageDataState();
}

class _NotificationPageDataState extends State<NotificationPageData>{

  final DateFormat time = DateFormat('jm');
  Stream documentStream = FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email).snapshots();
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


  Future<void> requestAction(Map<String, dynamic> data, int index, String action, List updatedNotfication) async{

    dynamic notificationChangeUser = await FirebaseFirestore.instance.collection('users').doc(data['emailid']).get();
    dynamic taskData = await FirebaseFirestore.instance.collection('tasks').doc(data['taskId']).get();

    if(action=="accept"){
      updatedNotfication[index] =
        {
          "type": "acceptUser",
          "emailid": data['emailid'],
          "userName": data['userName'],
          "taskId": data['taskId'],
          "taskName": data['taskName'],
          "dateTime": DateTime.now()
        };
    }
    else{
      updatedNotfication[index] =
        {
          "type": "declineUser",
          "emailid": data['emailid'],
          "userName": data['userName'],
          "taskId": data['taskId'],
          "taskName": data['taskName'],
          "dateTime": DateTime.now()
        };
    }

    await FirebaseFirestore.instance.collection('users').doc(await FirebaseAuth.instance.currentUser!.email).update({
      "notifications": [...updatedNotfication]
    });

    if(action=="accept"){
      await FirebaseFirestore.instance.collection('users').doc(data['emailid']).update(
          {
            "notifications": [
              {
                "type": "accepted",
                "emailid": await FirebaseAuth.instance.currentUser!.email,
                "userName": await FirebaseAuth.instance.currentUser!.displayName,
                "taskId": data['taskId'],
                "taskName": data['taskName'],
                "dateTime": DateTime.now()
              }, ...notificationChangeUser.data()['notifications']
            ]}
      );

      await FirebaseFirestore.instance.collection('users').doc(data['emailid']).update({
        "members": [ data['emailid'], ...taskData.data()['members']]
      });

    }
    else{
      await FirebaseFirestore.instance.collection('users').doc(data['emailid']).update(
          {
            "notifications": [
              {
                "type": "declined",
                "emailid": await FirebaseAuth.instance.currentUser!.email,
                "userName": await FirebaseAuth.instance.currentUser!.displayName,
                "taskId": data['taskId'],
                "taskName": data['taskName'],
                "dateTime": DateTime.now()
              }, ...notificationChangeUser.data()['notifications']
            ]}
      );
    }

  }


  @override
  Widget build(BuildContext context) {

    return StreamBuilder(
        stream: documentStream,
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Something went wrong, please close and open the app again...",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Loading();
          }

          if (snapshot.hasData && snapshot.data.data()['notifications'].length == 0) {
            return Center(
              child: Text(
                "You have no Notification",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data.data()['notifications'].length,
            itemBuilder: (context, index){
              Map<String, dynamic> data = snapshot.data.data()['notifications'][index] as Map<String, dynamic>;
              return Column(
                children: <Widget>[
                  data['type']=="request" ?
                    Container(
                    color: lightPurple,
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 15.0,),
                            Flexible(
                                flex: 2,
                                fit: FlexFit.tight,
                                child: Image.asset(
                                    'images/glogo.jpg'
                                )
                            ),
                            Flexible(
                              fit: FlexFit.tight,
                              flex: 8,
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Text(
                                        "${timeago.format( data['dateTime'].toDate())}",
                                        style: TextStyle(fontSize: 13.5),
                                      ),
                                      Text(
                                        time.format(
                                            data['dateTime'].toDate()),
                                        style:
                                        TextStyle(fontSize: 13.5),
                                      )
                                    ],
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      SizedBox(height: 10.0,),
                                      Text(
                                        "${data['userName']} has requested for a task ${data['taskName']}",
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                      SizedBox(height: 3.0,),
                                      Row(
                                        children: <Widget>[
                                          SizedBox(width: 20.0,),
                                          TextButton(
                                            onPressed: (){
                                              requestAction(data, index, "decline", snapshot.data.data()['notifications']);
                                            },
                                            child: Text(
                                              "Decline",
                                              style: TextStyle(
                                                  color: mediumPurple
                                              ),
                                            ),
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10.0),
                                                    side: BorderSide(
                                                      color: mediumPurple,
                                                    )
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 20.0,),
                                          ElevatedButton(
                                            onPressed: (){
                                              print(snapshot.data.data());
                                              requestAction(data, index, "accept", snapshot.data.data()['notifications']);
                                            },
                                            child: Text(
                                              "Accept",
                                              style: TextStyle(
                                                  color: Colors.white
                                              ),
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(
                                                  mediumPurple
                                              ),
                                              shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 7.0,),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5.0,),
                          ],
                        )
                    ) :
                    Container(
                      color: lightPurple,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 15.0,),
                          Flexible(
                              flex: 3,
                              fit: FlexFit.tight,
                              child: Image.asset('images/Pocketodo_logo.jpg')
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 7,
                            child: Column(
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    Text(
                                      "${timeago.format( data['dateTime'].toDate())}",
                                      style: TextStyle(fontSize: 13.5),
                                    ),
                                    Text(
                                      time.format(
                                          data['dateTime'].toDate()),
                                      style:
                                      TextStyle(fontSize: 13.5),
                                    )
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    SizedBox(height: 10.0,),
                                    Text(
                                      data['type']=="accepted" ?
                                      "${data['userName']} has accepted your request for a task ${data['taskName']}" :
                                      data['type']=="declined" ?
                                      "${data['userName']} has declined your request for a task ${data['taskName']}" :
                                      data['type']=="acceptUser" ?
                                      "You accepted ${data['userName']} for a task ${data['taskName']}" :
                                      "You declined ${data['userName']} for a task ${data['taskName']}",

                                      style: TextStyle(
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    SizedBox(height: 10.0,),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 5.0,),
                        ],
                      )
                  ),
                  Divider(height: 0.0,thickness: 2.5,),
                ],
              );
            },
          );
        }
    );

  }
}
