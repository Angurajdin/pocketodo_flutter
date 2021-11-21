import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:pocketodo/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "dart:math";
import 'bottomFloatingNav.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({Key? key}) : super(key: key);

  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {

  late dynamic nav;
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

    List<int> categoryColors = [0xFFE4DBFA, 0xFFD7E7F7, 0xFFDBF6F1, 0xFFFBE9D1, 0xFFFBE8E4, 0xFFE6FBE4, 0xFFFBE4F5, 0xFFFFE3E2]..shuffle();
    final _random = new Random();

    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return Scaffold(
      appBar: AppBar(
        title: Text("Categories", style: TextStyle(color: Colors.white),),
        backgroundColor: mediumPurple,
      ),
      drawer: DrawerPage(),
      bottomNavigationBar: bottomFloatingNav(currentIndex: 1,),
      body: FutureBuilder<DocumentSnapshot>(
        future: users.doc(FirebaseAuth.instance.currentUser!.email).get(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {

          if (snapshot.hasError) {
            return Text("Something went wrong");
          }

          if (snapshot.hasData && !snapshot.data!.exists) {
            return Text("Document does not exist");
          }

          if (snapshot.connectionState == ConnectionState.done) {

            Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
            // print(data);
            return ListView(
                padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                children:  List<Widget>.generate(data['tags'].length, (index)=>

                    new Column(
                      children: <Widget>[
                        GestureDetector(
                          onTap: (){
                            Navigator.pushNamed(context, '/categorytask', arguments: data['tags'][index]);
                          },
                          child: Container(
                            padding: EdgeInsets.all(20.0),
                            child: InkWell(
                              splashColor: lightPurple,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  Flexible(
                                    child: Container(),
                                    fit: FlexFit.tight,
                                    flex: 1,
                                  ),
                                  Expanded(
                                    child:  Text(
                                      data['tags'][index],
                                      style: TextStyle(
                                        // color: Colors.white,
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.5
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: Container(),
                                    flex: 2,
                                  ),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Color(categoryColors[index~/categoryColors.length]),
                              borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  spreadRadius: 5,
                                  blurRadius: 5,
                                  offset: Offset(0, 5), // changes position of shadow
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 15.0,),
                      ],
                    )
                  ),
            );
          }

          return Loading();
        },
      ),
    );
  }

}
