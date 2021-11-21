import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/screens/home/taskList.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter/material.dart';


class CategoryTask extends StatefulWidget {

  String category;

  CategoryTask({required this.category});

  @override
  _CategoryTaskState createState() => _CategoryTaskState();
}

class _CategoryTaskState extends State<CategoryTask> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Category - ${widget.category}"),
        centerTitle: true,
        titleSpacing: 1.0,
        backgroundColor: mediumPurple,
      ),
      drawer: DrawerPage(),
      body: TaskList(queryString: "category", dataNullMsge: "No task is created for this Category, create a new one by press + button", category: widget.category),
    );
  }
}
