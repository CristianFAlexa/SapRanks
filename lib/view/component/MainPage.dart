import 'dart:async';

import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/welcome.dart';
import 'package:bored/view/widget/GameHistoryTile.dart';
import 'package:bored/view/widget/MenuCarouselSlider.dart';
import 'package:bored/view/widget/MenuListTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import '../home.dart';
import 'ChallengePage.dart';
import 'ProfilePage.dart';
import 'SettingsPage.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  _MainPageState createState() => _MainPageState(user: user);
}

class _MainPageState extends State<MainPage> {
  _MainPageState({this.user});

  FirebaseUser user;
  DatabaseService databaseService = new DatabaseService();
  List<DocumentSnapshot> snaps;
  StreamSubscription<QuerySnapshot> games;
  final GoogleSignIn gSignIn = GoogleSignIn();
  StreamSubscription<DocumentSnapshot> items;
  List<String> history;

  @override
  void initState() {
    super.initState();
    snaps = new List();
    games?.cancel();
    games = databaseService.getGamesList().listen((QuerySnapshot snapshot) {
      final snapDocs = snapshot.documents;
      setState(() {
        this.snaps = snapDocs;
      });
    });

    items?.cancel();
    items = collectionReference
        .document(user.uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      final List<String> itemList = List.from(snapshot.data['history']);
      setState(() {
        this.history = itemList;
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
                colors: [Colors.black87, Colors.black38, Colors.black12])),
        drawer: Drawer(
          child: Container(
            decoration:  BoxDecoration(
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

            child: ListView(
              children: <Widget>[
                StreamBuilder(
                    stream: collectionReference.document(user.uid).snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.data != null)
                        return DrawerHeader(
                          child: Container(
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black54, blurRadius: 12)
                                      ],
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: (snapshot
                                              .data['profile_picture'] ==
                                              null)
                                              ? AssetImage(
                                              "assets/images/default-profile-picture.png")
                                              : NetworkImage(snapshot
                                              .data['profile_picture']))),
                                ),
                                Text("${snapshot.data['name']}")
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: [
                                  Color.fromRGBO(255, 90, 0, 1),
                                  Color.fromRGBO(236, 32, 77, 1)
                                ]),
                          ),
                        );
                      else
                        return SizedBox();
                    }),
                MenuListTile(
                    FontAwesomeIcons.userAlt,
                    "Profile",
                    () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage(user: user),
                                  fullscreenDialog: true))
                        }),
                MenuListTile(
                    FontAwesomeIcons.solidPlayCircle,
                    "Play",
                    () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Home(user: user)))
                        }),
                MenuListTile(
                    Icons.people,
                    "Users",
                    () => {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChallengePage(),
                                  fullscreenDialog: true))
                        }),
                MenuListTile(Icons.settings, "Settings", () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SettingsPage(user)))
                }),
                MenuListTile(
                    FontAwesomeIcons.signOutAlt,
                    "Sign out",
                    () => {
                          gSignIn.signOut(),
                          print('Signed out.'),
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Welcome(),
                                  fullscreenDialog: true))
                        }),
              ],
            ),
          ),
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
          child: new Column(
            children: <Widget>[
              new MenuCarouselSlider(snaps, user),
              new Container(
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
              (history != null)
                  ? new Expanded(
                      child: new ListView.builder(
                          itemCount: history.length,
                          itemBuilder: (context, index) {
                            return new GameHistoryTile(
                                Icons.history, history[index].split(" "), () {});
                          }))
                  : SizedBox(),
            ],
          ),
        ));
  }
}
