import 'dart:async';

import 'package:bored/model/UserModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/widget/CustomUsersAppBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          appBar: CustomUsersAppBar(user: widget.user),
          body: Column(
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
