import 'dart:async';

import 'package:bored/service/DatabaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class PlayGamePage extends StatefulWidget {
  PlayGamePage({this.user, this.gameName});

  final FirebaseUser user;
  final String gameName;

  @override
  _PlayGamePageState createState() =>
      _PlayGamePageState(user: user, gameName: gameName);
}

class _PlayGamePageState extends State<PlayGamePage> {
  _PlayGamePageState({this.user, this.gameName});

  final FirebaseUser user;
  final String gameName;

  final duration = const Duration(seconds: 1);
  var swatch = Stopwatch();
  String timeDisplay = "00:00:00";

  Timer startTimer() {
    return Timer(duration, isDone);
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
    startStopWatch();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    swatch.stop();
  }

  Widget getTextWidgets(List<dynamic> strings) {
    return new Column(
        children: strings
            .map((item) => Row(
                  children: <Widget>[
                    StreamBuilder(
                      stream: collectionReference.document(item).snapshots(),
                      builder: (context, snapshot) {
                        return (snapshot.data == null)
                            ? Text("Loading..")
                            : Padding(
                                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                          ),
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: (snapshot.data[
                                                                'profile_picture'] ==
                                                            null)
                                                        ? AssetImage(
                                                            "assets/images/default-profile-picture.png")
                                                        : NetworkImage(snapshot
                                                                .data[
                                                            'profile_picture']))),
                                          ),
                                          Text(
                                            "${snapshot.data['name']}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                      },
                    )
                  ],
                ))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: queueCollectionReference.document(gameName).snapshots(),
        builder: (context, snapshot) {
          return (snapshot.data == null)
              ? Text("Loading..")
              : Scaffold(
                  appBar: GradientAppBar(
                    title: Center(
                      child: Text("Queue"),
                    ),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black87,
                          Colors.black38,
                          Colors.black12
                        ]),
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
                            "Players: \n  ${snapshot.data['players'].length}/${snapshot.data['max_players']}",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                backgroundColor: Colors.black12),
                          ),
                        ),
                        getTextWidgets(snapshot.data['players']),
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
                                    padding: EdgeInsets.only(
                                        left: 10.0, right: 10.0),
                                    child: new Text(
                                      "Start game",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        });
  }
}
