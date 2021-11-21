import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/screens/home/taskList.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter/material.dart';


class TodayTask extends StatefulWidget {
  const TodayTask({Key? key}) : super(key: key);

  @override
  _TodayTaskState createState() => _TodayTaskState();
}

class _TodayTaskState extends State<TodayTask> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context)=> Scaffold(
        appBar: AppBar(
          title: Text("Today's Tasks"),
          centerTitle: true,
          titleSpacing: 1.0,
          backgroundColor: mediumPurple,
          actions: [
            IconButton(
              onPressed: (){},
              icon: Icon(
                Icons.home_outlined,
              ),
            )
          ],
        ),
        drawer: DrawerPage(),
        body: TaskList(queryString: "today", dataNullMsge: "No task is created for today till now, create a new one by press + button",category: "",),
      ),
    );
  }
}
