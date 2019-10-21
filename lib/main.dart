import 'package:bored/view/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sap ranks.',
      theme: ThemeData(
        fontFamily: 'RobotoMono',
        primaryColor: Colors.blueGrey[900],
      ),
      home: Welcome(),
    );
  }
}

