import 'dart:async';
import 'dart:ffi';

import 'package:bored/model/Constants.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/setup/LoginPage.dart';
import 'package:bored/view/widget/Cutout.dart';
import 'package:bored/view/widget/MenuCarouselSlider.dart';
import 'package:bored/view/widget/NewsCard.dart';
import 'package:bored/view/widget/NewsTile.dart';
import 'package:bored/view/widget/SimpleTile.dart';
import 'package:expandable/expandable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
  final GoogleSignIn gSignIn = GoogleSignIn();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: <Widget>[
              StreamBuilder(
                  stream: collectionReference.document(user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.data != null)
                      return InkWell(
                       onTap: () => {Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(user: user), fullscreenDialog: true))},
                        child: UserAccountsDrawerHeader(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(colors: Constants.appColors)),
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
                        ),
                      );
                    else
                      return SizedBox();
                  }),
              SimpleTile.withCustomColors(
                  FontAwesomeIcons.userAlt,
                  "Profile",
                  () => {Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(user: user), fullscreenDialog: true))},
                  null,
                  Colors.grey[800],
                  Colors.white,
                  Colors.grey[300]),
              SimpleTile.withCustomColors(
                  FontAwesomeIcons.solidPlayCircle,
                  "Play",
                  () => {Navigator.push(context, MaterialPageRoute(builder: (context) => PlayPage(user: user)))},
                  null,
                  Colors.grey[800],
                  Colors.white,
                  Colors.grey[300]),
              SimpleTile.withCustomColors(
                  Icons.people,
                  "Users",
                  () => {Navigator.push(context, MaterialPageRoute(builder: (context) => UsersPage(), fullscreenDialog: true))},
                  null,
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
                            Icons.settings, "Settings", null, null, Colors.grey[800], Colors.white, Colors.grey[300]),
                      ),
                      expanded: Column(
                        children: [
                          ExpandableButton(
                            // <-- Collapses when tapped on
                            child: SimpleTile.withCustomColors(
                                Icons.settings, "Settings", null, null, Colors.grey[800], Colors.white, Colors.grey[300]),
                          ),
                          SimpleTile.withCustomColors(
                              FontAwesomeIcons.qrcode,
                              "Scan QR Code",
                              () => {Navigator.push(context, MaterialPageRoute(builder: (context) => QrCodeScanPage(user), fullscreenDialog: true))},
                              null,
                              Colors.white,
                              Constants.primaryColor,
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
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage(), fullscreenDialog: true))
                      },
                  null,
                  Colors.grey[800],
                  Colors.white,
                  Colors.grey[300]),
            ],
          ),
        ),
      ),
      body: Builder(
        builder: (context) => Container(
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
                     mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                       IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        color: Colors.white,
                       ),
                        InkWell(
                         onTap: () => Scaffold.of(context).openDrawer(),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              'Menu',
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                        ),
                        Spacer(),
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
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
                child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10, top: 15, left: 20),
                      child: Text(
                        'Welcome',
                        style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
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
                   new MenuCarouselSlider(user),
                   NewsCard("Updates", Icons.update)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
