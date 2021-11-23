import 'package:pocketodo/screens/Authentication/signup.dart';
import 'package:pocketodo/shared/loading.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pocketodo/shared/constants.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:google_sign_in/google_sign_in.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login>  {

  String error = '';
  bool _isHidden = true;

  // text field state
  String email = '';
  String resendEmail = '';
  String password = '';

  FirebaseAuth auth = FirebaseAuth.instance;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'rubik'),
      routes: {
        '/signup': (context) => Signup(),
        '/loading': (context) => Loading()
      },
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Builder(
          builder: (context)=>Center(
            child: ListView(
              padding: EdgeInsets.all(40.0),
              children: <Widget>[
                SizedBox(height: 40.0,),
                Image.asset(
                  'images/logodark.jpg',
                  height: 50.0,
                  width: 400.0,
                ),
                SizedBox(height: 20.0,),
                Text(
                  'Sign in to continue',
                  style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 20,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.8
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30.0,),
                Text(
                  "   Email address",
                  style: formTextInputStyle.copyWith(
                      fontSize: 16.0
                  ),
                ),
                SizedBox(height: 5.0,),
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: "Enter your Email address"),
                  validator: (val) => val!="" ? 'Enter an email' : null,
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
                SizedBox(height: 5.0,),
                TextFormField(
                  obscureText: _isHidden,
                  textInputAction: TextInputAction.go,
                  decoration:
                  textInputDecoration.copyWith(
                    hintText: "Enter your Password",
                    contentPadding: EdgeInsets.all(18.0),
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
                  validator: (val) => val != "" ? 'Enter an Password' : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                ),
                SizedBox(height: 10.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                        onPressed: () async{
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('Find your Account'),
                                  content: TextField(
                                    onChanged: (value) {
                                      setState(() {
                                        resendEmail = value;
                                      });
                                    },
                                    decoration: InputDecoration(hintText: "Email address"),
                                  ),
                                  actions: <Widget>[
                                    ElevatedButton(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          color: mediumPurple,
                                        ),
                                      ),
                                      style: TextButton.styleFrom(
                                        side: BorderSide(color: mediumPurple,),
                                        alignment: Alignment.center,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        backgroundColor: Colors.white
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          Navigator.pop(context);
                                        });
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text(
                                        "Confirm",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all(
                                            mediumPurple
                                        ),
                                        shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10.0),
                                          ),
                                        ),
                                      ),
                                      onPressed: () async{
                                        if(resendEmail.trim()!=""){
                                          try{
                                            await auth.sendPasswordResetEmail(email: resendEmail);
                                            Navigator.pop(context);
                                            showToast('Reset password link has sent to $resendEmail',
                                                context: context,
                                                animation: StyledToastAnimation.scale,
                                                reverseAnimation: StyledToastAnimation.fade,
                                                position: StyledToastPosition.top,
                                                animDuration: Duration(seconds: 1),
                                                duration: Duration(seconds: 5),
                                                curve: Curves.elasticOut,
                                                reverseCurve: Curves.linear);
                                          }on FirebaseAuthException catch (e){
                                            Navigator.pop(context);
                                            showToast('${e.message}',
                                                context: context,
                                                animation: StyledToastAnimation.scale,
                                                reverseAnimation: StyledToastAnimation.fade,
                                                position: StyledToastPosition.top,
                                                animDuration: Duration(seconds: 1),
                                                duration: Duration(seconds: 5),
                                                curve: Curves.elasticOut,
                                                reverseCurve: Curves.linear);
                                          }
                                        } else{
                                          Navigator.pop(context);
                                        }
                                      },
                                    ),

                                  ],
                                );
                              });
                        },
                        child: Text(
                          "Forgot Password ?",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14.0,
                            fontWeight: FontWeight.w400,
                          ),
                        )
                    ),
                  ],
                ),
                SizedBox(height: 15.0,),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 100, vertical: 15),
                    backgroundColor: mediumPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35),
                    ),
                  ),
                  child: Text(
                    'LOGIN',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: 1.0
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pushNamed(context, '/loading');
                    if(email.trim()!="" && password.trim()!=""){
                      try {
                        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                            email: email.trim(),
                            password: password.trim()
                        );
                      } on FirebaseAuthException catch (e) {

                        // print(e.message);
                        setState(() {
                          // error = e.message as String;
                          error = "Invalid Username or Password";
                        });

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
                    else{
                      if(email.trim()=="" && password.trim()=="") {
                        setState(() {
                          error = "Please, Enter Email and password";
                        });
                      }
                      else if(email.trim()=="" && password.trim()!="") {
                        setState(() {
                          error = "Please, Enter Email Address";
                        });
                      }
                      else {
                        setState(() {
                          error = "Please, Enter Password";
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
                SizedBox(height: 15.0,),
                const Divider(
                  height: 20,
                  thickness: 1,
                  indent: 10,
                  endIndent: 10,
                  color: darkPurple,
                ),
                SizedBox(height: 15.0,),
                ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await _googleSignIn.signIn();
                      } catch (error) {
                        print(error);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      elevation: 0,
                      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 6),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(35),
                        side: BorderSide(
                            color: darkPurple,
                            width: 1
                        ),
                      ),
                    ),
                    icon: Image.asset(
                      "images/glogo.jpg",
                      width: 40.0,
                      height: 40.0,
                    ),
                    label: Text(
                      "Continue with Google Account",
                      style: TextStyle(
                          color: Colors.black,
                          letterSpacing: 0.1,
                          fontWeight: FontWeight.w400,
                          fontSize: 16.0
                      ),
                    )
                ),
                SizedBox(height: 10.0,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "Don't have an Account ?",
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    TextButton(
                        onPressed: (){
                          Navigator.pushNamed(context, '/signup');
                        },
                        child: Text(
                          "Register",
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 16,
                            color: darkPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                    ),
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
