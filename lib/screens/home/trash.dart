import 'package:flutter/material.dart';
import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/screens/home/taskList.dart';
import 'package:pocketodo/shared/constants.dart';

import 'bottomFloatingNav.dart';


class TrashPage extends StatefulWidget {
  const TrashPage({Key? key}) : super(key: key);

  @override
  _TrashPageState createState() => _TrashPageState();
}

class _TrashPageState extends State<TrashPage> {
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context)=> Scaffold(
        appBar: AppBar(
          title: Text("Deleted Tasks"),
          centerTitle: true,
          titleSpacing: 1.0,
          backgroundColor: mediumPurple,
        ),
        drawer: DrawerPage(),
        body: TaskList(queryString: "trash", dataNullMsge: "Your trash is empty",category: "",),
      ),
    );
  }
}
