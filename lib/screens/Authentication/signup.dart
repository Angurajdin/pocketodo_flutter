import 'package:pocketodo/screens/Authentication/login.dart';
import 'package:pocketodo/shared/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';

class Signup extends StatefulWidget {
  const Signup({Key? key}) : super(key: key);

  @override
  _SignupState createState() => _SignupState();
}

class _SignupState extends State<Signup> {

  String error = '';
  bool _isHidden = true;

  // text field state
  String email = '';
  String password = '';
  String mobileNo = '';
  String userName = '';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (context) => Login(),
        '/loading': (context) => Loading(),
      },
      theme: ThemeData(fontFamily: 'rubik'),
      home: Scaffold(

        body: Builder(
          builder: (context)=> Center(
            child: ListView(
              padding: EdgeInsets.all(40.0),
              children: <Widget>[
                SizedBox(height: 35.0,),
                Image.asset(
                  'images/logodark.jpg',
                  height: 30.0,
                  width: 400.0,
                ),
                SizedBox(height: 20.0,),
                Text(
                  'Signup Here',
                  style: TextStyle(
                    letterSpacing: 1.2,
                    fontFamily: 'Rubik',
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.0,),
                Text(
                  "   Username",
                  style: formTextInputStyle.copyWith(
                    fontSize: 16.0
                  ),
                ),
                SizedBox(height: 3.0,),
                TextFormField(
                  decoration: textInputDecoration,
                  onChanged: (val) {
                    setState(() => userName = val);
                  },
                ),
                SizedBox(height: 20.0,),
                Text(
                  "   Email address",
                  style: formTextInputStyle.copyWith(
                      fontSize: 16.0
                  ),
                ),
                SizedBox(height: 3.0,),
                TextFormField(
                  decoration:
                  textInputDecoration.copyWith(hintText: "Enter your Email address"),
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                ),
                SizedBox(height: 20.0,),
                Text(
                  "   Password",
                  style: formTextInputStyle.copyWith(
                      fontSize: 16.0
                  ),
                ),
                SizedBox(height: 3.0,),
                TextFormField(
                  obscureText: _isHidden,
                  decoration:
                  textInputDecoration.copyWith(
                    contentPadding: EdgeInsets.all(16.0),
                    hintText: "Enter your Password",
                    suffix: InkWell(
                      onTap: (){
                        setState(() {
                          _isHidden = !_isHidden;
                        });
                      },
                      child: Icon(
                        Icons.visibility,
                        size: 20.0,
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
                SizedBox(height: 20.0,),
                Text(
                  "   Mobile No",
                  style: formTextInputStyle.copyWith(
                      fontSize: 16.0
                  ),
                ),
                SizedBox(height: 3.0,),
                TextFormField(
                  keyboardType: TextInputType.number,
                  // Only numbers can be entered
                  textInputAction: TextInputAction.go,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                  decoration:
                  textInputDecoration.copyWith(hintText: "Enter your Mobile No"),
                  onChanged: (val) {
                    setState(() => mobileNo = val);
                  },
                ),
                SizedBox(height: 25.0,),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                    backgroundColor: mediumPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'SIGN UP',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  onPressed: () async {

                    Navigator.pushNamed(context, '/loading');

                    if(userName.trim()!="" && password.trim()!="" && email.trim()!="" && mobileNo.trim()!="") {

                      if(userName.length<3 || mobileNo.length!=10){
                        if(userName.length<3){
                          setState(() {
                            error = "UserName must be at least 3 characters";
                          });
                        }
                        if(mobileNo.length!=10){
                          setState(() {
                            error = "Mobile No must be 10 characters";
                          });
                        }
                        Navigator.pop(context);
                        showToast(error,
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
                      else{
                        try {
                          UserCredential userCredential = await FirebaseAuth
                              .instance
                              .createUserWithEmailAndPassword(
                              email: email, password: password);

                          await FirebaseFirestore.instance.collection('users').doc(email).set({
                              "username": userName,
                              "emailid": email,
                              "password": password,
                              "mobileNo": mobileNo,
                              "tasks": [],
                              "assigned": [],
                              "groupTasks": [],
                              "notifications": [],
                              "tags": ['Work', 'Personal', 'Shopping', 'Learning', 'Wish List', 'Fitness', 'Birthday'],
                              "declined": []
                          })
                          .then((value) async {
                            print("User Added");
                            await FirebaseAuth.instance.currentUser!.updateDisplayName(userName);
                          });

                        } on FirebaseAuthException catch (e) {
                          if (e.code == 'weak-password') {
                            // print('The password provided is too weak.');
                            setState(() {
                              error = 'The password provided is too weak.Try Stronger!';
                            });
                          } else if (e.code == 'email-already-in-use') {
                            // print('The account already exists for that email.');
                            setState(() {
                              error = 'The account already exists for that email.';
                            });
                          }
                          else {
                            // print(e.message);
                            setState(() {
                              error = e.message as String;
                            });
                          }
                          Navigator.pop(context);
                          showToast(error,
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
                    else{
                      setState(() {
                        error = "Please Enter";
                      });
                      if(password.trim()=="") {
                        setState(() {
                          error += " password,";
                        });
                      }
                      if(email.trim()=="") {
                        setState(() {
                          error += " Email Address,";
                        });
                      }
                      if(userName.trim()=="") {
                        setState(() {
                          error += " UserName,";
                        });
                      }
                      if(mobileNo.trim()=="") {
                        setState(() {
                          error += " Mobile No,";
                        });
                      }
                      Navigator.pop(context);
                      showToast( error,
                          context: context,
                          animation: StyledToastAnimation.slideFromTop,
                          reverseAnimation: StyledToastAnimation.slideToTop,
                          position: StyledToastPosition.top,
                          startOffset: Offset(0.0, -3.0),
                          reverseEndOffset: Offset(0.0, -3.0),
                          duration: Duration(seconds: 5),
                          //Animation duration   animDuration * 2 <= duration
                          animDuration: Duration(seconds: 1),
                          textStyle: TextStyle(
                            color: Colors.black,
                          ),
                          textAlign: TextAlign.center,
                          curve: Curves.elasticOut,
                          backgroundColor: Colors.amberAccent,
                          reverseCurve: Curves.fastOutSlowIn);
                    }
                  },
                ),
                SizedBox(height: 10.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Already have an Account ?',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: Text(
                          "Login",
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 16,
                            color: darkPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
