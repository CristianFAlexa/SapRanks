import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class PlayGamePage extends StatefulWidget {
  PlayGamePage({this.user});

  final FirebaseUser user;

  @override
  _PlayGamePageState createState() => _PlayGamePageState(user: user);
}

class _PlayGamePageState extends State<PlayGamePage> {
  _PlayGamePageState({this.user});

  final FirebaseUser user;

  final duration = const Duration(seconds: 1);
  var swatch = Stopwatch();
  String timeDisplay = "00:00:00";

  void startTimer() {
    Timer(duration, isDone);
  }

  void isDone() {
    if (swatch.isRunning) {
      startTimer();
    }
    setState(() {
      timeDisplay = swatch.elapsed.inHours.toString().padLeft(2, "0") +
          ":" +
          (swatch.elapsed.inMinutes % 60).toString().padLeft(2, "0") +
          ":" +
          (swatch.elapsed.inSeconds % 60).toString().padLeft(2, "0");
    });
  }

  void startStopWatch() {
    swatch.start();
    startTimer();
  }

  @override
  void initState() {
    // TODO: implement initState
    startStopWatch();
  }

  @override
  void dispose() {
    super.dispose();
    swatch.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Center(
          child: Text("Queue"),
        ),
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.black38, Colors.black12]),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.blueGrey[800],
                Colors.blueGrey[700],
                Colors.blueGrey[700],
                Colors.blueGrey[800],
              ]),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "Players: \n  2/10   ",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    backgroundColor: Colors.black12),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
              child: Text(
                "$timeDisplay",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    backgroundColor: Colors.black12),
              ),
            ),
            SizedBox(
              height: 200,
            ),
            Center(
              child: RaisedButton(
                onPressed: () {},
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0),
                ),
                color: Colors.green,
                child: new Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                    ),
                    new Container(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: new Text(
                          "Start game",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}