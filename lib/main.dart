import 'package:flutter/material.dart';
import 'Home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance
      .collection("usuarios")
      .document("001")
      .setData({"nome": "Melquis"});

  runApp(MaterialApp(
    home: Home(),
    debugShowCheckedModeBanner: false,
  ));
}
