import 'dart:async';

import 'package:bored/model/QueueModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/component/CreateQueue.dart';
import 'package:bored/view/setup/MainPage.dart';
import 'package:bored/view/component/QrCodeGenPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'PlayGamePage.dart';

class GamePage extends StatefulWidget {
  GamePage({this.user, this.gameDetails});

  final FirebaseUser user;
  final DocumentSnapshot gameDetails;

  @override
  _GamePageState createState() => _GamePageState(user: user, gameDetails: gameDetails);
}

class _GamePageState extends State<GamePage> {
  _GamePageState({this.user, this.gameDetails});

  final FirebaseUser user;
  final DocumentSnapshot gameDetails;

  List<QueueModel> items;
  StreamSubscription<QuerySnapshot> queues;
  DatabaseService databaseService = new DatabaseService();
  List<DocumentSnapshot> snaps;

  @override
  void initState() {
    items = new List();
    queues?.cancel();
    queues = queueCollectionReference.document(gameDetails.data['name']).collection('active').snapshots().listen((QuerySnapshot snapshot) {
      if (!mounted) {
        return;
      }
      final List<DocumentSnapshot> queueSnaps = snapshot.documents;
      final List<QueueModel> queueModels = snapshot.documents.map((documentSnapshot) => QueueModel.fromMap(documentSnapshot.data)).toList();
      setState(() {
        snaps = queueSnaps;
        this.items = queueModels;
      });
    });
    super.initState();
  }

  void addUserToList(int index, String listName) {
    List<String> players;
    queueCollectionReference.document(gameDetails.data['name']).collection('active').document(snaps[index].documentID).get().then((snap) {
      if (!mounted) {
        return;
      }
      setState(() {
        var tmpList = new List<String>.from(snap.data[listName]);
        tmpList.removeWhere((item) => item == null);
        players = tmpList;
        players.add(user.uid);
      });
      queueCollectionReference
          .document(gameDetails.data['name'])
          .collection('active')
          .document(snaps[index].documentID)
          .updateData({listName: FieldValue.arrayUnion(players)});
      toQueue(context, user, gameDetails.data['name'], snaps[index], gameDetails);
    });
  }

  void showChooseTeamDialog(BuildContext context, int index) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          //Here we will build the content of the dialog
          return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // RoundedRectangleBorder,
              title: Text(
                "Choose a team",
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
              actions: <Widget>[
                FlatButton(
                  child: Text(
                    "Blue team",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  onPressed: () {
                    addUserToList(index, 'players');
                    addUserToList(index, 'blue_team');
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text(
                    "Green team",
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
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
      resizeToAvoidBottomPadding: true,
      appBar: GradientAppBar(
        title: Text(
          "${gameDetails.data['name']} events",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black, Colors.black]),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage(user: user), fullscreenDialog: true));
            },
            icon: Icon(Icons.home),
          )
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
                  return (snaps[index] == null)
                      ? SizedBox()
                      : GestureDetector(
                          onDoubleTap: () => toQrCode(context, snaps[index].documentID, gameDetails.data['name']),
                          onTap: () {
                            if (!items[index].players.contains(user.uid))
                              showChooseTeamDialog(context, index);
                            else
                              toQueue(context, user, gameDetails.data['name'], snaps[index], gameDetails);
                          },
                          onLongPress: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                content: ListTile(
                                  title: Text("Are you sure you want to delete the event?"),
                                ),
                                actions: <Widget>[
                                  FlatButton(
                                    child: Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () => {
                                      if (snaps[index].data['creator'] == user.uid)
                                        queueCollectionReference
                                            .document(gameDetails.data['name'])
                                            .collection('active')
                                            .document(snaps[index].documentID)
                                            .delete(),
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Column(
                            children: <Widget>[
                              Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(gameDetails.data['picture']),
                                  ),
                                ),
                                height: MediaQuery.of(context).size.height / 3.5,
                              ),
                              Container(
                                color: Colors.blueGrey[900],
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Text(
                                            "${gameDetails.data['name']}",
                                            style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                          ),
                                          SizedBox(
                                            width: 25,
                                          ),
                                          Text(
                                            "${gameDetails.data['xp']} ",
                                            style: TextStyle(color: Colors.white, fontSize: 16),
                                          ),
                                          Icon(
                                            Icons.star,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            "Description: ${items[index].description}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .display1
                                                .copyWith(color: Colors.white, fontWeight: FontWeight.bold, backgroundColor: Colors.black26, fontSize: 12),
                                          ),
                                          Icon(
                                            Icons.description,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            "Location: ${items[index].location}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .display1
                                                .copyWith(color: Colors.white, fontWeight: FontWeight.bold, backgroundColor: Colors.black26, fontSize: 12),
                                          ),
                                          Icon(
                                            Icons.location_on,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            "Date: ${items[index].eventDate.toDate()}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .display1
                                                .copyWith(color: Colors.white, fontWeight: FontWeight.bold, backgroundColor: Colors.black26, fontSize: 12),
                                          ),
                                          Icon(
                                            Icons.date_range,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Text(
                                            "Players enrolled ${items[index].players.length}",
                                            style: Theme.of(context)
                                                .textTheme
                                                .display1
                                                .copyWith(color: Colors.white, fontWeight: FontWeight.bold, backgroundColor: Colors.black26, fontSize: 12),
                                          ),
                                          Icon(
                                            Icons.people,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ],
                                      ),
                                    ],
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
      floatingActionButton: FloatingActionButton(
        heroTag: "floatingButton2",
        onPressed: () => toCreateQueue(context, user, gameDetails.data['name']),
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
    );
  }
}

void toQueue(BuildContext context, FirebaseUser user, String gameName, DocumentSnapshot document, DocumentSnapshot gameDetails) {
  Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayGamePage(user: user, gameName: gameName, document: document, gameDetails: gameDetails),
      ));
}

void toCreateQueue(BuildContext context, FirebaseUser user, String gameName) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateQueue(user: user, gameName: gameName), fullscreenDialog: true));
}

void toQrCode(BuildContext context, String documentId, String gameName) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeGenPage(documentId, gameName), fullscreenDialog: true));
}
