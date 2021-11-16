import 'package:flutter/material.dart';
import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/screens/home/taskList.dart';
import 'package:pocketodo/shared/constants.dart';


class ImportantTaskPage extends StatefulWidget {
  const ImportantTaskPage({Key? key}) : super(key: key);

  @override
  _ImportantTaskPageState createState() => _ImportantTaskPageState();
}

class _ImportantTaskPageState extends State<ImportantTaskPage> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context)=> Scaffold(
        appBar: AppBar(
          title: Text("Important Tasks"),
          centerTitle: true,
          titleSpacing: 1.0,
          backgroundColor: mediumPurple,
        ),
        drawer: DrawerPage(),
        body: TaskList(queryString: "important", dataNullMsge: "Till now, You haven't set no tasks as important",category: "",),
      ),
    );
  }
}
