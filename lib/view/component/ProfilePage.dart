import 'dart:async';

import 'package:bored/model/UserModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/widget/CustomAppBar.dart';
import 'package:bored/view/widget/GameHistoryTile.dart';
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
  UserModel _userModel;
  StreamSubscription<DocumentSnapshot> items;
  List<String> history;

  @override
  void initState() {
    super.initState();
    collectionReference.document(user.uid).get().then((docSnap) {
      setState(() {
        _userModel = UserModel.map(docSnap.data);
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
    return StreamBuilder(
        stream: collectionReference.document(this.user.uid).snapshots(),
        builder: (context, snapshot) {
          return Stack(children: <Widget>[
            Image.asset(
              "assets/images/spaceman.jpg",
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: CustomAppBar(
                user: user,
                collectionReference: collectionReference,
                userModel: _userModel,
              ),
              body: StreamBuilder(
                  stream: collectionReference.document(this.user.uid).snapshots(),
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Text('Loading..');
                      default:
                        return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [Colors.black87, Colors.black45, Colors.black38, Colors.black12, Colors.black12]),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    child: Column(
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey))),
                                          height: 50,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      "History",
                                                      style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold, color: Colors.white),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        showHistory(history),
                                        Text(
                                          "Contact",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          "${snapshot.data['email']}",
                                          style: TextStyle(color: Colors.white, fontSize: 20),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ));
                    }
                  }),
            ),
          ]);
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
      ? new Expanded(
          child: new ListView.builder(
              itemCount: history.length,
              itemBuilder: (context, index) {
                return new GameHistoryTile(Icons.history, history[index].split(" "), () {});
              }))
      : new SizedBox();
}
