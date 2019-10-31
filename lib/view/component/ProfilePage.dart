import 'dart:math';

import 'package:bored/model/Rank.dart';
import 'package:bored/model/UserModel.dart';
import 'package:bored/service/DatabaseService.dart';
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

  @override
  Widget build(BuildContext context) {
    collectionReference.document(user.uid).get().then((docSnap) {
      _userModel = UserModel.map(docSnap.data);
    });
    return StreamBuilder(
        stream: collectionReference.document(this.user.uid).snapshots(),
        builder: (context, snapshot) {
          return Stack(
            children: <Widget>[
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
                                   colors: [Colors.black87, Colors.black45, Colors.black38,  Colors.black12, Colors.black12]),),
                             child: Column(
                               mainAxisAlignment: MainAxisAlignment.spaceAround,
                               crossAxisAlignment: CrossAxisAlignment.stretch,
                               children: <Widget>[
                                 Container(
                                   child: Column(
                                     children: <Widget>[
                                       Text(
                                         "Contact",
                                         style: TextStyle(color: Colors.white),
                                       ),
                                       Text(
                                         //"${snapshot.data['email']}",
                                         "${snapshot.data['email']}",
                                         style: TextStyle(color: Colors.white, fontSize: 20),
                                       ),
                                     ],
                                   ),
                                 ),
                               ],
                             )
                         );
                     }
                   }),
            ),
            ]
          );
        });
  }
}

// ignore: must_be_immutable
class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  CustomAppBar({this.user, this.collectionReference, this.userModel});

  final UserModel userModel;
  final CollectionReference collectionReference;
  final FirebaseUser user;

  double _winRate;
  int _level;
  String _rank;

  @override
  Widget build(BuildContext context) {

    if(userModel==null)
      return Text("Loading");
    // win rate rule - todo: make a class of static object rules
    _winRate = ((userModel.disputeWin) / (userModel.disputeWin + userModel.disputeLoss)) * 100;
    // level rule
    _level = (( sqrt(625+100*userModel.xp) - 25) / 50).floor();
    // rank rule
    _rank = Rank().getRankFromLevel(_level);

    return ClipPath(
      clipper: MyClipper(),
      child: StreamBuilder(
          stream: collectionReference.document(this.user.uid).snapshots(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Text('Loading..');
              default:
                return Container(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [Color.fromRGBO(255, 90, 0, 1),
                            Color.fromRGBO(236, 32, 77, 1)
                          ]),),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(width: 50,),
                          Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 55,),
                        ],
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                "Rank",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "$_rank",
                                style: TextStyle(
                                    fontSize: 20, color: Colors.white),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                "Level",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "$_level",
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
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
                              Text(
                                "${userModel.name.toUpperCase()}",
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              )
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Text(
                                "Win rate",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "${_winRate.toStringAsFixed(2)}%",
                                style: TextStyle(
                                    fontSize: 24, color: Colors.white),
                              )
                            ],
                          ),
                          SizedBox(width: 30,)
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Text(
                                "XP",
                                style: TextStyle(color: Colors.white),
                              ),
                              Text(
                                "${userModel.xp}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                          SizedBox(width: 5,),
                          Column(
                            children: <Widget>[
                              IconButton(
                                iconSize: 20,
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                ),
                                onPressed: () =>
                                    editProfile(context, user),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 50,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
            }
          }),
    );
  }

  @override
  Size get preferredSize => Size(0, 200);
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 50); // to change later if desired
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
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
