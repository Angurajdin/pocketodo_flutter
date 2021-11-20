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
            title: Image.asset(
              'assets/Logo.jpg',
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

class _NotificationPageDataState extends State<NotificationPageData> {

  final yesterday = DateTime(
      DateTime
          .now()
          .year, DateTime
      .now()
      .month, DateTime
      .now()
      .day - 1);
  final tomorrow = DateTime(
      DateTime
          .now()
          .year, DateTime
      .now()
      .month, DateTime
      .now()
      .day + 1);
  final DateFormat dateMonthYear = DateFormat('yyyy-MM-dd');
  final DateFormat time = DateFormat('jm');
  late Map<String, dynamic> data;
  List<Widget> childs = [];
  Stream<QuerySnapshot> queryCondition = FirebaseFirestore.instance
      .collection('tasks')
      .where("createdBy", isEqualTo: FirebaseAuth.instance.currentUser!.email)
      .where("deleted", isEqualTo: false)
      .orderBy('datetime', descending: true)
      .snapshots();

  @override
  Widget build(BuildContext context) {

    return StreamBuilder<QuerySnapshot>(
        stream: queryCondition,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
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

          if (snapshot.hasData && snapshot.data!.docs.length == 0) {
            return Center(
              child: Text(
                "You have no Notification",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0),
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index){
              data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
              childs = [];
              for(var i in data['requested']){
                childs.add(new Container(
                  decoration: BoxDecoration(
                    color: lightPurple
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    children: <Widget>[
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 7,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Text("${i['emailid']} has requested for a task ${data['title']}"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                TextButton(
                                  onPressed: (){},
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
                                  onPressed: (){},
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
                            )
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
                              CalendarTime(i['requestedDateTime'].toDate()).isTomorrow
                                  ? "Tomorrow" :
                              "${timeago.format( i['requestedDateTime'].toDate())}",
                              style: TextStyle(fontSize: 14.0),
                            ),
                            Text(
                              time.format(
                                  i['requestedDateTime'].toDate()),
                              style:
                              TextStyle(fontSize: 14.0),
                            )
                          ],
                        ),
                      ),
                    ],
                  )
                ));
                childs.add(new SizedBox(height: 20.0,));
              }

              return Column(
                children: childs
              );
            },
          );
        }
    );



  }
}
