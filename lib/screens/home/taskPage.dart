import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:flutter/services.dart';

class TaskPage extends StatelessWidget {

  final DateFormat time = DateFormat('jm');

  @override
  Widget build(BuildContext context) {

    Map<String, dynamic> data = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return Scaffold(
      backgroundColor: lightPurple,
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Container(
          padding: EdgeInsets.fromLTRB(20.0, 20.0, 20.0, MediaQuery.of(context).viewInsets.bottom),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Flexible(
                        flex: 9,
                        fit: FlexFit.tight,
                        child: Text(
                          data['title'],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20.0,
                              letterSpacing: 0.42,
                              fontWeight: FontWeight.w900,
                              color: mediumPurple
                          ),
                        ),
                    ),
                    Flexible(
                      flex: 1,
                      child: IconButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.edit, size: 27.0,)
                      ),
                    ),
                  ],
                ),
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
                SizedBox(height: 20.0,),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
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
                      SizedBox(width: 5.0,),
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
                SizedBox(height: 20.0,),
                Text(
                  "Access Permission",
                  style: TextStyle(
                      fontSize: 20.0,
                      letterSpacing: 0.42,
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(height: 20.0,),
                Text(
                  "Tags",
                  style: TextStyle(
                      fontSize: 20.0,
                      letterSpacing: 0.42,
                      fontWeight: FontWeight.bold
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
    );
  }
}
