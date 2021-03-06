import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter_tagging/flutter_tagging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:cool_alert/cool_alert.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

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


class EditTask extends StatefulWidget {

  Map<String, dynamic> data;

  EditTask({required this.data});

  @override
  _EditTaskState createState() => _EditTaskState();
}

class _EditTaskState extends State<EditTask> {

  final format = DateFormat("dd-MM-yyyy HH:mm");
  final DateFormat dateMonthYear = DateFormat('dd-MM-yyyy');
  dynamic data = null;

  double priorityLevel = 1;
  dynamic selectedDateTime;
  String _selectedValuesJson = 'Nothing to show';
  String description = "", link = "", permission="", title="";
  late List<Language> userTags = [];
  late List<Language> _selectedLanguages=[];
  List<String> selectedTags = [];
  CollectionReference taskCollectionRef = FirebaseFirestore.instance.collection('tasks');

  Future<List<Language>> getLanguages(String query) async {
    return userTags
        .where((lang) => lang.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<void> updateTask() async {
    // Call the user's CollectionReference to add a new user

    selectedTags=[];
    for(dynamic a in _selectedLanguages){
      selectedTags.add(a.name);
    }

    final taskData = {
      "title": title.toString().trim(),
      "description": description.trim(),
      "datetime": selectedDateTime,
      "date": dateMonthYear.format(selectedDateTime),
      "link": link.trim(),
      "priority": priorityLevel,
      "tags": selectedTags,
      "permission": permission,
      "modifiedAt": DateTime.now(),
      "deleted": widget.data['deleted'],
      "important": widget.data['important'],
    };

    return taskCollectionRef
        .doc(widget.data['id'])
        .update(taskData)
        .then((value) async{
      // task added

        Notify(selectedDateTime, widget.data['id'], {...taskData});
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

  Future<void> assignTags() async{
    for(dynamic i in widget.data['tags']){
      String tag = i.toString();
      _selectedLanguages.add(Language(name: tag));
    }
  }

  @override
  void initState() {

    title = widget.data['title'];
    priorityLevel = widget.data['priority'].toDouble();
    selectedDateTime = widget.data['datetime'].toDate();
    permission = widget.data['permission'];
    description = widget.data['description'];
    link = widget.data['link'];

    assignTags().whenComplete((){
      setState(() {});
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
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    Future<void> editDiscard()async{
      selectedTags = [];
      List<String> dbTags = [];
      for(dynamic a in _selectedLanguages){
        selectedTags.add(a.name.toString());
      }
      for(String a in widget.data['tags']){
        dbTags.add(a.toString());
      }
      int datetimeLen = selectedDateTime.millisecondsSinceEpoch.toString().length;
      Function eq = const ListEquality().equals;


      if(title.toString()==widget.data['title'] && description==widget.data['description'] &&
          priorityLevel==widget.data['priority'] && link==widget.data['link'] && widget.data['permission']==permission &&
          selectedDateTime.millisecondsSinceEpoch.toString().substring(0, datetimeLen-3) == widget.data['datetime'].seconds.toString() &&
          eq(selectedTags, dbTags)){
        Navigator.pop(context);
      }
      else{
        CoolAlert.show(
          context: context,
          type: CoolAlertType.confirm,
          text: 'Do you want to update the changes ?',
          confirmBtnText: 'Discard',
          onConfirmBtnTap: (){
            Navigator.of(context, rootNavigator: true).pop();
            Navigator.pop(context);
          },
          confirmBtnColor: mediumPurple,
          cancelBtnText: 'Update',
          onCancelBtnTap: (){
            if (title.trim()!="") {
              if(selectedDateTime!=null && selectedDateTime.isAfter(DateTime.now())){
              Navigator.pushNamed(context, '/loading');
              updateTask();
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
            else{
              showToast("title is mandatory to create Task !",
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
          },
          cancelBtnTextStyle: TextStyle(color: Colors.grey[700]),
        );
      }
    }


    return WillPopScope(
      onWillPop: ()async{

        bool returnCond = false;

        selectedTags = [];
        List<String> dbTags = [];
        for(dynamic a in _selectedLanguages){
          selectedTags.add(a.name.toString());
        }
        for(String a in widget.data['tags']){
          dbTags.add(a.toString());
        }
        int datetimeLen = selectedDateTime.millisecondsSinceEpoch.toString().length;
        Function eq = const ListEquality().equals;

        if(title.toString()==widget.data['title'] && description==widget.data['description'] &&
            priorityLevel==widget.data['priority'] && link==widget.data['link'] && widget.data['permission']==permission &&
            selectedDateTime.millisecondsSinceEpoch.toString().substring(0, datetimeLen-3) == widget.data['datetime'].seconds.toString() &&
            eq(selectedTags, dbTags)){
          returnCond = true;
        }
        else{
          CoolAlert.show(
            context: context,
            type: CoolAlertType.confirm,
            text: 'Want to cancel it',
            confirmBtnText: 'Discard',
            onConfirmBtnTap: (){
              Navigator.of(context, rootNavigator: true).pop();
              returnCond = true;
            },
            confirmBtnColor: mediumPurple,
            cancelBtnText: 'Cancel',
            onCancelBtnTap: (){
              if (title.trim()!="") {
                if(selectedDateTime!=null && selectedDateTime.isAfter(DateTime.now())){
                  Navigator.pushNamed(context, '/loading');
                  updateTask();
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
              else{
                showToast("title is mandatory to create Task !",
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
            },
            cancelBtnTextStyle: TextStyle(color: Colors.grey[700]),
          );
        }
        return returnCond;
      },
      child: Scaffold(
        backgroundColor: lightPurple,
        // resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                      onPressed: (){
                        editDiscard();
                      },
                      icon: Icon(Icons.close, size: 30.0,)
                  ),
                ],
              ),
              Text(
                "Title",
                style: formTextInputStyle,
              ),
              SizedBox(height: 5.0,),
              TextFormField(
                // The validator receives the text that the user has entered.
                initialValue: title,
                keyboardType: TextInputType.text,
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
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
              TextFormField(
                autofocus: true,
                initialValue: description,
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
                    child: SfSlider(
                      min: 0.0,
                      max: 10.0,
                      stepSize: 1.0,
                      value: priorityLevel,
                      activeColor: darkPurple,
                      inactiveColor: mediumPurple,
                      interval: 2,
                      showTicks: true,
                      showLabels: true,
                      enableTooltip: true,
                      minorTicksPerInterval: 1,
                      onChanged: (dynamic value){
                        setState(() {
                          priorityLevel = value;
                        });
                      },
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
              TextFormField(
                initialValue: link,
                decoration: formTextInputFieldDecoration.copyWith(
                  hintText: 'link',
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
                      editDiscard();
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
                        'Update',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            letterSpacing: 1.0
                        ),
                      ),
                      onPressed: () async{
                        if (title.trim()!="") {
                          if(selectedDateTime!=null && selectedDateTime.isAfter(DateTime.now())){
                            Navigator.pushNamed(context, '/loading');
                            updateTask();
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
                        else{
                          showToast("title is mandatory to create Task !",
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
                  )
                ],
              ),
              SizedBox(height: 20.0,),
            ],
          ),
        ),
      ),
    );
  }
}