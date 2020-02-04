import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/component/PlayPage.dart';
import 'package:bored/view/widget/Cutout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../setup/MainPage.dart';

class PlayGamePage extends StatefulWidget {
  PlayGamePage({this.user, this.gameName, this.document, this.gameDetails});

  final DocumentSnapshot document;
  final FirebaseUser user;
  final String gameName;
  final DocumentSnapshot gameDetails;

  @override
  _PlayGamePageState createState() => _PlayGamePageState(user: user, gameName: gameName, document: document, gameDetails: gameDetails);
}

class _PlayGamePageState extends State<PlayGamePage> {
  _PlayGamePageState({this.user, this.gameName, this.document, this.gameDetails});

  var time = new Duration();
  final DocumentSnapshot document;
  final FirebaseUser user;
  final String gameName;
  final DocumentSnapshot gameDetails;

  var disputeWin;
  var disputeLoss;
  var xp;

  void removeUserFromList(String listName) async {
    await queueCollectionReference.document(gameName).collection('active').document(document.documentID).updateData({
      listName: FieldValue.arrayRemove([user.uid])
    });
  }

  void showChooseWinnerDialog(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // RoundedRectangleBorder,
              title: Text(
                "Who won?",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    "Blue team",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  onPressed: () {
                    List<String> bluePlayers = new List<String>();
                    List<String> redPlayers = new List<String>();
                    queueCollectionReference.document(gameName).collection('active').document(document.documentID).get().then((snap) {
                      if (!mounted) return;
                      setState(() {
                        bluePlayers = new List<String>.from(snap.data['blue_team']);
                        redPlayers = new List<String>.from(snap.data['red_team']);
                        bluePlayers.forEach((player) => {
                              if (player != null)
                                {
                                  collectionReference.document(player).get().then((blue) {
                                    disputeWin = blue.data['dispute_win'] + 1;
                                    xp = blue.data['xp'] + gameDetails.data['xp'];
                                  }).then((function) {
                                    collectionReference.document(player).updateData({
                                      'history': FieldValue.arrayUnion(["$gameName win ${Timestamp.now()}"]),
                                      'xp': xp,
                                      'dispute_win': disputeWin
                                    });
                                  })
                                }
                            });
                        redPlayers.forEach((player) => {
                              if (player != null)
                                {
                                  collectionReference.document(player).get().then((red) {
                                    disputeLoss = red.data['dispute_loss'] + 1;
                                  }).then((function) {
                                    collectionReference.document(player).updateData({
                                      'history': FieldValue.arrayUnion(["$gameName lose ${Timestamp.now()}"]),
                                      'dispute_loss': disputeLoss
                                    });
                                  })
                                }
                            });
                        queueCollectionReference.document(gameName).collection('active').document(document.documentID).updateData({'settled': true});
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlayPage(
                                      user: user,
                                    )));
                      });
                    });
                  },
                ),
                FlatButton(
                  child: Text(
                    "Green team",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                  ),
                  onPressed: () {
                    List<String> bluePlayers = new List<String>();
                    List<String> redPlayers = new List<String>();
                    queueCollectionReference.document(gameName).collection('active').document(document.documentID).get().then((snap) {
                      if (!mounted) return;
                      setState(() {
                        bluePlayers = new List<String>.from(snap.data['blue_team']);
                        redPlayers = new List<String>.from(snap.data['red_team']);
                        bluePlayers.forEach((player) => {
                              if (player != null)
                                {
                                  collectionReference.document(player).get().then((blue) {
                                    disputeLoss = blue.data['dispute_loss'] + 1;
                                  }).then((function) {
                                    collectionReference.document(player).updateData({
                                      'history': FieldValue.arrayUnion(["$gameName lose ${Timestamp.now()}"]),
                                      'dispute_loss': disputeLoss
                                    });
                                  })
                                }
                            });
                        redPlayers.forEach((player) => {
                              if (player != null)
                                {
                                  collectionReference.document(player).get().then((red) {
                                    disputeWin = red.data['dispute_win'] + 1;
                                    xp = red.data['xp'] + gameDetails.data['xp'];
                                  }).then((function) {
                                    collectionReference.document(player).updateData({
                                      'history': FieldValue.arrayUnion(["$gameName win ${Timestamp.now()}"]),
                                      'xp': xp,
                                      'dispute_win': disputeWin
                                    });
                                  })
                                }
                            });
                        queueCollectionReference.document(gameName).collection('active').document(document.documentID).updateData({'settled': true});
                        Navigator.of(context).pop();
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PlayPage(
                                      user: user,
                                    )));
                      });
                    });
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
                            stream: collectionReference.document(item).snapshots(),
                            builder: (context, snapshot) {
                              return (snapshot.data == null)
                                  ? SizedBox()
                                  : Padding(
                                      padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                                          image: (snapshot.data['profile_picture'] == null)
                                                              ? AssetImage("assets/images/default-profile-picture.png")
                                                              : NetworkImage(snapshot.data['profile_picture']))),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 10),
                                                  child: Text(
                                                    "${snapshot.data['name']}",
                                                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                  ),
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

  void changeTeam(String teamName) async {
    if (teamName == 'red_team') {
      removeUserFromList('blue_team');
    } else if (teamName == 'blue_team') {
      removeUserFromList('red_team');
    }
    await queueCollectionReference.document(gameName).collection('active').document(document.documentID).updateData({
      teamName: FieldValue.arrayUnion([user.uid])
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: queueCollectionReference.document(gameName).collection('active').document(document.documentID).snapshots(),
        builder: (context, snapshot) {
          return (snapshot.data == null || !snapshot.data.exists)
              ? CircularProgressIndicator()
              : Scaffold(
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
                              child: Stack(
                                children: <Widget>[
                                  FlatButton(
                                    onPressed: (){
                                      Navigator.of(context).pop();
                                    },
                                    child: Icon(Icons.arrow_back, color: Colors.white, size: 28,),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(Icons.people, color: Colors.white, size: 20,),
                                      Padding(
                                        padding: const EdgeInsets.only(right: 10),
                                        child: Text(
                                          "${snapshot.data['players'].length}-${snapshot.data['max_players']}",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white
                                          ),
                                        ),
                                      ),
                                      Container(
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 10, right: 10),
                                          child: Container(
                                            height: 60,
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: <Widget>[
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                                                  child: Center(
                                                    child: ClipRRect(
                                                      borderRadius: BorderRadius.circular(3),
                                                      child: Cutout(
                                                        color: Colors.white,
                                                        child: Image.asset('assets/images/rsz_spacemandraw.png'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 10, right: 10),
                                        child: Text('${gameDetails.data['name']}',
                                          style: TextStyle(fontSize: 15, color: Colors.white), maxLines: 4, softWrap: true,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
                          ),
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10, top: 15, left: 20),
                                child: Text('${gameDetails.data['name']}, Event', style: TextStyle( fontSize: 20, color: Colors.grey[700]),),
                              )
                            ],
                          ),
                        ),
                        Container(
                          color: Colors.white,
                          child: ListView(
                            physics: ClampingScrollPhysics(),
                            scrollDirection: Axis.vertical,
                            shrinkWrap: true,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () => {if (!snapshot.data['event_date'].toDate().difference(Timestamp.now().toDate()).isNegative) changeTeam('red_team')},
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                          ),
                                          gradient: LinearGradient(begin: Alignment.topCenter, colors: [Colors.green[200], Colors.green[500], Colors.green[800]])),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              'Green team',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            getTextWidgets(snapshot.data['red_team']),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Text(
                                        "VS",
                                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => {if (!snapshot.data['event_date'].toDate().difference(Timestamp.now().toDate()).isNegative) changeTeam('blue_team')},
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            bottomLeft: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                          ),
                                          gradient: LinearGradient(end: Alignment.topCenter, colors: [Colors.blue[200], Colors.blue[500], Colors.blue[800]])),
                                        child: Column(
                                          children: <Widget>[
                                            Text(
                                              'Blue team',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            getTextWidgets(snapshot.data['blue_team']),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: (!snapshot.data['event_date'].toDate().difference(Timestamp.now().toDate()).isNegative)
                                             ? Column(
                                        children: <Widget>[
                                          CountdownFormatted(
                                            duration: snapshot.data['event_date'].toDate().difference(snapshot.data['created_at'].toDate()),
                                            builder: (BuildContext ctx, String remaining) {
                                              return Text(
                                                "Game starts in $remaining",
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                                              );
                                            },
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: FloatingActionButton(
                                                heroTag: "floatingButton4",
                                                onPressed: () => {
                                                  removeUserFromList('red_team'),
                                                  removeUserFromList('blue_team'),
                                                  removeUserFromList('players'),
                                                  Navigator.of(context).pop()
                                                },
                                                child: Icon(Icons.exit_to_app),
                                                backgroundColor: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                             : (snapshot.data['creator'] == user.uid && snapshot.data['settled'] == false)
                                               ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Align(
                                          alignment: Alignment.bottomRight,
                                          child: FloatingActionButton(
                                            heroTag: "floatingButton5",
                                            onPressed: () => {
                                              showChooseWinnerDialog(context),
                                            },
                                            child: Icon(Icons.thumbs_up_down),
                                            backgroundColor: Colors.green[700],
                                          ),
                                        ),
                                      )
                                               : Text("Event no longer available!"),
                                    ),
                                    Stack(
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Align(
                                            alignment: Alignment.bottomRight,
                                            child: FloatingActionButton(
                                              heroTag: "floatingButton3",
                                              onPressed: () =>
                                              {Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage(user: user), fullscreenDialog: true))},
                                              child: Icon(Icons.home),
                                              backgroundColor: Colors.blueGrey[900],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              Container(
                                height: 250,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          );
        });
  }
}

