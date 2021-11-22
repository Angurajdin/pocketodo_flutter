import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/screens/home/taskList.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter/material.dart';
import 'bottomFloatingNav.dart';


class CompletedTask extends StatefulWidget {
  const CompletedTask({Key? key}) : super(key: key);

  @override
  _CompletedTaskState createState() => _CompletedTaskState();
}

class _CompletedTaskState extends State<CompletedTask> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context)=> Scaffold(
        appBar: AppBar(
          title: Text("Completed Tasks"),
          centerTitle: true,
          titleSpacing: 1.0,
          backgroundColor: mediumPurple,
        ),
        drawer: DrawerPage(),
        body: TaskList(queryString: "completed", dataNullMsge: "Your completed list is empty.",category: "",),
      ),
    );
  }
}
