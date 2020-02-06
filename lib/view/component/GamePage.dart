import 'dart:async';

import 'package:bored/model/Constants.dart';
import 'package:bored/model/QueueModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/component/CreateEventPage.dart';
import 'package:bored/view/component/QrCodeGenPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
   MediaQueryData media = MediaQuery.of(context);
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Container(
       decoration: BoxDecoration(
        gradient: LinearGradient(colors: Constants.appColors),
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
                 onPressed: (){
                  Navigator.of(context).pop();
                 },
                 child: Icon(Icons.arrow_back, color: Colors.white, size: 28,),
                ),
                Icon(Icons.event, color: Colors.white, size: 20,),
                Padding(
                 padding: const EdgeInsets.only(right: 10),
                 child: Text('${items.length}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),),
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
               child: Text('${gameDetails.data['name']}, Events', style: TextStyle( fontSize: 20, color: Colors.grey[700]),),
              )
             ],
            ),
           ),
            Container(
              child: ListView.builder(
               physics: ClampingScrollPhysics(),
               scrollDirection: Axis.vertical,
               shrinkWrap: true,
               itemCount: items.length,
               itemBuilder: (context, index) {
                return (snaps[index] == null)
                       ? SizedBox()
                       : GestureDetector(
                 onTap: () {
                  if (!items[index].players.contains(user.uid))
                   showChooseTeamDialog(context, index);
                  else
                   toQueue(context, user, gameDetails.data['name'], snaps[index], gameDetails);
                 },
                 onLongPress: () {
                  if (snaps[index].data['creator'] == user.uid)
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
                        queueCollectionReference
                          .document(gameDetails.data['name'])
                          .collection('active')
                          .document(snaps[index].documentID)
                          .delete(),
                        Navigator.of(context).pop()
                       },
                      ),
                     ],
                    ),
                   );
                 },
                 child: Container(
                  color: Colors.white,
                   child: Padding(
                     padding: const EdgeInsets.all(5.0),
                     child: Column(
                      children: <Widget>[
                       Container(
                        decoration: BoxDecoration(
                         image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(gameDetails.data['picture']),
                         ),
                        ),
                        height: media.size.height / 3.5,
                       ),
                       Container(
                        child: Padding(
                         padding: const EdgeInsets.all(8.0),
                         child: Column(
                          children: <Widget>[
                           Row(
                            children: <Widget>[
                             Text(
                              "${gameDetails.data['name']}",
                              style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
                             ),
                             Spacer(),
                             Icon(
                              Icons.star,
                              color:  Constants.primaryColorLight,
                             ),
                             Text(
                              "${gameDetails.data['xp']}",
                              style: TextStyle(color:  Constants.primaryColorLight, fontWeight: FontWeight.bold, fontSize: 24),
                             ),
                            ],
                           ),
                           Row(
                            children: <Widget>[
                             Icon(
                              Icons.description,
                              color: Colors.grey,
                              size: 16,
                             ),
                             Text(
                              "${items[index].description}",
                              style: Theme.of(context)
                                .textTheme
                                .display1
                                .copyWith(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                             ),
                            ],
                           ),
                           Row(
                            children: <Widget>[
                             Icon(
                              Icons.location_on,
                              color: Colors.grey,
                              size: 16,
                             ),
                             Text(
                              "${items[index].location}",
                              style: Theme.of(context)
                                .textTheme
                                .display1
                                .copyWith(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                             ),
                            ],
                           ),
                           Row(
                            children: <Widget>[
                             Icon(
                              Icons.date_range,
                              color: Colors.grey,
                              size: 16,
                             ),
                             Text(
                              "${items[index].eventDate.toDate()}".substring(0,19),
                              style: Theme.of(context)
                                .textTheme
                                .display1
                                .copyWith(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                             ),
                             Padding(
                              padding: const EdgeInsets.only(left: 8, right: 8),
                              child: Icon(
                               Icons.stop,
                               color: Colors.grey,
                               size: 5,
                              ),
                             ),
                             Icon(
                              Icons.people,
                              color: Colors.grey,
                              size: 16,
                             ),
                             Text(
                              "${items[index].players.length}",
                              style: Theme.of(context)
                                .textTheme
                                .display1
                                .copyWith(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12),
                             ),
                             Spacer(),
                             InkWell(
                              onTap: () => toQrCode(context, snaps[index].documentID, gameDetails.data['name']),
                               child: Row(
                                children: <Widget>[
                                  Icon(FontAwesomeIcons.share, color: Colors.grey, size: 20,),
                                 Text(' SHARE', style: TextStyle(color: Colors.grey),)
                                ],
                               ),
                             ),
                            ],
                           ),
                          ],
                         ),
                        ),
                        decoration: BoxDecoration(
                         color: Colors.white,
                          boxShadow: [ BoxShadow(color: Colors.grey, offset: Offset(0,5), blurRadius: 5)]
                        ),
                       ),
                      ],
                     ),
                   ),
                 ),
                );
               },
              ),
            ),
           (items.length == 0)? Container(
               color: Colors.white,
               height: media.size.height / 1.2,
           ) : SizedBox(),
          ],
        ),
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
  Navigator.push(context, MaterialPageRoute(builder: (context) => CreateEventPage(user: user, gameName: gameName,), fullscreenDialog: true));
}

void toQrCode(BuildContext context, String documentId, String gameName) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeGenPage(documentId, gameName), fullscreenDialog: true));
}
