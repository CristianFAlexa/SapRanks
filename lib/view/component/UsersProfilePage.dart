import 'dart:async';
import 'dart:math';

import 'package:bored/model/Constants.dart';
import 'package:bored/model/Rank.dart';
import 'package:bored/model/UserModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/widget/SimpleTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';

import 'ProfilePage.dart';

class UsersProfilePage extends StatefulWidget {
  UsersProfilePage({this.user});

  final UserModel user;

  @override
  _UsersProfilePageState createState() => _UsersProfilePageState(user);
}

class _UsersProfilePageState extends State<UsersProfilePage> {
  _UsersProfilePageState(this.user);

  final UserModel user;

  StreamSubscription<DocumentSnapshot> items;
  List<String> history;
  double _winRate;
  int _level;
  String _rank;

  @override
  void initState() {
    super.initState();

    items?.cancel();
    items = collectionReference.document(user.uid).snapshots().listen((DocumentSnapshot snapshot) {
      final List<String> itemList = List.from(snapshot.data['history']);
      if (mounted) {
        setState(() {
          this.history = itemList;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // win rate rule
    _winRate = ((user.disputeWin) / (user.disputeWin + user.disputeLoss)) * 100;
    // level rule
    _level = ((sqrt(625 + 100 * user.xp) - 25) / 50).floor();
    // rank rule
    _rank = Rank().getRankFromLevel(_level);

    return Scaffold(
      body: Stack(
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
                      colors: Constants.appColors),
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
                                    '${user.xp}',
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
                  "${user.email}",
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
                      image: (user.profilePicture == null)
                             ? AssetImage("assets/images/default-profile-picture.png")
                             : NetworkImage(user.profilePicture))
                  ),
                ),
                Text(
                  "${user.name.toUpperCase()}",
                  style: TextStyle(
                    color: Colors.grey[700], fontWeight: FontWeight.bold
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
