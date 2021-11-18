import 'package:cool_alert/cool_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'loading.dart';

const textInputDecoration = InputDecoration(
  hintText: "Enter your Username",
  fillColor: const Color(0xFFE7E6F4),
  filled: true,
  contentPadding: EdgeInsets.all(20.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Colors.white, width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: const Color(0xFF706897), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(30.0)),
  ),
);

const formTextInputFieldDecoration = InputDecoration(
  filled: true,
  contentPadding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 10.0),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF706897), width: 1.2),
    borderRadius: BorderRadius.all(Radius.circular(20.0))
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: const Color(0xFF706897), width: 1.2),
    borderRadius: BorderRadius.all(Radius.circular(20.0)),
  ),
);

const formTextInputStyle = TextStyle(
  fontSize: 16.0,
  color: Color(0xFF706897),
);

const darkPurple = Color(0xFF706897);
const lightPurple = Color(0xFFE7E6F4);
const textColorDarkPurple = Color(0xFF262A35);
const mediumPurple = Color(0xFF9088D3);