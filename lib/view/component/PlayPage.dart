import 'dart:async';

import 'package:bored/model/GameModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'CreateGamePage.dart';
import 'EditGamePage.dart';
import 'GamePage.dart';

class PlayPage extends StatefulWidget {
  const PlayPage({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _PlayPageState createState() => _PlayPageState(user: user);
}

class _PlayPageState extends State<PlayPage> {
  _PlayPageState({this.user});

  FirebaseUser user;

  DatabaseService databaseService = new DatabaseService();
  List<GameModel> gameItems;
  List<DocumentSnapshot> snaps;
  StreamSubscription<QuerySnapshot> games;

  List<String> gamesEnrolment;
  List<String> usersEnrolment;

  bool _editGameState = false;

  List<bool> subscribedList = List();

  Future<RaisedButton> checkSubscription(int index) async {
    await usersEnrolmentCollectionReference.document(user.uid).get().then((snap) {
      setState(() {
        if (snap.data != null)
          usersEnrolment = new List<String>.from(snap.data['game_id']);
        else
          usersEnrolment = new List<String>();
      });
      // ignore: missing_return
    });
    if (usersEnrolment != null && usersEnrolment.contains(snaps[index].data['uid']))
      return RaisedButton(
        onPressed: () {
          toPlayGame(
            context,
            user,
            snaps[index],
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: Color.fromRGBO(100, 100, 100, 0.5),
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.play_circle_filled,
              color: Colors.white,
            ),
            new Container(
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: new Text(
                  "Play game",
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                )),
          ],
        ),
      );
    return RaisedButton(
      onPressed: () => {
        onPlayGame(context, user.uid, snaps[index]),
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      color: Color.fromRGBO(100, 100, 100, 0.5),
      child: new Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.subscriptions,
            color: Colors.white,
          ),
          new Container(
              padding: EdgeInsets.only(left: 10.0, right: 10.0),
              child: new Text(
                "Subscribe",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
        ],
      ),
    );
  }

  void onPlayGame(BuildContext context, String userId, DocumentSnapshot game) {
    final FirebaseMessaging _fcm = FirebaseMessaging();
    _fcm.subscribeToTopic(game.data['name']);
    usersEnrolment.add(game.data['uid']);
    usersEnrolmentCollectionReference.document(userId).setData({'game_id': FieldValue.arrayUnion(usersEnrolment)});
  }

  void showDeleteDialog(BuildContext context, DocumentReference gameReference) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // RoundedRectangleBorder,
              title: Text(
                "Are you sure that you want to delete this game?",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              actions: <Widget>[
                FlatButton(
                  padding: EdgeInsets.only(left: 8.0, right: 135.0),
                  child: Text(
                    "Delete",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
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
      final List<GameModel> gameModels = snapDocs.map((documentSnapshot) => GameModel.fromMap(documentSnapshot.data)).toList();
      if (!mounted) return;
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
     resizeToAvoidBottomPadding: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color.fromRGBO(255, 90, 0, 1), Color.fromRGBO(236, 32, 77, 1)]),
        ),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 25, top: 20),
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: Row(
                    children: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Icon(
                        Icons.videogame_asset,
                        color: Colors.white,
                        size: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Text(
                          '${gameItems.length}',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                        ),
                      ),
                      Container(
                          decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.white), right: BorderSide(color: Colors.white))),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              'Choose Game',
                              style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                          )),
                     StreamBuilder(
                       stream: collectionReference.document(user.uid).snapshots(),
                       builder: (context, snapshot) {
                        return (snapshot.data == null)
                               ? CircularProgressIndicator()
                               : Container(
                          child: (snapshot.data['role'] == "admin")
                                 ? Row(
                           children: <Widget>[
                            IconButton(icon: Icon(Icons.games, size: 20, color: Colors.white,), onPressed: () => setEditGameState(_editGameState),),
                            Text(
                             'Admin',
                             style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                           ],
                          )
                                 : Row(
                           children: <Widget>[
                            Icon(Icons.person, size: 20, color: Colors.white,),
                            Text(
                             'User',
                             style: TextStyle(fontSize: 15, color: Colors.white),
                            ),
                           ],
                          )
                        );
                       }),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 15, left: 20),
                    child: Text(
                      'Games',
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                  )
                ],
              ),
            ),
            Container(
             color: Colors.white,
              child: ListView.builder(
               physics: ClampingScrollPhysics(),
               scrollDirection: Axis.vertical,
               shrinkWrap: true,
                itemCount: gameItems.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      toPlayGame(
                        context,
                        user,
                        snaps[index],
                      );
                    },
                    child: Stack(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                           children: <Widget>[
                            Container(
                             decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                               topLeft: Radius.circular(5),
                               topRight: Radius.circular(5),
                              ),
                              image: DecorationImage(
                               fit: BoxFit.fill,
                               image: NetworkImage(snaps[index].data['picture']),
                              ),
                             ),
                             height: MediaQuery.of(context).size.height / 3,
                             child: Center(
                              child: Padding(
                               padding: EdgeInsets.all(8.0),
                               child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                 Center(
                                  child: FutureBuilder<RaisedButton>(
                                   future: checkSubscription(index),
                                   builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                     return snapshot.data;
                                    } else if (snapshot.hasError) {
                                     return Text("${snapshot.error}");
                                    }
                                    return CircularProgressIndicator();
                                   },
                                  ),
                                 ),
                                ],
                               ),
                              ),
                             ),
                            ),
                            Container(
                             height: 50,
                             decoration:
                             BoxDecoration(
                               color: Colors.white,
                               boxShadow: [ BoxShadow(color: Colors.grey, offset: Offset(0,5), blurRadius: 5)]
                             ),
                             child: Row(
                              children: <Widget>[
                               SizedBox(
                                width: 25,
                               ),
                               Text(
                                "${snaps[index].data['name']}",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                               ),
                               Spacer(),
                               (_editGameState)
                               ? Row(
                                children: <Widget>[
                                 IconButton(
                                  onPressed: () => showDeleteDialog(context, snaps[index].reference),
                                  icon: Icon(
                                   Icons.delete,
                                  ),
                                 ),
                                 IconButton(
                                  onPressed: () => toEditGamePage(context, snaps[index]),
                                  icon: Icon(
                                   Icons.edit,
                                  ),
                                 ),
                                ],
                               )
                               : SizedBox(),
                               Icon(
                                Icons.star,
                                color: Color.fromRGBO(236, 32, 77, 1),
                               ),
                               Text(
                                "${snaps[index].data['xp']} ",
                                style: TextStyle(color: Color.fromRGBO(236, 32, 77, 1), fontSize: 24, fontWeight: FontWeight.bold),
                               ),
                              ],
                             ),
                            ),
                           ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: (_editGameState)
          ? FloatingActionButton(
              onPressed: () => toCreateGamePage(context),
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
            )
          : null,
    );
  }
}

void toPlayGame(BuildContext context, FirebaseUser user, DocumentSnapshot gameDetails) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(user: user, gameDetails: gameDetails),
      ));
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
  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateGamePage(), fullscreenDialog: true));
}
