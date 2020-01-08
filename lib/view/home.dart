import 'dart:async';

import 'package:bored/model/GameModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'component/CreateGamePage.dart';
import 'component/EditGamePage.dart';
import 'component/GamePage.dart';

class Home extends StatefulWidget {
  const Home({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _HomeState createState() => _HomeState(user: user);
}

class _HomeState extends State<Home> {
  _HomeState({this.user});

  FirebaseUser user;

  DatabaseService databaseService = new DatabaseService();
  List<GameModel> gameItems;
  List<DocumentSnapshot> snaps;
  StreamSubscription<QuerySnapshot> games;

  List<String> gamesEnrolment;
  List<String> usersEnrolment;

  bool _editGameState = false;

  List<bool> subscribedList = List();

  Future<bool> checkSubscription(String userId, String gameId) async {
    bool subscription = false;
    gamesEnrolmentCollectionReference.document(gameId).get().then((snaps) {
      print(snaps.data);
      if (snaps.data != null && snaps.data.toString().contains(userId)) {
        subscription = true;
      }
    });
    return subscription;
  }

  void onPlayGame(BuildContext context, String userId, String gameId) {
    usersEnrolment.add(gameId);
    usersEnrolmentCollectionReference
        .document(userId)
        .setData({'game_id': FieldValue.arrayUnion(usersEnrolment)});
  }

  void showDeleteDialog(BuildContext context, DocumentReference gameReference) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10)), // RoundedRectangleBorder,
              title: Text(
                "Are you sure that you want to delete this game?",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              actions: <Widget>[
                FlatButton(
                  padding: EdgeInsets.only(left: 8.0, right: 135.0),
                  child: Text(
                    "Delete",
                    style: TextStyle(fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red),
                  ),
                  onPressed: () => {deleteGame(context, gameReference)},
                )
              ]);
        });
  }

  Future setEditGameState(bool state) async {
    setState(() {
      _editGameState = !_editGameState;
    });
  }

  Future deleteGame(BuildContext context, DocumentReference gameReference) async {
    await Firestore.instance.runTransaction((Transaction myTransaction) async {
      await myTransaction.delete(gameReference);
    });
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();

    gameItems = new List();
    snaps = new List();

    games?.cancel();
    games = databaseService.getGamesList().listen((QuerySnapshot snapshot) {
      final snapDocs = snapshot.documents;
      final List<GameModel> gameModels = snapDocs
          .map((documentSnapshot) => GameModel.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        this.gameItems = gameModels;
        this.snaps = snapDocs;
      });
    });

    usersEnrolmentCollectionReference.document(user.uid).get().then((snap) {
      setState(() {
        if (snap.data != null)
          usersEnrolment = new List<String>.from(snap.data['game_id']);
        else
          usersEnrolment = new List<String>();
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: GradientAppBar(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors:  [Colors.blueGrey[900], Colors.blueGrey[900] ]),
        automaticallyImplyLeading: true,
        actions: <Widget>[
          StreamBuilder(
              stream: collectionReference.document(user.uid).snapshots(),
              builder: (context, snapshot) {
                return (snapshot.data == null)
                    ? Text("Loading..")
                    : Container(
                        child: Row(
                        children: <Widget>[
                          (_editGameState)
                              ? SignInButtonBuilder(
                            text: 'Create game',
                            icon: Icons.library_add,
                            onPressed: () => toCreateGamePage(context),
                            backgroundColor: Colors.blueGrey[900],
                          )
                              : SizedBox(),
                          (snapshot.data['role'] == "admin")
                              ? IconButton(
                                  icon: Icon(
                                    Icons.games,
                                    size: 20.0,
                                    color: Colors.white,
                                  ),
                                  onPressed: () =>
                                      setEditGameState(_editGameState),
                                )
                              : SizedBox(),
                        ],
                      ));
              }),
        ],
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 80,
                child: ListView.builder(
                  itemCount: gameItems.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      child: Stack(
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: 250,
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
                                        image: NetworkImage(
                                            snaps[index].data['picture']),
                                      ),
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Column(
                                          children: <Widget>[
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                Text(
                                                  "${snaps[index].data['name']}",
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
                                                (_editGameState)
                                                    ? Row(
                                                        children: <Widget>[
                                                          Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Container(
                                                                child:
                                                                    IconButton(
                                                              onPressed: () =>
                                                                  showDeleteDialog(
                                                                      context,
                                                                      snaps[index]
                                                                          .reference),
                                                              icon: Icon(
                                                                Icons.delete,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            )),
                                                          ),
                                                          Align(
                                                            alignment: Alignment
                                                                .centerRight,
                                                            child: Container(
                                                                child:
                                                                    IconButton(
                                                              onPressed: () =>
                                                                  toEditGamePage(
                                                                      context,
                                                                      snaps[
                                                                          index]),
                                                              icon: Icon(
                                                                Icons.edit,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            )),
                                                          ),
                                                        ],
                                                      )
                                                    : SizedBox(),
                                              ],
                                            ),
                                            (usersEnrolment == null ||
                                                    !usersEnrolment.contains(
                                                        snaps[index].data['uid']))
                                                ? RaisedButton(
                                                    onPressed: () {
                                                      onPlayGame(
                                                          context,
                                                          user.uid,
                                                          snaps[index].data['uid']);
                                                    },
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                    color: Color.fromRGBO(
                                                        100, 100, 100, 0.5),
                                                    child: new Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        Icon(
                                                          Icons.subscriptions,
                                                          color: Colors.white,
                                                        ),
                                                        new Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10.0,
                                                                    right:
                                                                        10.0),
                                                            child: new Text(
                                                              "Subscribe",
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
                                                      toPlayGame(
                                                          context,
                                                          user,
                                                          snaps[index].data['name']);
                                                    },
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                    ),
                                                    color: Color.fromRGBO(
                                                        100, 100, 100, 0.5),
                                                    child: new Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: <Widget>[
                                                        Icon(
                                                          FontAwesomeIcons
                                                              .googlePlay,
                                                          color: Colors.white,
                                                        ),
                                                        new Container(
                                                            padding:
                                                                EdgeInsets.only(
                                                                    left: 10.0,
                                                                    right:
                                                                        10.0),
                                                            child: new Text(
                                                              "Play game",
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
      ),
    );
  }
}

void toPlayGame(BuildContext context, FirebaseUser user, String gameName) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => GamePage(user: user, gameName: gameName),
          fullscreenDialog: true));
}

void toEditGamePage(BuildContext context, DocumentSnapshot documentSnapshot) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditGamePage(
                documentSnapshot: documentSnapshot,
              ),
          fullscreenDialog: true));
}

void toCreateGamePage(BuildContext context) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CreateGamePage(), fullscreenDialog: true));
}
