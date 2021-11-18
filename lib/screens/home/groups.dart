import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/screens/home/taskList.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter/material.dart';
import 'bottomFloatingNav.dart';


class Groups extends StatefulWidget {
  const Groups({Key? key}) : super(key: key);

  @override
  _GroupsState createState() => _GroupsState();
}

class _GroupsState extends State<Groups> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context)=> Scaffold(
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
        bottomNavigationBar: bottomFloatingNav(currentIndex: 2,),
        body: TaskList(queryString: "home", dataNullMsge: "No todo has created till now, Create new one by pressing the below + button",category: "",),
      ),
    );
  }
}
