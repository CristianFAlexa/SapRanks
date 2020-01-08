import 'dart:async';

import 'package:bored/model/QueueModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/component/CreateQueue.dart';
import 'package:bored/view/component/QrCodeGenPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'PlayGamePage.dart';

class GamePage extends StatefulWidget {
  GamePage({this.user, this.gameName});

  final FirebaseUser user;
  final String gameName;

  @override
  _GamePageState createState() =>
      _GamePageState(user: user, gameName: gameName);
}

class _GamePageState extends State<GamePage> {
  _GamePageState({this.user, this.gameName});

  final FirebaseUser user;
  final String gameName;

  List<QueueModel> items;
  StreamSubscription<QuerySnapshot> queues;
  DatabaseService databaseService = new DatabaseService();
  List<DocumentSnapshot> snaps;

  @override
  void initState() {
    items = new List();
    queues?.cancel();
    queues = queueCollectionReference
        .document(gameName)
        .collection('active')
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      final List<DocumentSnapshot> queueSnaps = snapshot.documents;
      final List<QueueModel> queueModels = snapshot.documents
          .map((documentSnapshot) => QueueModel.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        snaps = queueSnaps;
        this.items = queueModels;
      });
    });
    super.initState();
  }

  void addUserToList(int index, String listName) {
    List<String> players;
    queueCollectionReference
        .document(gameName)
        .collection('active')
        .document(snaps[index].documentID)
        .get()
        .then((snap) {
      setState(() {
        var tmpList = new List<String>.from(snap.data[listName]);
        tmpList.removeWhere( (item) => item == null);
        players = tmpList;
        players.add(user.uid);
      });
      queueCollectionReference
          .document(gameName)
          .collection('active')
          .document(snaps[index].documentID)
          .updateData({listName: FieldValue.arrayUnion(players)});
      toQueue(context, user, gameName, snaps[index].documentID);
    });
  }

  void showChooseTeamDialog(BuildContext context, int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10)), // RoundedRectangleBorder,
              title: Text(
                "Choose a team",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    "Blue team",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  onPressed: () {
                    addUserToList(index, 'players');
                    addUserToList(index, 'blue_team');
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(
                    "Red team",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  onPressed: () {
                    addUserToList(index, 'players');
                    addUserToList(index, 'red_team');
                    Navigator.of(context).pop();
                  },
                )
              ]);
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black, Colors.black]),
        automaticallyImplyLeading: true,
        actions: <Widget>[
          Center(
            child: RaisedButton(
              onPressed: () => toCreateQueue(context, user, gameName),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              color: Colors.transparent,
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    Icons.accessibility_new,
                    color: Colors.white,
                  ),
                  new Container(
                      padding: EdgeInsets.only(left: 10.0, right: 110.0),
                      child: new Text(
                        "Create new event",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      )),
                ],
              ),
            ),
          ),
        ],
      ),
      body: new Column(
        children: <Widget>[
          Expanded(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 80,
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onDoubleTap: () =>
                        toQrCode(context, snaps[index].documentID, gameName),
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 8.0, right: 8.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 190.0,
                            child: Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Material(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20),
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                                color: Colors.white,
                                elevation: 14.0,
                                shadowColor: Colors.black,
                                child: Container(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(5),
                                        bottomRight: Radius.circular(5),
                                        topLeft: Radius.circular(5),
                                        topRight: Radius.circular(5),
                                      ),
                                      image: DecorationImage(
                                          fit: BoxFit.fill,
                                          image: AssetImage(
                                              "assets/images/spaceman.jpg"))),
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                "$gameName",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .display1
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        backgroundColor:
                                                            Colors.black26),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                "${items[index].description}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .display1
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        backgroundColor:
                                                            Colors.black26,
                                                        fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                "${items[index].location}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .display1
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        backgroundColor:
                                                            Colors.black26,
                                                        fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                "${items[index].eventDate.toDate()}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .display1
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        backgroundColor:
                                                            Colors.black26,
                                                        fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Text(
                                                "Players enrolled ${items[index].players.length}",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .display1
                                                    .copyWith(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        backgroundColor:
                                                            Colors.black26,
                                                        fontSize: 12),
                                              ),
                                            ],
                                          ),
                                          (!items[index]
                                                  .players
                                                  .contains(user.uid))
                                              ? RaisedButton(
                                                  onPressed: () {
                                                    showChooseTeamDialog(
                                                        context, index);
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  color: Colors.blueGrey,
                                                  child: new Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.arrow_forward,
                                                        color: Colors.white,
                                                      ),
                                                      new Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8.0,
                                                                  right: 8.0),
                                                          child: new Text(
                                                            "GO",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )),
                                                    ],
                                                  ),
                                                )
                                              : RaisedButton(
                                                  onPressed: () {
                                                    toQueue(
                                                        context,
                                                        user,
                                                        gameName,
                                                        snaps[index]
                                                            .documentID);
                                                  },
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5.0),
                                                  ),
                                                  color: Colors.blueGrey,
                                                  child: new Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: <Widget>[
                                                      Icon(
                                                        Icons.arrow_forward,
                                                        color: Colors.white,
                                                      ),
                                                      new Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 8.0,
                                                                  right: 8.0),
                                                          child: new Text(
                                                            "See status",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          )),
                                                    ],
                                                  ),
                                                ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void toQueue(BuildContext context, FirebaseUser user, String gameName,
    String documentId) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PlayGamePage(
              user: user, gameName: gameName, documentId: documentId),
          fullscreenDialog: true));
}

void toCreateQueue(BuildContext context, FirebaseUser user, String gameName) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateQueue(user: user, gameName: gameName),
          fullscreenDialog: true));
}

void toQrCode(BuildContext context, String documentId, String gameName) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => QrCodeGenPage(documentId, gameName),
          fullscreenDialog: true));
}
