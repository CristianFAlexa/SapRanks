import 'dart:async';

import 'package:bored/model/UserModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

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
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              // Color.fromRGBO(255, 90, 0, 1),
              Colors.deepOrange,
              Color.fromRGBO(255, 173, 52, 1),
            ]),
      ),
      body: Column(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 80,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context,index){
                return Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 8.0,right: 8.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: 80.0,
                        child: Padding(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Material(
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            color: Colors.white,
                            elevation: 14.0,
                            shadowColor: Colors.black, // todo: maybe not black
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      "${items[index].email}",
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 15.0
                                      ),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          "${items[index].rank}",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 13.0,
                                            fontWeight: FontWeight.bold
                                          ),
                                        ),
                                        Text(
                                          "${items[index].role}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 13.0,
                                              fontWeight: FontWeight.bold
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
