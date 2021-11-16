import 'package:pocketodo/shared/constants.dart';
import 'package:pocketodo/shared/loading.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:calendar_time/calendar_time.dart';

class TaskList extends StatefulWidget {
  String queryString, dataNullMsge, category;

  TaskList({required this.queryString,
    required this.dataNullMsge,
    required this.category});

  @override
  _TaskListState createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
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
  String showDateConversation = "";
  late Stream<QuerySnapshot> queryCondition;
  int categoryCount = 0;

  @override
  void initState() {
    if (widget.queryString == "completed") {
      queryCondition = FirebaseFirestore.instance
          .collection('tasks')
          .where('members',
          arrayContainsAny: [FirebaseAuth.instance.currentUser!.email])
          .where("completed", isEqualTo: true)
          .where("deleted", isEqualTo: false)
          .orderBy('datetime', descending: true)
          .snapshots();
    }
    else if (widget.queryString == "today") {
      queryCondition = FirebaseFirestore.instance
          .collection('tasks')
          .where('members',
          arrayContainsAny: [FirebaseAuth.instance.currentUser!.email])
      //.where('date', isEqualTo: dateMonthYear.format(DateTime.now()))
          .where("deleted", isEqualTo: false)
          .orderBy('datetime', descending: true)
          .snapshots();
    }
    else {
      queryCondition = FirebaseFirestore.instance
          .collection('tasks')
          .where('members',
          arrayContainsAny: [FirebaseAuth.instance.currentUser!.email])
          .where('datetime', isGreaterThan: DateTime.now())
          .where("deleted", isEqualTo: false)
          .orderBy('datetime')
          .snapshots();
    }

    if (widget.queryString == "category") {
      categoryCount = 0;
    }

    super.initState();
  }


  List<Widget> returnTags(var taskItem) {
    List<Widget> childs = [];
    if (taskItem.length > 1) {
      childs.add(new Container(
        decoration: BoxDecoration(
          color: mediumPurple,
          borderRadius:
          BorderRadius.all(
              Radius.circular(
                  6.0)),
        ),
        padding:
        EdgeInsets.fromLTRB(5.0,
            5.0, 10.0, 5.0),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.loyalty_rounded,
              color: Colors.white,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text(
              taskItem[0],
              style: TextStyle(
                color: Colors.white,
              ),
            )
          ],
        ),
      ));

      childs.add(new Container(
        decoration: BoxDecoration(
          color: mediumPurple,
          borderRadius:
          BorderRadius.all(
              Radius.circular(
                  15.0)),
        ),
        padding:
        EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 2.0,
            ),
            Text(
              "+ " + (taskItem.length - 1).toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold
              ),
            ),
            SizedBox(
              width: 2.0,
            ),
          ],
        ),
      ));
      return childs;
    }
    for (var i = 0; i < taskItem.length; i++) {
      childs.add(new Container(
        decoration: BoxDecoration(
          color: mediumPurple,
          borderRadius:
          BorderRadius.all(
              Radius.circular(
                  6.0)),
        ),
        padding:
        EdgeInsets.fromLTRB(5.0,
            5.0, 10.0, 5.0),
        child: Row(
          mainAxisSize:
          MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.loyalty_rounded,
              color: Colors.white,
            ),
            SizedBox(
              width: 5.0,
            ),
            Text(
              taskItem[i],
              style: TextStyle(
                  color:
                  Colors.white),
            )
          ],
        ),
      ));
    }
    return childs;
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: queryCondition,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Something went wrong, pls close and open the app again...",
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
                widget.dataNullMsge,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0),
              ),
            );
          }

          // snapshot.data!.docs.map((DocumentSnapshot document) {
          //   Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          //     // if(widget.queryString=="category"){
          //     //   Map<String, dynamic> dataFilter;
          //     //   data.forEach((k,v) {
          //     //
          //     //   });
          //     // }
          // });

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> data =
              snapshot.data!.docs[index].data() as Map<String, dynamic>;
              if (widget.queryString == "category") {
                if (data['tags'].contains(widget.category)) {
                  categoryCount += 1;
                  return Column(
                    children: <Widget>[
                      Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/taskpage',
                                arguments: data);
                          },
                          child: Container(
                            padding:
                            EdgeInsets.fromLTRB(10.0, 10.0, 18.0, 25.0),
                            child: InkWell(
                                splashColor: lightPurple,
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      child: Container(),
                                      fit: FlexFit.tight,
                                    ),
                                    Flexible(
                                      flex: 8,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            data['title'],
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                letterSpacing: 0.7,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          // Text((() {
                                          //   if(data['description'].length>10){
                                          //     return "${data['description'].substring(0, 10)}...";
                                          //   }
                                          //   return "${data['description']}...";
                                          // })()),
                                          Wrap(
                                              spacing: 10.0,
                                              // gap between adjacent chips
                                              runSpacing: 5.0,
                                              // gap between lines
                                              children: List<Widget>.generate(
                                                  data['tags'].length,
                                                      (i) =>
                                                  new Container(
                                                    decoration:
                                                    BoxDecoration(
                                                      color: mediumPurple,
                                                      borderRadius:
                                                      BorderRadius.all(
                                                          Radius
                                                              .circular(
                                                              6.0)),
                                                    ),
                                                    padding:
                                                    EdgeInsets.fromLTRB(
                                                        5.0,
                                                        5.0,
                                                        10.0,
                                                        5.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                      MainAxisSize.min,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons
                                                              .loyalty_rounded,
                                                          color:
                                                          Colors.white,
                                                        ),
                                                        SizedBox(
                                                          width: 5.0,
                                                        ),
                                                        Text(
                                                          data['tags'][i],
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .white),
                                                        )
                                                      ],
                                                    ),
                                                  ))),
                                        ],
                                      ),
                                      fit: FlexFit.tight,
                                    ),
                                    Flexible(
                                      flex: 4,
                                      child: Column(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Icon(
                                                Icons.today,
                                              ),
                                              Text(
                                                CalendarTime(data['datetime']
                                                    .toDate())
                                                    .isToday
                                                    ? "Today"
                                                    : CalendarTime(
                                                    data['datetime']
                                                        .toDate())
                                                    .isTomorrow
                                                    ? "Tomorrow"
                                                    : CalendarTime(data[
                                                'datetime']
                                                    .toDate())
                                                    .isYesterday
                                                    ? "Yesterday"
                                                    : "${dateMonthYear.format(
                                                    data['datetime']
                                                        .toDate())}",
                                                style:
                                                TextStyle(fontSize: 14.0),
                                              )
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Icon(Icons.access_alarms_rounded),
                                              Text(
                                                time.format(
                                                    data['datetime'].toDate()),
                                                style:
                                                TextStyle(fontSize: 14.0),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                      fit: FlexFit.tight,
                                    ),
                                  ],
                                )),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.all(Radius.circular(15.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 5,
                                  offset: Offset(
                                      0, 5), // changes position of shadow
                                ),
                              ],
                            ),
                          ),
                        ),
                        actions: <Widget>[
                          IconSlideAction(
                            caption: 'Archive',
                            color: Colors.blue,
                            icon: Icons.archive,
                            onTap: () => print('Archive'),
                          ),
                          IconSlideAction(
                            caption: 'Share',
                            color: Colors.indigo,
                            icon: Icons.share,
                            onTap: () => print('Share'),
                          ),
                        ],
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () async {
                              await AwesomeNotifications().cancel(
                                  data['notificationId']);

                              await FirebaseFirestore.instance
                                  .collection('tasks').doc(
                                  snapshot.data!.docs[index].id).update(
                                  {"deleted": true});
                            },
                          ),
                          IconSlideAction(
                            caption: 'Close',
                            color: Colors.black45,
                            icon: Icons.close,
                            onTap: () => null,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15.0,
                      ),
                    ],
                  );
                } else {
                  if (snapshot.data!.docs.length - 1 == index) {
                    if (categoryCount == 0) {
                      return Center(
                        child: Text("You have tasks in this category"),
                      );
                    }
                  }
                  return Container();
                }
              }
              return Column(
                  children: <Widget>[
              Slidable(
              child: GestureDetector(
                  onTap: ()
              {
                Navigator.pushNamed(context, '/taskpage',
                    arguments: data);
              },
              child: Container(
              padding: EdgeInsets.fromLTRB(10.0, 10.0, 18.0, 25.0),
              child: InkWell(
              splashColor: lightPurple,
              child: Row(
              children: <Widget>[
              Flexible(
              flex: 1,
              child: Container(),
              fit: FlexFit.tight,
              ),
              Flexible(
              flex: 8,
              child: Column(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: <Widget>[
              Text(
              data['title'],
              style: TextStyle(
              fontSize: 18.0,
              letterSpacing: 0.7,
              fontWeight: FontWeight.w600),
              ),
              SizedBox(
              height: 10.0,
              ),
              // Text((() {
              //   if(data['description'].length>10){
              //     return "${data['description'].substring(0, 10)}...";
              //   }
              //   return "${data['description']}...";
              // })()),
              Wrap(
              spacing: 10.0,
              // gap between adjacent chips
              runSpacing: 5.0,
              // gap between lines
              children: returnTags(data['tags']),
              ),
              ],
              ),
              fit: FlexFit.tight,
              ),
              Flexible(
              flex: 4,
              child: Column(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: <Widget>[
              Row(
              children: <Widget>[
              Icon(
              Icons.today,
              ),
              Text(
              CalendarTime(data['datetime']
                  .toDate())
                  .isToday
              ? "Today"
                  : CalendarTime(data['datetime']
                  .toDate())
                  .isTomorrow
              ? "Tomorrow"
                  : CalendarTime(
              data['datetime']
                  .toDate())
                  .isYesterday
              ? "Yesterday"
                  : "${dateMonthYear.format(
              data['datetime'].toDate())}",
              style: TextStyle(fontSize: 14.0),
              )
              ],
              ),
              Row(
              children: <Widget>[
              Icon(Icons.access_alarms_rounded),
              Text(
              time.format(
              data['datetime'].toDate()),
              style: TextStyle(fontSize: 14.0),
              )
              ],
              ),
              ],
              ),
              fit: FlexFit.tight,
              ),
              ],
              )),
              decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              boxShadow: [
              BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 3,
              blurRadius: 6,
              offset:
              Offset(2, 3), // changes position of shadow
              ),
              ],
              ),
              ),
              ),
              actionPane: SlidableDrawerActionPane(),
              actions: <Widget>[
              IconSlideAction(
              caption: 'Archive wo',
              color: Colors.blue,
              icon: Icons.archive,
              onTap: () => print('Archive'),
              ),
              IconSlideAction(
              caption: 'Share',
              color: Colors.indigo,
              icon: Icons.share,
              onTap: () => print('Share'),
              ),
              ],
              secondaryActions: <Widget>[
              IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () async{
              // print(" current doc id = ${snapshot.data!.docs[index].id}");

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete'),
                  content: Text('Are you sure, want to delete it'),
                  actions: [
                  TextButton(
                  onPressed: () {
                  Navigator.pop(context);
                  },
                  child: Text(
                  'No',
                  style: TextStyle(color: mediumPurple, fontSize: 18),
                  ),
                  ),
                  TextButton(
                  onPressed: () async{
                    await AwesomeNotifications().cancelNotificationsByGroupKey(data['notificationId']);
                    await AwesomeNotifications().cancelSchedulesByGroupKey(data['notificationId']);

                    await FirebaseFirestore.instance
                        .collection('tasks').doc(snapshot.data!.docs[index].id).update({"deleted": true})
                        .then((_) => Navigator.pop(context));
                  },
                  child: Text(
                    'Yes',
                    style: TextStyle(
                      color: Colors.red[300],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                  ],
                ),
              );
              }
          )
          ,
          IconSlideAction(
          caption: 'Close',
          color: Colors.black45,
          icon: Icons.close,
          onTap: () => null,
          ),
          ],
          ),
          SizedBox(
          height: 15.0,
          ),
          ]
          ,
          );
        });
  }

  ,

  );
}}
