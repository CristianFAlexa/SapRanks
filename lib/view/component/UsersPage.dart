import 'dart:async';

import 'package:bored/model/UserModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

import 'UsersProfilePage.dart';

class UsersPage extends StatefulWidget {
  @override
  _UsersPageState createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {
  List<UserModel> items;
  DatabaseService databaseService = new DatabaseService();
  StreamSubscription<QuerySnapshot> users;

  @override
  void initState() {
    super.initState();

    items = new List();
    users?.cancel();
    users = databaseService.getUserModelList().listen((QuerySnapshot snapshot) {
      final List<UserModel> userModels = snapshot.documents.map((documentSnapshot) => UserModel.fromMap(documentSnapshot.data)).toList();
      if (this.mounted) {
        setState(() {
          this.items = userModels;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        title: Text(
          "Users",
          style: TextStyle(color: Colors.white),
        ),
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.black38, Colors.black12]),
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
                              color: Colors.blueGrey[900],
                              elevation: 14.0,
                              shadowColor: Colors.black,
                              child: Center(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Row(
                                        children: <Widget>[
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: (items[index].profilePicture == null)
                                                        ? AssetImage("assets/images/default-profile-picture.png")
                                                        : NetworkImage(items[index].profilePicture))),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: <Widget>[
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                "${items[index].name}",
                                                style: TextStyle(color: Colors.white, fontSize: 16.0, fontWeight: FontWeight.bold),
                                              ),
                                              Text(
                                                "${items[index].email}",
                                                style: TextStyle(color: Colors.white, fontSize: 14.0),
                                              ),
                                              Text(
                                                "${items[index].xp} xp",
                                                style: TextStyle(color: Colors.white, fontSize: 14.0),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
                                          Row(
                                            children: <Widget>[
                                              Text(
                                                "${items[index].rank}",
                                                style: TextStyle(color: Colors.white, fontSize: 13.0, fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              IconButton(
                                                  icon: Icon(
                                                    Icons.star,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: null)
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
  Navigator.push(context, MaterialPageRoute(builder: (context) => UsersProfilePage(user: user), fullscreenDialog: true));
}
