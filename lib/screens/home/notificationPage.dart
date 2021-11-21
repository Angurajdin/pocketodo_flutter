import 'package:calendar_time/calendar_time.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/screens/home/taskList.dart';
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



  Future<void> requestAction(Map<String, dynamic> data, int index, String action) async{

    dynamic currentUserData = await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.email).get();
    dynamic notificationChangeUser = await FirebaseFirestore.instance.collection('users').doc(data['emailid']).get();

    List<dynamic> updatedNotfication = await currentUserData.data()['notifications'];

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
                  data['type']=="request" ? Container(
                  color: lightPurple,
                  child: Row(
                    children: <Widget>[
                      SizedBox(width: 15.0,),
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 7,
                        child: Column(
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
                                    requestAction(data, index, "decline");
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
                                    requestAction(data, index, "accept");
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
                      ),
                      Flexible(
                        flex: 3,
                        fit: FlexFit.tight,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text(
                              "${timeago.format( data['dateTime'].toDate())}",
                              style: TextStyle(fontSize: 13.5),
                            ),
                            SizedBox(height: 5.0,),
                            Text(
                              time.format(
                                  data['dateTime'].toDate()),
                              style:
                              TextStyle(fontSize: 13.5),
                            )
                          ],
                        ),
                      ),
                      SizedBox(width: 5.0,),
                    ],
                  )
              ) :
                  data['type']=="accepted" ? Container(
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 15.0,),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                SizedBox(height: 10.0,),
                                Text(
                                  "${data['userName']} has accepted your request for a task ${data['taskName']}",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 7.0,),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            fit: FlexFit.tight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  "${timeago.format( data['dateTime'].toDate())}",
                                  style: TextStyle(fontSize: 13.5),
                                ),
                                SizedBox(height: 5.0,),
                                Text(
                                  time.format(
                                      data['dateTime'].toDate()),
                                  style:
                                  TextStyle(fontSize: 13.5),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 5.0,),
                        ],
                      )
                  ) :
                  data['type']=="declined" ? Container(
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 15.0,),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                SizedBox(height: 10.0,),
                                Text(
                                  "${data['userName']} has declined your request for a task ${data['taskName']}",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 7.0,),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            fit: FlexFit.tight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  "${timeago.format( data['dateTime'].toDate())}",
                                  style: TextStyle(fontSize: 13.5),
                                ),
                                SizedBox(height: 5.0,),
                                Text(
                                  time.format(
                                      data['dateTime'].toDate()),
                                  style:
                                  TextStyle(fontSize: 13.5),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 5.0,),
                        ],
                      )
                  ) :
                  data['type']=="acceptUser" ? Container(
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 15.0,),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                SizedBox(height: 10.0,),
                                Text(
                                  "You accepted ${data['userName']} for a task ${data['taskName']}",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 7.0,),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            fit: FlexFit.tight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  "${timeago.format( data['dateTime'].toDate())}",
                                  style: TextStyle(fontSize: 13.5),
                                ),
                                SizedBox(height: 5.0,),
                                Text(
                                  time.format(
                                      data['dateTime'].toDate()),
                                  style:
                                  TextStyle(fontSize: 13.5),
                                )
                              ],
                            ),
                          ),
                          SizedBox(width: 5.0,),
                        ],
                      )
                  ) :
                  Container(
                      color: Colors.white,
                      child: Row(
                        children: <Widget>[
                          SizedBox(width: 15.0,),
                          Flexible(
                            fit: FlexFit.tight,
                            flex: 7,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                SizedBox(height: 10.0,),
                                Text(
                                  "You declined ${data['userName']} for a task ${data['taskName']}",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                  ),
                                ),
                                SizedBox(height: 7.0,),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            fit: FlexFit.tight,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Text(
                                  "${timeago.format( data['dateTime'].toDate())}",
                                  style: TextStyle(fontSize: 13.5),
                                ),
                                SizedBox(height: 5.0,),
                                Text(
                                  time.format(
                                      data['dateTime'].toDate()),
                                  style:
                                  TextStyle(fontSize: 13.5),
                                )
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
