import 'package:bored/view/component/ProfilePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'component/ChallengePage.dart';

class Home extends StatelessWidget {
  const Home({Key key, this.user}) : super(key: key);
  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    final GoogleSignIn _gSignIn = GoogleSignIn();

    return Scaffold(
      appBar: GradientAppBar(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // Color.fromRGBO(255, 90, 0, 1),
              Colors.deepOrange,
              Color.fromRGBO(255, 173, 52, 1),
            ]),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              FontAwesomeIcons.solidPlayCircle,
              size: 20.0,
              color: Colors.white,
            ),
            onPressed: () => toChallenge(context),
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.userAlt,
              size: 20.0,
              color: Colors.white,
            ),
            onPressed: () => toProfile(context),
          ),
          IconButton(
            icon: Icon(
              Icons.settings,
              size: 20.0,
              color: Colors.white,
            ),
            onPressed: toSettings,
          ),
          IconButton(
            icon: Icon(
              FontAwesomeIcons.signOutAlt,
              size: 20.0,
              color: Colors.white,
            ),
            onPressed: () {
              _gSignIn.signOut();
              print('Signed out.');
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document(user.uid)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Text('Loading..');
            default:
              return Center(
                child: Text(snapshot.data['role'] + ' page'),
              );
          }
        },
      ),
    );
  }
}

void toProfile(BuildContext context) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ProfilePage(), fullscreenDialog: true));
}

void toSettings() {
  //  Navigator.push(
  //      context,
  //      MaterialPageRoute(
  //          builder: (context) => SettingsPage(),
  //          fullscreenDialog: true));
}

void toChallenge(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChallengePage(),
            fullscreenDialog: true));
}
