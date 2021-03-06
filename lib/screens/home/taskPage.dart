import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/services.dart';
import 'package:pocketodo/shared/loading.dart';


class TaskPage extends StatefulWidget {

  String id;

  TaskPage({
      required this.id
  });

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {

  final DateFormat time = DateFormat('jm');
  late Stream<DocumentSnapshot> documentStream;
  String? id = null;
  dynamic data;

  @override
  Widget build(BuildContext context) {

    documentStream = FirebaseFirestore.instance.collection('tasks').doc(widget.id).snapshots();

    return StreamBuilder<DocumentSnapshot>(
      stream: documentStream,
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Something went wrong, please close and open the app again...",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
          );
        }

        else if (snapshot.connectionState == ConnectionState.waiting) {
          return Loading();
        }

        else if (snapshot.hasData && snapshot.data!.data()==null) {
          return Center(
            child: Text(
              "Maybe this Document was deleted, Please connect the owner of this document",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20.0),
            ),
          );
        }

        else{
          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;

          return Scaffold(
            backgroundColor: lightPurple,
            // resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Scrollbar(
                isAlwaysShown: true,
                child: SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, MediaQuery.of(context).viewInsets.bottom),
                    child: SingleChildScrollView(
                      reverse: true,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Container(),
                              Text(
                                "       "+data['title'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontSize: 20.0,
                                    letterSpacing: 0.42,
                                    fontWeight: FontWeight.w900,
                                    color: mediumPurple
                                ),
                              ),
                              IconButton(
                                  onPressed: (){
                                    Navigator.pushNamed(context, '/edittask', arguments: data);
                                  },
                                  icon: Icon(Icons.edit, size: 27.0,)
                              ),
                            ],
                          ),
                          Divider(height: 0.0, thickness: 1.0, color: mediumPurple,),
                          data['description'] != "" ?
                          Column(
                            children: <Widget>[
                              SizedBox(height: 20.0,),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                child: Row(
                                  children: <Widget>[
                                    Flexible(
                                      flex: 1,
                                      fit: FlexFit.tight,
                                      child: Icon(Icons.description_outlined),
                                    ),
                                    SizedBox(width: 5.0,),
                                    Flexible(
                                      flex: 6,
                                      fit: FlexFit.tight,
                                      child: Text(
                                        data['description'],
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          letterSpacing: 0.42,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5.0,),
                                    Flexible(
                                      child: CircularPercentIndicator(
                                        radius: 33.0,
                                        lineWidth: 3.3,
                                        animation: true,
                                        percent: data['priority']/10,
                                        center: new Text(
                                          data['priority'].toInt().toString(),
                                          style:
                                          new TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14.0
                                          ),
                                        ),
                                        circularStrokeCap: CircularStrokeCap.round,
                                        progressColor: mediumPurple,
                                        backgroundColor: lightPurple,
                                      ),
                                      flex: 1,
                                      fit: FlexFit.tight,
                                    )
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ) : Container(),
                          SizedBox(height: 20.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Icon(Icons.today),
                                      Text(
                                        data['date'].toString(),
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 6,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.0,),
                              Flexible(
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(width: 5.0,),
                                      Icon(Icons.alarm),
                                      SizedBox(width: 10.0,),
                                      Text(
                                        time.format(data['datetime'].toDate()),
                                        style: TextStyle(
                                          fontSize: 18.0,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 2,
                                        blurRadius: 6,
                                        offset: Offset(0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          data['link'] != "" ?
                          Column(
                            children: <Widget>[
                              SizedBox(height: 20.0,),
                              Container(
                                padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
                                child: Row(
                                  children: <Widget>[
                                    SizedBox(width: 5.0,),
                                    Icon(Icons.link),
                                    SizedBox(width: 10.0,),
                                    Text(
                                      data['link'],
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        letterSpacing: 0.42,
                                      ),
                                    ),
                                  ],
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 6,
                                      offset: Offset(0, 3), // changes position of shadow
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ) : Container(),
                          SizedBox(height: 20.0,),
                          Text(
                            "Access Permission",
                            style: TextStyle(
                                fontSize: 20.0,
                                letterSpacing: 0.42,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                          SizedBox(height: 12.0,),
                          Row(
                            children: <Widget>[
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 5,
                                child: Container(
                                  height: 100.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.person, size: 25.0,
                                        color: data['permission']=='private' ? Colors.white : Colors.black,
                                      ),
                                      Text(
                                        "Only me",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: data['permission']=='private' ? Colors.white : Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: data['permission']=='private' ? FontWeight.w600 : FontWeight.normal,
                                          letterSpacing: 0.42,
                                        ),
                                      ),
                                    ],
                                  ),
                                  decoration:
                                    data['permission']=='private' ?
                                      BoxDecoration(
                                          color: mediumPurple,
                                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.6),
                                            width: 4.0,
                                          )
                                      ) :
                                        BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                ),
                              ),
                              Flexible(child: Container(), flex: 1,),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 5,
                                child: Container(
                                  height: 100.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.link, size: 26.0,
                                        color: data['permission']=='public' ? Colors.white : Colors.black,
                                      ),
                                      SizedBox(height: 6.5,),
                                      Text(
                                        "Anyone with link",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: data['permission']=='public' ? Colors.white : Colors.black,
                                          fontSize: 15.0,
                                          fontWeight: data['permission']=='public' ? FontWeight.w600 : FontWeight.normal,
                                          letterSpacing: 0.42,
                                        ),
                                      ),
                                    ],
                                  ),
                                  decoration:
                                    data['permission']=='public' ?
                                      BoxDecoration(
                              color: mediumPurple,
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.6),
                                width: 4.0,
                              )
                          ) :
                                        BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                              ),
                                ),
                              ),
                              Flexible(child: Container(), flex: 1,),
                              Flexible(
                                fit: FlexFit.tight,
                                flex: 5,
                                child: Container(
                                  height: 100.0,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.lock, size: 23.0,
                                        color: data['permission']=='protected' ? Colors.white : Colors.black,
                                      ),
                                      SizedBox(height: 5.0,),
                                      Text(
                                        "Access  required",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: data['permission']=='protected' ? FontWeight.w600 : FontWeight.normal,
                                          color: data['permission']=='protected' ? Colors.white : Colors.black,
                                          fontSize: 15.0,
                                          letterSpacing: 0.42,
                                        ),
                                      ),
                                    ],
                                  ),
                                  decoration:
                                    data['permission']=='protected' ?
                                      BoxDecoration(
                                        color: mediumPurple,
                                        borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.6),
                                          width: 4.0,
                                        )
                                    ) :
                                        BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          data['permission']=='public' || data['permission']=='protected' ?
                              Column(
                                children: <Widget>[
                                  SizedBox(height: 15.0,),
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 7.0),
                                    child: Row(
                                      children: <Widget>[
                                        SizedBox(width: 10.0,),
                                        Expanded(
                                          child: Text(
                                            data['taskLink'],
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              letterSpacing: 0.42,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: (){
                                            Clipboard.setData(ClipboardData(text: data['taskLink']));
                                            showToast('Link Copied',
                                                context: context,
                                                animation: StyledToastAnimation.scale,
                                                reverseAnimation: StyledToastAnimation.fade,
                                                position: StyledToastPosition.top,
                                                animDuration: Duration(seconds: 1),
                                                duration: Duration(seconds: 4),
                                                curve: Curves.elasticOut,
                                                reverseCurve: Curves.linear);
                                          },
                                          icon: Icon(Icons.copy),
                                        ),
                                      ],
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 6,
                                          offset: Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ) : Container(),
                          data['tags'].length > 0 ?
                          Column(
                            children: <Widget>[
                              SizedBox(height: 20.0,),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Tags",
                                  textAlign: TextAlign.start,
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      letterSpacing: 0.42,
                                      fontWeight: FontWeight.bold
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.0,),
                              Wrap(
                                  spacing: 15.0, // gap between adjacent chips
                                  runSpacing: 15.0, // gap between lines
                                  children:
                                  List<Widget>.generate(
                                    data['tags'].length, (i) =>
                                      Container(
                                        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                                        child: Text(
                                          data['tags'][i],
                                          style: TextStyle(
                                              fontSize: 15.0
                                          ),
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.2),
                                              spreadRadius: 2,
                                              blurRadius: 6,
                                              offset: Offset(0, 3), // changes position of shadow
                                            ),
                                          ],
                                        ),
                                      ),
                                  )
                              ),
                            ],
                          ) : Container(),
                          SizedBox(height: 30.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Expanded(
                                flex: 4,
                                child: ElevatedButton(
                                  onPressed: (){
                                    Navigator.pop(context);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    elevation: 0,
                                    padding: EdgeInsets.symmetric(vertical: 15.0),
                                    backgroundColor: Colors.white60,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      side: BorderSide(
                                          color: mediumPurple,
                                          width: 1
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    "Cancel",
                                    style: TextStyle(
                                        color: textColorDarkPurple,
                                        letterSpacing: 0.1,
                                        fontSize: 20.0
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 20.0,),
                              Expanded(
                                flex: 6,
                                child: TextButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      elevation: 0,
                                      padding: EdgeInsets.symmetric(vertical: 15.0),
                                      backgroundColor: mediumPurple,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ),
                                    onPressed: ()async {
                                      if(!data['completed']){
                                        await FirebaseFirestore.instance
                                            .collection('tasks')
                                            .doc(data['notificationId'])
                                            .update({"completed": true});

                                        await AwesomeNotifications().cancelNotificationsByGroupKey(data['notificationId']);
                                        await AwesomeNotifications().cancelSchedulesByGroupKey(data['notificationId']);
                                        Navigator.pop(context);
                                      }

                                    },
                                    icon: Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                    ),
                                    label: data['completed'] ?
                                    Text(
                                      "Completed",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          letterSpacing: 1.0
                                      ),
                                    ) : Text(
                                      "Mark as done",
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          letterSpacing: 1.0
                                      ),
                                    )
                                ),)
                            ],
                          ),
                          SizedBox(height: 20.0,),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );

  }
}