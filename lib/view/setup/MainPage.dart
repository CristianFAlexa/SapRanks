import 'dart:async';

import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/setup/WelcomePage.dart';
import 'package:bored/view/widget/MenuCarouselSlider.dart';
import 'package:bored/view/widget/NewsCard.dart';
import 'package:bored/view/widget/NewsTile.dart';
import 'package:bored/view/widget/SimpleTile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import '../component/PlayPage.dart';
import '../component/UsersPage.dart';
import '../component/ProfilePage.dart';
import '../component/QrCodeScanPage.dart';

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

  List<NewsTile> newsTiles = <NewsTile>[
    NewsTile("Football", "Bosted xp for a balanced experience.", "Jan 8, 2020", "Boost", () {}),
    NewsTile("Foosball", "Added new game foosball, come and check out!", "Jan 15, 2020", "NEW!", () {})
  ];

  @override
  void initState() {
    super.initState();
    snaps = new List();
    games?.cancel();
    games = databaseService.getGamesList().listen((QuerySnapshot snapshot) {
      final snapDocs = snapshot.documents;
      if (mounted) {
        setState(() {
          this.snaps = snapDocs;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.black38, Colors.black12])),
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: <Widget>[
              StreamBuilder(
                  stream: collectionReference.document(user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null)
                      return UserAccountsDrawerHeader(
                        decoration: BoxDecoration(
                            boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 12)],
                            image: DecorationImage(fit: BoxFit.cover, image: AssetImage("assets/images/pattern.jpg"))),
                        accountName: Text("${snapshot.data['name']}"),
                        accountEmail: Text("${snapshot.data['email']}"),
                        currentAccountPicture: Container(
                          decoration: BoxDecoration(
                              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 12)],
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: (snapshot.data['profile_picture'] == null)
                                      ? AssetImage("assets/images/default-profile-picture.png")
                                      : NetworkImage(snapshot.data['profile_picture']))),
                        ),
                      );
                    else
                      return SizedBox();
                  }),
              SimpleTile.withCustomColors(
                  FontAwesomeIcons.userAlt,
                  "Profile",
                  () => {Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(user: user), fullscreenDialog: true))},
                  Icons.arrow_right,
                  Colors.grey[800],
                  Colors.white,
                  Colors.grey[300]),
              SimpleTile.withCustomColors(
                  FontAwesomeIcons.solidPlayCircle,
                  "Play",
                  () => {Navigator.push(context, MaterialPageRoute(builder: (context) => PlayPage(user: user)))},
                  Icons.arrow_right,
                  Colors.grey[800],
                  Colors.white,
                  Colors.grey[300]),
              SimpleTile.withCustomColors(
                  Icons.people,
                  "Users",
                  () => {Navigator.push(context, MaterialPageRoute(builder: (context) => UsersPage(), fullscreenDialog: true))},
                  Icons.arrow_right,
                  Colors.grey[800],
                  Colors.white,
                  Colors.grey[300]),
              ExpandableNotifier(
                // <-- Provides ExpandableController to its children
                child: Column(
                  children: [
                    Expandable(
                      // <-- Driven by ExpandableController from ExpandableNotifier
                      collapsed: ExpandableButton(
                        // <-- Expands when tapped on the cover photo
                        child: SimpleTile.withCustomColors(
                            Icons.settings, "Settings", null, Icons.arrow_drop_down, Colors.grey[800], Colors.white, Colors.grey[300]),
                      ),
                      expanded: Column(
                        children: [
                          ExpandableButton(
                            // <-- Collapses when tapped on
                            child: SimpleTile.withCustomColors(
                                Icons.settings, "Settings", null, Icons.arrow_drop_up, Colors.grey[800], Colors.white, Colors.grey[300]),
                          ),
                          SimpleTile.withCustomColors(
                              FontAwesomeIcons.qrcode,
                              "Scan QR Code",
                              () => {Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeScanPage(user), fullscreenDialog: true))},
                              null,
                              Colors.white,
                              Colors.grey[800],
                              Colors.white),
                          ExpandableButton(
                            // <-- Collapses when tapped on
                            child: Icon(Icons.arrow_drop_up),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SimpleTile.withCustomColors(
                  FontAwesomeIcons.signOutAlt,
                  "Sign out",
                  () => {
                        gSignIn.signOut(),
                        print('Signed out.'),
                        Navigator.push(context, MaterialPageRoute(builder: (context) => WelcomePage(), fullscreenDialog: true))
                      },
                  Icons.arrow_right,
                  Colors.grey[800],
                  Colors.white,
                  Colors.grey[300]),
            ],
          ),
        ),
      ),
      body: ListView(
        children: <Widget>[new MenuCarouselSlider(snaps, user), NewsCard("Updates", Icons.update, newsTiles)],
      ),
    );
  }
}
