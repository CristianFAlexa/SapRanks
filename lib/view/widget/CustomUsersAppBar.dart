import 'dart:math';

import 'package:bored/model/Rank.dart';
import 'package:bored/model/UserModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:flutter/material.dart';

import 'MyClipper.dart';

// ignore: must_be_immutable
class CustomUsersAppBar extends StatelessWidget with PreferredSizeWidget {
  CustomUsersAppBar({this.user});

  final UserModel user;

  double _winRate;
  int _level;
  String _rank;

  @override
  Widget build(BuildContext context) {
    // win rate rule
    _winRate = ((user.disputeWin) / (user.disputeWin + user.disputeLoss)) * 100;
    // level rule
    _level = ((sqrt(625 + 100 * user.xp) - 25) / 50).floor();
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
                        colors: [Color.fromRGBO(255, 90, 0, 1), Color.fromRGBO(236, 32, 77, 1)]),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          SizedBox(
                            width: 50,
                          ),
                          Text(
                            "Profile",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(
                            width: 55,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
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
                                style: TextStyle(fontSize: 20, color: Colors.white),
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
                                style: TextStyle(fontSize: 24, color: Colors.white),
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
                                        image: (snapshot.data['profile_picture'] == null)
                                            ? AssetImage("assets/images/default-profile-picture.png")
                                            : NetworkImage(snapshot.data['profile_picture']))),
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
                                style: TextStyle(fontSize: 24, color: Colors.white),
                              )
                            ],
                          ),
                          SizedBox(
                            width: 30,
                          )
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
                                style: TextStyle(color: Colors.white, fontSize: 20),
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
  Size get preferredSize => Size(double.infinity, 200);
}
