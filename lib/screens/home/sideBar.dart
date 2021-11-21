import 'package:pocketodo/shared/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class DrawerPage extends StatelessWidget {
  const DrawerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: lightPurple, //This will change the drawer background to blue.
        //other styles
      ),
      child: Drawer(
        elevation: 0.0,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Column(
                children: <Widget>[
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: mediumPurple,
                    ),
                    child: Column(
                      // mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Image.asset(
                          'images/Logo.jpg',
                          height: 35,
                        ),
                        SizedBox(height: 5.0,),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Image.asset(
                              'images/Pocketodo_logo.png',
                              height: 60.0,
                              width: 60.0,
                            ),
                          ),
                        ),
                        SizedBox(height: 9.0,),
                        Align(
                            alignment: Alignment.bottomLeft,
                            child: Text(
                              FirebaseAuth.instance.currentUser!.displayName ?? "Set Username",
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.white,
                                letterSpacing: 0.7,
                              ),
                            )
                        )
                      ],
                    ),
                  ),
                  ListTile(
                    dense: true,
                    title: Text(
                      "Today's tasks",
                      style: TextStyle(
                          color: textColorDarkPurple,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    horizontalTitleGap: 0.0,
                    leading: Icon(
                      Icons.calendar_today_rounded,
                      color: textColorDarkPurple,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/today');
                    },
                  ),
                  ListTile(
                    dense: true,
                    horizontalTitleGap: 0.0,
                    title: Text(
                      "Completed tasks",
                      style: TextStyle(
                          color: textColorDarkPurple,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    leading: Icon(
                      Icons.format_list_bulleted_rounded,
                      color: textColorDarkPurple,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/completed');
                    },
                  ),
                  // ListTile(
                  //   dense: true,
                  //   horizontalTitleGap: 0.0,
                  //   title: Text(
                  //     "Assigned to you",
                  //     style: TextStyle(
                  //         color: textColorDarkPurple,
                  //         fontSize: 16.0,
                  //         fontWeight: FontWeight.w600
                  //     ),
                  //   ),
                  //   leading: Icon(
                  //     Icons.person,
                  //     color: textColorDarkPurple,
                  //   ),
                  //   onTap: () {
                  //     Navigator.pop(context);
                  //   },
                  // ),
                  ListTile(
                    dense: true,
                    horizontalTitleGap: 0.0,
                    title: Text(
                      "Important",
                      style: TextStyle(
                          color: textColorDarkPurple,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    leading: Icon(
                      Icons.star,
                      color: textColorDarkPurple,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/important');
                    },
                  ),
                  ListTile(
                    dense: true,
                    horizontalTitleGap: 0.0,
                    title: Text(
                      "Profile",
                      style: TextStyle(
                          color: textColorDarkPurple,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    leading: Icon(
                      Icons.manage_accounts_rounded,
                      color: textColorDarkPurple,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    dense: true,
                    horizontalTitleGap: 0.0,
                    title: Text(
                      "Logout",
                      style: TextStyle(
                          color: textColorDarkPurple,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    leading: Icon(
                      Icons.logout_rounded,
                      color: textColorDarkPurple,
                    ),
                    onTap: () async{
                      // Loading();
                      await FirebaseAuth.instance.signOut();
                      // Navigator.pop(context);
                    },
                  ),
                ],
              ),
              Divider(
                height: 33.0,
                thickness: 1.0,
              ),
              Column(
                children: <Widget>[
                  ListTile(
                    dense: true,
                    horizontalTitleGap: 0.0,
                    title: Text(
                      "Trash",
                      style: TextStyle(
                          color: darkPurple,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    leading: Icon(
                      Icons.delete,
                      color: darkPurple,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/trash');
                    },
                  ),
                  ListTile(
                    dense: true,
                    horizontalTitleGap: 0.0,
                    title: Text(
                      "Share",
                      style: TextStyle(
                          color: darkPurple,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    leading: Icon(
                      Icons.share,
                      color: darkPurple,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    dense: true,
                    horizontalTitleGap: 0.0,
                    title: Text(
                      "About us",
                      style: TextStyle(
                          color: darkPurple,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600
                      ),
                    ),
                    leading: Icon(
                      Icons.info,
                      color: darkPurple,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              )
            ],
          ),
        )
      ),
    );
  }
}