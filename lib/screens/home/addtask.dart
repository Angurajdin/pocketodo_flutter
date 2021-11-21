import 'package:pocketodo/services/createDynamicLink.dart';
import 'package:pocketodo/shared/loading.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'dart:math';


final random = new Random();


class Language extends Taggable {
  final String name;
  Language({
    required this.name
  });

  @override
  List<Object> get props => [name];
  /// Converts the class to json string.
  String toJson() => '''  {
    "name": $name,\n
  }''';
}


void Notify(selectedDateTime, id, taskData) async{

  late final taskDesc;

  if(taskData['description'].length>40){
    taskDesc = taskData['description'].substring(0, 40) + "...";
  }
  else{
    taskDesc = taskData['description'];
  }

  await AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: random.nextInt(pow(2, 31).toInt()),
      groupKey: id.toString(),
      channelKey: 'pocketodo',
      title: taskData['title'],
      body: taskDesc,
      payload: {"id": id.toString()}
    ),
    schedule: NotificationCalendar.fromDate(date: selectedDateTime),
    actionButtons: [
      NotificationActionButton(
        key: 'MARK_DONE',
        label: 'Mark as done',
        color: mediumPurple,
      )
    ],
  );

}


class AddTask extends StatefulWidget {
  const AddTask({Key? key}) : super(key: key);

  @override
  _AddTaskState createState() => _AddTaskState();
}

class _AddTaskState extends State<AddTask> {

  String url = "";

  var focusNode = FocusNode();
  var focusNodeDesc = FocusNode();
  var focusNodeLink = FocusNode();
  var focusNodeSlider = FocusNode();
  bool inpuFieldsFocus = true;
  final _formKey = GlobalKey<FormState>();
  TextEditingController title = new TextEditingController();
  final format = DateFormat("dd-MM-yyyy HH:mm");
  final DateFormat dateMonthYear = DateFormat('dd-MM-yyyy');
  
  double _currentSliderValue = 1;
  dynamic selectedDateTime;
  String _selectedValuesJson = 'Nothing to show';
  String description = "", link = "", permission="private";
  late final List<Language> _selectedLanguages;
  late List<Language> userTags = [];
  List<String> selectedTags = [];
  CollectionReference taskCollectionRef = FirebaseFirestore.instance.collection('tasks');

  Future<List<Language>> getLanguages(String query) async {

    return userTags
        .where((lang) => lang.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> addTask() async {
    // Call the user's CollectionReference to add a new user

    for(dynamic a in _selectedLanguages){
      selectedTags.add(a.name.toString());
    }

    final taskData = {
      "id": null,
      "title": title.text.toString(),
      "description": description,
      "datetime": selectedDateTime,
      "date": dateMonthYear.format(selectedDateTime),
      "link": link.trim(),
      "priority": _currentSliderValue,
      "tags": selectedTags,
      "members": [FirebaseAuth.instance.currentUser!.email],
      "membersPermission": [],
      "declined": [],
      "requested": [],
      "createdBy": FirebaseAuth.instance.currentUser!.email,
      "createdAt": DateTime.now(),
      "modifiedAt": null,
      "deleted": false,
      "permission": permission,
      "important": false,
      "completed": false,
      "taskLink": ""
    };

    return taskCollectionRef
        .add(taskData)
        .then((value) async{
            // task added
            url = await createDynamicLink.buildDynamicLink(value.id);
            await taskCollectionRef.doc(value.id).update({"id": value.id, "notificationId": value.id, "taskLink": url});
            Notify(selectedDateTime, value.id, {...taskData, "id": value.id, "notificationId": value.id, "taskLink": url});
            Navigator.pop(context);
            Navigator.pop(context);
          }
        )
        .catchError((error) {
          print("Failed to add task: $error");
          Navigator.pop(context);
          showToast(error.toString(),
              context: context,
              animation: StyledToastAnimation.slideFromTop,
              reverseAnimation: StyledToastAnimation.slideToTop,
              position: StyledToastPosition.top,
              startOffset: Offset(0.0, -3.0),
              reverseEndOffset: Offset(0.0, -3.0),
              duration: Duration(seconds: 5),
              //Animation duration   animDuration * 2 <= duration
              animDuration: Duration(seconds: 1),
              curve: Curves.elasticOut,
              backgroundColor: Colors.redAccent,
              reverseCurve: Curves.fastOutSlowIn);
        });

  }

  @override
  void initState() {

    focusNode.addListener(() {
      if(focusNode.hasFocus)
        inpuFieldsFocus = false;
      else
        inpuFieldsFocus = true;
    });
    focusNodeDesc.addListener(() {
      if(focusNodeDesc.hasFocus)
        inpuFieldsFocus = false;
      else
        inpuFieldsFocus = true;
    });
    focusNodeLink.addListener(() {
      if(focusNodeLink.hasFocus)
        inpuFieldsFocus = false;
      else
        inpuFieldsFocus = true;
    });
    focusNodeSlider.addListener(() {
      if(focusNodeSlider.hasFocus)
        inpuFieldsFocus = false;
      else
        inpuFieldsFocus = true;
    });

    userTags = [];

    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        // print('Document data: ${documentSnapshot.data()}');
        for(var i in documentSnapshot.get('tags')){
          userTags.add(Language(name: i));
        }
      } else {
        print('Document does not exist on the database');
      }
    });
    super.initState();
    _selectedLanguages = [];
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    focusNode.dispose();
    focusNodeDesc.dispose();
    focusNodeSlider.dispose();
    focusNodeLink.dispose();
    _selectedLanguages.clear();
    title.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightPurple,
      // resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Scrollbar(
          isAlwaysShown: true,
          child: SingleChildScrollView(
            padding: inpuFieldsFocus ?
            EdgeInsets.fromLTRB(20.0, 3.0, 20.0, MediaQuery.of(context).viewInsets.bottom):
            EdgeInsets.all(20.0),
            child: Container(
              // color: lightPurple,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            icon: Icon(Icons.close, size: 30.0,)
                        ),
                      ],
                    ),
                    Text(
                        "Title",
                        style: formTextInputStyle
                    ),
                    SizedBox(height: 5.0,),
                    TextFormField(
                      // The validator receives the text that the user has entered.
                      controller: title,
                      focusNode: focusNode,
                      keyboardType: TextInputType.text,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                      decoration: formTextInputFieldDecoration.copyWith(
                          hintText: 'title'
                      ),
                      style: TextStyle(
                        fontSize: 18.0,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 15.0,),
                    Text(
                      "Description",
                      style: formTextInputStyle,
                    ),
                    SizedBox(height: 5.0,),
                    TextField(
                      focusNode: focusNodeDesc,
                      decoration: formTextInputFieldDecoration.copyWith(
                          hintText: 'description'
                      ),
                      maxLines: 3,
                      onChanged: (val)=> setState(() {
                        description = val;
                      }),
                      style: TextStyle(
                        fontSize: 18.0,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 15.0,),
                    Text(
                      "DateTime",
                      style: formTextInputStyle,
                    ),
                    SizedBox(height: 5.0,),
                    DateTimeField(
                      initialValue: selectedDateTime,
                      format: format,
                      onChanged: (val) =>setState(() {
                        selectedDateTime = val;
                      }),
                      onSaved: (val) =>setState(() {
                        selectedDateTime = val;
                      }),
                      onShowPicker: (context, currentValue) async {
                        final date = await showDatePicker(
                            context: context,
                            firstDate: DateTime.now(),
                            initialDate: currentValue ?? DateTime.now(),
                            lastDate: DateTime(2100));
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime:
                            TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                          );
                          return DateTimeField.combine(date, time);
                        } else {
                          return currentValue;
                        }
                      },
                    ),
                    SizedBox(height: 15.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Priority",
                          style: formTextInputStyle,
                        ),
                        Expanded(
                          child: Slider(
                              focusNode: focusNodeSlider,
                              value: _currentSliderValue,
                              min: 1,
                              max: 10,
                              divisions: 9,
                              activeColor: darkPurple,
                              inactiveColor: mediumPurple,
                              label: _currentSliderValue.round().toString(),
                              onChanged: (double value) {
                                setState(() {
                                  _currentSliderValue = value;
                                });
                              }
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Text(
                      "Category",
                      style: formTextInputStyle,
                    ),
                    SizedBox(height: 5.0,),
                    FlutterTagging<Language>(
                      initialItems: _selectedLanguages,
                      textFieldConfiguration: TextFieldConfiguration(
                          decoration: formTextInputFieldDecoration.copyWith(
                            filled: true,
                            hintText: 'Tags',
                          )
                      ),
                      findSuggestions: getLanguages,
                      additionCallback: (value) {
                        return Language(
                            name: value
                        );
                      },
                      onAdded: (language) {
                        // api calls here, triggered when add to tag button is pressed

                        return language;
                      },
                      configureSuggestion: (lang) {
                        return SuggestionConfiguration(
                          title: Text(lang.name),
                          additionWidget: Chip(
                            avatar: Icon(
                              Icons.add_circle,
                              color: Colors.white,
                            ),
                            label: Text('Add New Tag'),
                            labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              // fontWeight: FontWeight.w400,
                            ),
                            backgroundColor: mediumPurple,
                          ),
                        );
                      },
                      configureChip: (lang) {
                        return ChipConfiguration(
                          label: Text(lang.name),
                          backgroundColor: mediumPurple,
                          labelStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0
                          ),
                          deleteIconColor: Colors.white,
                        );
                      },
                      onChanged: () {
                        setState(() {
                          _selectedValuesJson = _selectedLanguages
                              .map<String>((lang) => '\n${lang.toJson()}')
                              .toList()
                              .toString();
                          _selectedValuesJson =
                              _selectedValuesJson.replaceFirst('}]', '}\n]');
                        });
                      },
                    ),
                    SizedBox(height: 15.0,),
                    Text(
                      "Link",
                      style: formTextInputStyle,
                    ),
                    SizedBox(height: 5.0,),
                    TextField(
                      key: Key("link"),
                      focusNode: focusNodeLink,
                      autofocus: false,
                      decoration: formTextInputFieldDecoration.copyWith(
                          hintText: 'link'
                      ),
                      onChanged: (val)=> setState(() {
                        link = val;
                      }),
                      style: TextStyle(
                        fontSize: 18.0,
                        letterSpacing: 1.0,
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    Text(
                      "Access Permission",
                      style: TextStyle(
                          fontSize: 20.0,
                          letterSpacing: 0.42,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    SizedBox(height: 12.0,),
                    Row(
                      children: <Widget>[
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 5,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                permission = "private";
                              });
                            },
                            child: Container(
                              height: 100.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.person, size: 25.0,
                                    color: permission=='private' ? Colors.white : Colors.black,
                                  ),
                                  Text(
                                    "Only me",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: permission=='private' ? Colors.white : Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: permission=='private' ? FontWeight.w600 : FontWeight.normal,
                                      letterSpacing: 0.42,
                                    ),
                                  ),
                                ],
                              ),
                              decoration:
                              permission=='private' ?
                              BoxDecoration(
                                  color: mediumPurple,
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 4.0,
                                  )
                              ) :
                              BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              ),
                            ),
                          ),
                        ),
                        Flexible(child: Container(), flex: 1,),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 5,
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                permission = "public";
                              });
                            },
                            child: Container(
                              height: 100.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.link, size: 26.0,
                                    color: permission=='public' ? Colors.white : Colors.black,
                                  ),
                                  SizedBox(height: 6.5,),
                                  Text(
                                    "Anyone with link",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: permission=='public' ? Colors.white : Colors.black,
                                      fontSize: 15.0,
                                      fontWeight: permission=='public' ? FontWeight.w600 : FontWeight.normal,
                                      letterSpacing: 0.42,
                                    ),
                                  ),
                                ],
                              ),
                              decoration:
                              permission=='public' ?
                              BoxDecoration(
                                  color: mediumPurple,
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 4.0,
                                  )
                              ) :
                              BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              ),
                            ),
                          ),
                        ),
                        Flexible(child: Container(), flex: 1,),
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 5,
                          child: GestureDetector(
                            onTap: (){
                              setState(() {
                                permission = "protected";
                              });
                            },
                            child: Container(
                              height: 100.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Icon(Icons.lock, size: 23.0,
                                    color: permission=='protected' ? Colors.white : Colors.black,
                                  ),
                                  SizedBox(height: 5.0,),
                                  Text(
                                    "Access  required",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: permission=='protected' ? FontWeight.w600 : FontWeight.normal,
                                      color: permission=='protected' ? Colors.white : Colors.black,
                                      fontSize: 15.0,
                                      letterSpacing: 0.42,
                                    ),
                                  ),
                                ],
                              ),
                              decoration:
                              permission=='protected' ?
                              BoxDecoration(
                                  color: mediumPurple,
                                  borderRadius: BorderRadius.all(Radius.circular(15.0)),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.6),
                                    width: 4.0,
                                  )
                              ) :
                              BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: (){
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            elevation: 0,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            backgroundColor: lightPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                  color: mediumPurple,
                                  width: 1
                              ),
                            ),
                          ),
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                                color: textColorDarkPurple,
                                letterSpacing: 0.1,
                                fontSize: 20.0
                            ),
                          ),
                        ),
                        OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              elevation: 0,
                              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                              backgroundColor: mediumPurple,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: Text(
                              'Create Task',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  letterSpacing: 1.0
                              ),
                            ),
                            onPressed: () async{
                              if (_formKey.currentState!.validate()) {

                                if(selectedDateTime!=null && selectedDateTime.isAfter(DateTime.now())){
                                  Navigator.pushNamed(context, '/loading');
                                  addTask();

                                }
                                else{
                                  showToast("Select Valid DateTime to create Task !",
                                      context: context,
                                      animation: StyledToastAnimation.slideFromTop,
                                      reverseAnimation: StyledToastAnimation.slideToTop,
                                      position: StyledToastPosition.top,
                                      startOffset: Offset(0.0, -3.0),
                                      reverseEndOffset: Offset(0.0, -3.0),
                                      duration: Duration(seconds: 5),
                                      //Animation duration   animDuration * 2 <= duration
                                      animDuration: Duration(seconds: 1),
                                      curve: Curves.elasticOut,
                                      backgroundColor: Colors.redAccent,
                                      reverseCurve: Curves.fastOutSlowIn);
                                }
                              }
                            }
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
      ),
    );
  }
}


