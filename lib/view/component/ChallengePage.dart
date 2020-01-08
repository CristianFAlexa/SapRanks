import 'dart:async';
import 'dart:math';

import 'package:bored/model/Rank.dart';
import 'package:bored/model/UserModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'ProfilePage.dart';

class ChallengePage extends StatefulWidget {
  @override
  _ChallengePageState createState() => _ChallengePageState();
}

class _ChallengePageState extends State<ChallengePage> {
  List<UserModel> items;
  DatabaseService databaseService = new DatabaseService();
  StreamSubscription<QuerySnapshot> users;

  @override
  void initState() {
    super.initState();

    items = new List();
    users?.cancel();
    users = databaseService.getUserModelList().listen((QuerySnapshot snapshot) {
      final List<UserModel> userModels = snapshot.documents
          .map((documentSnapshot) => UserModel.fromMap(documentSnapshot.data))
          .toList();
      setState(() {
        this.items = userModels;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        actions: <Widget>[
          IconButton(
            onPressed: (){},
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        ],
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black87, Colors.black38, Colors.black12]),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 80,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: () => visitProfile(context, items[index]),
                  child: Stack(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100.0,
                          child: Padding(
                            padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                            child: Material(
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(5),
                                bottomRight: Radius.circular(5),
                                topLeft: Radius.circular(5),
                                topRight: Radius.circular(5),
                              ),
                              color: Colors.white,
                              elevation: 14.0,
                              shadowColor: Colors.black,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: (items[index].profilePicture ==
                                                    null)
                                                    ? AssetImage(
                                                    "assets/images/default-profile-picture.png")
                                                    : NetworkImage(items[index].profilePicture))),
                                      ),
                                      Text(
                                        "${items[index].name}",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 15.0),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${items[index].rank}",
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 13.0,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                                IconButton(icon: Icon(Icons.person_pin_circle), onPressed: null)
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


void visitProfile(BuildContext context, UserModel user) {
  Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => UsersProfilePage(user: user),
          fullscreenDialog: true));
}

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

  @override
  void initState() {
    super.initState();

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
          appBar: CustomAppBar2(user: widget.user),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey))),
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
                                    style: TextStyle(
                                        fontSize: 25.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      showHistory(history)
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

}

// ignore: must_be_immutable
class CustomAppBar2 extends StatelessWidget with PreferredSizeWidget {
  CustomAppBar2({this.user});

  final UserModel user;

  double _winRate;
  int _level;
  String _rank;

  @override
  Widget build(BuildContext context) {
    // win rate rule - todo: make a class of static object rules
    _winRate = ((user.disputeWin) / (user.disputeWin + user.disputeLoss)) * 100;
    // level rule
    _level = (( sqrt(625+100*user.xp) - 25) / 50).floor();
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
//                            Color.fromRGBO(255, 117, 24, 1),
//                            Color.fromRGBO(255, 73, 108, 1),
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
                                // todo: here should be actual rank of user
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
                                "${user.name.toUpperCase()}",
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
                                "${user.xp}",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            ],
                          ),
                          SizedBox(
                            width: 55,
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
  // TODO: implement preferredSize
  Size get preferredSize => Size(double.infinity, 200);
}


