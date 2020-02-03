import 'dart:async';
import 'dart:math';

import 'package:bored/model/Rank.dart';
import 'package:bored/model/UserModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/setup/MainPage.dart';
import 'package:bored/view/widget/GameHistoryTile.dart';
import 'package:bored/view/widget/SimpleTile.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'EditProfilePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _ProfilePageState createState() => _ProfilePageState(user: user);
}

class _ProfilePageState extends State<ProfilePage> {
  _ProfilePageState({this.user});

  final FirebaseUser user;
  UserModel userModel;
  StreamSubscription<DocumentSnapshot> items;
  List<String> history;

  double _winRate;
  int _level;
  String _rank;

  @override
  void initState() {
    super.initState();
    collectionReference.document(user.uid).get().then((docSnap) {
      setState(() {
        userModel = UserModel.map(docSnap.data);
      });
    });

    items?.cancel();
    items = collectionReference.document(user.uid).snapshots().listen((DocumentSnapshot snapshot) {
      if (!mounted) {
        return;
      }
      final List<String> itemList = List.from(snapshot.data['history']);
      setState(() {
        this.history = itemList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (userModel == null) return CircularProgressIndicator();
    // win rate rule
    _winRate = ((userModel.disputeWin) / (userModel.disputeWin + userModel.disputeLoss)) * 100;
    // level rule
    _level = ((sqrt(625 + 100 * userModel.xp) - 25) / 50).floor();
    // rank rule
    _rank = Rank().getRankFromLevel(_level);
    return StreamBuilder(
        stream: collectionReference.document(this.user.uid).snapshots(),
        builder: (context, snapshot) {
          return Scaffold(
              body: StreamBuilder(
                  stream: collectionReference.document(this.user.uid).snapshots(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return CircularProgressIndicator();
                      default:
                        return Stack(
                          children: <Widget>[
                            Container(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [Color.fromRGBO(255, 90, 0, 1), Color.fromRGBO(236, 32, 77, 1)]),
                                    ),
                                    child: Row(
                                      children: <Widget>[
                                        IconButton(
                                          icon: Icon(Icons.arrow_back, color: Colors.white,),
                                          onPressed: () => {
                                            Navigator.of(context).pop()
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 100,),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(0,5), blurRadius: 5)]
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Padding(
                                              padding: const EdgeInsets.only(right: 32),
                                              child: Container(
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      '$_level',
                                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(
                                                      'level',
                                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                border: Border(
                                                  left: BorderSide(color: Colors.grey),
                                                  right: BorderSide(color: Colors.grey)
                                                )
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.only(left: 32, right: 32),
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      '${_winRate.toStringAsFixed(2)}%',
                                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(
                                                      'win rate',
                                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(left: 32),
                                              child: Container(
                                                child: Column(
                                                  children: <Widget>[
                                                    Text(
                                                      '${userModel.xp}',
                                                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                                    ),
                                                    Text(
                                                      'xp',
                                                      style: TextStyle(fontSize: 16, color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: <Widget>[
                                          ExpandableNotifier(
                                            child: Column(
                                              children: [
                                                Expandable(
                                                  collapsed: ExpandableButton(
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(0,5), blurRadius: 5)]
                                                      ),
                                                      child: SimpleTile.withCustomColors(
                                                        Icons.add_circle, "History", null, Icons.arrow_drop_down, Colors.grey[800], Colors.white, Colors.grey[300]),
                                                    ),
                                                  ),
                                                  expanded: Column(
                                                    children: [
                                                      ExpandableButton(
                                                        child: Container(
                                                          decoration: BoxDecoration(
                                                            boxShadow: [BoxShadow(color: Colors.grey, offset: Offset(0,5), blurRadius: 5)]
                                                          ),
                                                          child: SimpleTile.withCustomColors(
                                                            Icons.remove_circle, "History", null, Icons.arrow_drop_up, Colors.grey[800], Colors.white, Colors.grey[300]),
                                                        ),
                                                      ),
                                                      Container(child: showHistory(history)),
                                                      ExpandableButton(
                                                        child: Icon(Icons.arrow_drop_up),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 10,),
                                  Text(
                                    "Contact",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    "${snapshot.data['email']}",
                                    style: TextStyle(color: Colors.grey, fontSize: 20),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: MediaQuery.of(context).size.width / 2 - 70,
                              top: 110,
                              child:  Column(
                                children: <Widget>[
                                  Container(
                                    width: 140,
                                    height: 140,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: (snapshot.data['profile_picture'] == null)
                                               ? AssetImage("assets/images/default-profile-picture.png")
                                               : NetworkImage(snapshot.data['profile_picture']))),
                                  ),
                                  Text(
                                    "${userModel.name.toUpperCase()}",
                                    style: TextStyle(
                                      color: Colors.grey[700], fontWeight: FontWeight.bold
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Positioned(
                              left: MediaQuery.of(context).size.width / 6 - 25,
                              top: 160,
                              child:  Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Color.fromRGBO(255, 90, 0, 1),
                                    size: 32,
                                  ),
                                  onPressed: () => editProfile(context, user),
                                ),
                              ),
                            ),
                            Positioned(
                              right: MediaQuery.of(context).size.width / 6 - 25,
                              top: 160,
                              child:  Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.home,
                                    color: Color.fromRGBO(236, 32, 77, 1),
                                    size: 32,
                                  ),
                                  onPressed: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage(user: user), fullscreenDialog: true))},
                                ),
                              ),
                            ),
                          ],
                        );
                    }
                  }),
            );
        });
  }
}

void editProfile(BuildContext context, FirebaseUser user) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditProfilePage(
                user: user,
              ),
          fullscreenDialog: true));
}

Widget showHistory(List<String> history) {
  return (history != null)
      ? new ListView.builder(
    shrinkWrap: true,

    itemCount: history.length,
    itemBuilder: (context, index) {
      return new GameHistoryTile(Icons.history, history[index].split(" "), () {});
    })
      : new SizedBox();
}
