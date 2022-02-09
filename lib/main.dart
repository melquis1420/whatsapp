import 'package:flutter/material.dart';
import 'package:whatsapp/Login.dart';
import 'package:whatsapp/RouteGenerator.dart';
import 'Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

//Theme for iOS
final ThemeData temaIOS = ThemeData(
  primaryColor: Colors.grey[200],
  accentColor: Color(0xff25D366),
);

//Theme for Android
final ThemeData temaPadrao = ThemeData(
  primaryColor: Color(0xff075E54),
  accentColor: Color(0xff25D366),
);

void main() {
  runApp(MaterialApp(
    home: Login(),
    //check who plataform
    theme: Platform.isIOS ? temaIOS : temaPadrao,
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
    debugShowCheckedModeBanner: false,
  ));
}
