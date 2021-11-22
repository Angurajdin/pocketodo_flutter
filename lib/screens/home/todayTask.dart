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
              onPressed: (){
                Navigator.pushNamed(context, '/');
              },
              icon: Icon(
                Icons.home,
              ),
            )
          ],
        ),
        drawer: DrawerPage(),
        body: TaskList(queryString: "today", dataNullMsge: "You don't have any tasks due today.\n hey buddy!Chill out and get back soon.", category: "",),
      ),
    );
  }
}
