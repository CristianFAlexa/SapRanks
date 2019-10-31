import 'dart:async';

import 'package:bored/model/GameModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/component/ProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'component/ChallengePage.dart';
import 'component/CreateGamePage.dart';
import 'component/EditGamePage.dart';
import 'component/PlayGamePage.dart';

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

  bool checkSubscription(String userId, String gameId) {
    bool subscription = false;
    gamesEnrolmentCollectionReference.document(gameId).get().then((snaps) {
      print(snaps.data);
      if (snaps.data != null && snaps.data.toString().contains(userId)) {
        subscription = true;
      }
    });
    return subscription;
  }

  onPlayGame(BuildContext context, String userId, String gameId) {
    // todo : figure out games enrolment shit
//    await gamesEnrolmentCollectionReference.document(gameId).get().then((snap) async {
//      setState(() {
//        gamesEnrolment = new List<String>.from(snap.data['user_id']);
//        gamesEnrolment.add(userId);
//        gamesEnrolmentCollectionReference
//            .document(gameId)
//            .setData({'user_id': FieldValue.arrayUnion(gamesEnrolment)});
//      });
//    });

    usersEnrolment.add(gameId);
    usersEnrolmentCollectionReference
        .document(userId)
        .setData({'game_id': FieldValue.arrayUnion(usersEnrolment)});
  }

  showDeleteDialog(BuildContext context, DocumentReference gameReference) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(20.0)), // RoundedRectangleBorder,
              title: Text(
                "Are you sure that you want to delete this game?",
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    "Delete",
                    style: TextStyle(fontWeight: FontWeight.bold),
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

  Future deleteGame(
      BuildContext context, DocumentReference gameReference) async {
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
        usersEnrolment = new List<String>.from(snap.data['game_id']);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();

    return Scaffold(
      appBar: GradientAppBar(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.black38, Colors.black12]),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          StreamBuilder(
              stream: collectionReference.document(user.uid).snapshots(),
              builder: (context, snapshot) {
                return (snapshot.data == null)
                    ? Text("Loading..")
                    : Container(
                        child: Row(
                        children: <Widget>[
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
                          IconButton(
                            icon: Icon(
                              FontAwesomeIcons.solidPlayCircle,
                              size: 20.0,
                              color: Colors.white,
                            ),
                            onPressed: () => toChallenge(context),
                          ),
                          IconButton(
                            icon: Icon(
                              FontAwesomeIcons.userAlt,
                              size: 20.0,
                              color: Colors.white,
                            ),
                            onPressed: () => toProfile(context, user),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.settings,
                              size: 20.0,
                              color: Colors.white,
                            ),
                            onPressed: toSettings,
                          ),
                          IconButton(
                            icon: Icon(
                              FontAwesomeIcons.signOutAlt,
                              size: 20.0,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _gSignIn.signOut();
                              print('Signed out.');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ));
              }),
        ],
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
              height: 10,
            ),
            (_editGameState)
                ? SignInButtonBuilder(
                    text: 'Create game',
                    icon: Icons.library_add,
                    onPressed: () => toCreateGamePage(context),
                    backgroundColor: Colors.blueGrey[900],
                  )
                : SizedBox(),
            (usersEnrolment==null)? Text("Loading"):
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
                              height: 175.0,
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
                                            gameItems[index].picture),
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
                                                  "${gameItems[index].name}",
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
                                                Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Text(
                                                      "${gameItems[index].players}",
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .display1
                                                          .copyWith(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              backgroundColor:
                                                                  Colors
                                                                      .black26),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            (!usersEnrolment.contains(
                                                    gameItems[index].uid))
                                                ? RaisedButton(
                                                    onPressed: () {
                                                      onPlayGame(
                                                          context,
                                                          user.uid,
                                                          gameItems[index].uid);
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
                                                      List<String> players;
                                                      queueCollectionReference
                                                          .document(
                                                              gameItems[index]
                                                                  .name)
                                                          .get()
                                                          .then((snap) {
                                                        setState(() {
                                                          players = new List<
                                                                  String>.from(
                                                              snap.data[
                                                                  'players']);
                                                          players.add(user.uid);
                                                        });
                                                        queueCollectionReference
                                                            .document(
                                                                gameItems[index]
                                                                    .name)
                                                            .updateData({
                                                          'players': FieldValue
                                                              .arrayUnion(
                                                                  players)
                                                        });
                                                        toPlayGame(
                                                            context,
                                                            user,
                                                            gameItems[index]
                                                                .name);
                                                      });
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
          builder: (context) => PlayGamePage(user: user, gameName: gameName),
          fullscreenDialog: true));
}

void toProfile(BuildContext context, FirebaseUser user) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfilePage(user: user),
          fullscreenDialog: true));
}

void toSettings() {
  //  Navigator.push(
  //      context,
  //      MaterialPageRoute(
  //          builder: (context) => SettingsPage(),
  //          fullscreenDialog: true));
}

void toChallenge(BuildContext context) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChallengePage(), fullscreenDialog: true));
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
