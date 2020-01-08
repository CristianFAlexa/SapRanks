import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/component/GamePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class PlayGamePage extends StatefulWidget {
  PlayGamePage({this.user, this.gameName, this.documentId});

  final String documentId;
  final FirebaseUser user;
  final String gameName;

  @override
  _PlayGamePageState createState() => _PlayGamePageState(
      user: user, gameName: gameName, documentId: documentId);
}

class _PlayGamePageState extends State<PlayGamePage> {
  _PlayGamePageState({this.user, this.gameName, this.documentId});

  var time = new Duration();
  final String documentId;
  final FirebaseUser user;
  final String gameName;

  void removeUserFromList(String listName) async {
    await queueCollectionReference
        .document(gameName)
        .collection('active')
        .document(documentId)
        .updateData({
      listName: FieldValue.arrayRemove([user.uid])
    });
  }

  void showChooseWinnerDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10)), // RoundedRectangleBorder,
              title: Text(
                "Who won?",
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
                    List<String> bluePlayers = new List<String>();
                    List<String> redPlayers = new List<String>();
                    queueCollectionReference
                        .document(gameName)
                        .collection('active')
                        .document(documentId)
                        .get()
                        .then((snap) {
                      setState(() {
                        bluePlayers =
                            new List<String>.from(snap.data['blue_team']);
                        redPlayers =
                            new List<String>.from(snap.data['red_team']);
                        bluePlayers.forEach((player) => {
                          collectionReference.document(player).updateData({
                            'history': FieldValue.arrayUnion(["$gameName win"])
                          })
                        });
                        redPlayers.forEach((player) => {
                          collectionReference.document(player).updateData({
                            'history': FieldValue.arrayUnion(["$gameName lose"])
                          })
                        });
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GamePage(
                                  gameName: gameName, user: user,
                                ),
                                fullscreenDialog: true));
                      });
                    });
                    queueCollectionReference
                        .document(gameName)
                        .collection('active')
                        .document(
                        documentId)
                        .delete();

                  },
                ),
                FlatButton(
                  child: Text(
                    "Red team",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  onPressed: () {
                    List<String> bluePlayers = new List<String>();
                    List<String> redPlayers = new List<String>();
                    queueCollectionReference
                        .document(gameName)
                        .collection('active')
                        .document(documentId)
                        .get()
                        .then((snap) {
                      setState(() {
                        bluePlayers =
                        new List<String>.from(snap.data['blue_team']);
                        redPlayers =
                        new List<String>.from(snap.data['red_team']);
                        bluePlayers.forEach((player) => {
                          collectionReference.document(player).updateData({
                            'history': FieldValue.arrayUnion(["$gameName lose"])
                          })
                        });
                        redPlayers.forEach((player) => {
                          collectionReference.document(player).updateData({
                            'history': FieldValue.arrayUnion(["$gameName win"])
                          })
                        });
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GamePage(
                                  gameName: gameName, user: user,
                                ),
                                fullscreenDialog: true));
                      });
                    });
                    queueCollectionReference
                        .document(gameName)
                        .collection('active')
                        .document(
                        documentId)
                        .delete();
                  },
                )
              ]);
        });
  }

  Widget getTextWidgets(List<dynamic> strings) {
    return new Column(
        children: strings
            .map((item) => Row(
                  children: <Widget>[
                    (item == null)
                        ? SizedBox()
                        : StreamBuilder(
                            stream:
                                collectionReference.document(item).snapshots(),
                            builder: (context, snapshot) {
                              return (snapshot.data == null)
                                  ? SizedBox()
                                  : Padding(
                                      padding: EdgeInsets.only(
                                          top: 8.0, bottom: 8.0),
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
                                                              : NetworkImage(
                                                                  snapshot.data[
                                                                      'profile_picture']))),
                                                ),
                                                Text(
                                                  "   ${snapshot.data['name']}",
                                                  style:
                                                      TextStyle(fontSize: 12.0),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                            },
                          ),
                  ],
                ))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: queueCollectionReference
            .document(gameName)
            .collection('active')
            .document(documentId)
            .snapshots(),
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
                    automaticallyImplyLeading: true,
                  ),
                  body: Container(
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Text(
                            "${snapshot.data['players'].length}/${snapshot.data['max_players']} players",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.black))),
                        ),
                        Text('Blue team'),
                        getTextWidgets(snapshot.data['blue_team']),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.black))),
                        ),
                        Text('Red team'),
                        getTextWidgets(snapshot.data['red_team']),
                        Container(
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(color: Colors.black))),
                        ),
                        SizedBox(
                          height: 50,
                        ),
                        Center(
                          child: (!snapshot.data['event_date']
                                  .toDate()
                                  .difference(Timestamp.now().toDate())
                                  .isNegative) ?

                          Column( children: <Widget>[
                           CountdownFormatted(
                                  duration: snapshot.data['event_date']
                                      .toDate()
                                      .difference(
                                          snapshot.data['created_at'].toDate()),
                                  builder:
                                      (BuildContext ctx, String remaining) {
                                    return Text(
                                      "Game starts in $remaining",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 25),
                                    );
                                  },
                                ),
                            RaisedButton(
                              onPressed: () => {
                                removeUserFromList('red_team'),
                                removeUserFromList('blue_team'),
                                removeUserFromList('players'),
                                Navigator.of(context).pop()
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              color: Colors.blueGrey,
                              child: new Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Icon(
                                    Icons.accessible_forward,
                                    color: Colors.white,
                                  ),
                                  new Container(
                                      padding:
                                      EdgeInsets.only(left: 8.0, right: 8.0),
                                      child: new Text(
                                        "Leave event",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      )),
                                ],
                              ),
                            ),
                          ],)
                              : (snapshot.data['creator'] == user.uid)
                                  ? RaisedButton(
                                      onPressed: () => {
                                        showChooseWinnerDialog(context),
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      color: Colors.blueGrey,
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Icon(
                                            Icons.close,
                                            color: Colors.white,
                                          ),
                                          new Container(
                                              padding: EdgeInsets.only(
                                                  left: 8.0, right: 8.0),
                                              child: new Text(
                                                "Delete event",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              )),
                                        ],
                                      ),
                                    )
                                  : Text("Game has been started"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                );
        });
  }
}
