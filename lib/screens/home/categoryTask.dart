import 'package:pocketodo/screens/home/sideBar.dart';
import 'package:pocketodo/screens/home/taskList.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter/material.dart';


class CategoryTask extends StatefulWidget {
  const CategoryTask({Key? key}) : super(key: key);

  @override
  _CategoryTaskState createState() => _CategoryTaskState();
}

class _CategoryTaskState extends State<CategoryTask> {

  late String category;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    category = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text("Category - $category"),
        centerTitle: true,
        titleSpacing: 1.0,
        backgroundColor: mediumPurple,
      ),
      drawer: DrawerPage(),
      body: TaskList(queryString: "category", dataNullMsge: "No task is created for this Category, create a new one by press + button", category: category),
    );
  }
}
