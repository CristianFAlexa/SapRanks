import 'package:bored/service/DatabaseService.dart';
import 'package:countdown_flutter/countdown_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class PlayGamePage extends StatefulWidget {
  PlayGamePage({this.user, this.gameName});

  final FirebaseUser user;
  final String gameName;

  @override
  _PlayGamePageState createState() =>
      _PlayGamePageState(user: user, gameName: gameName);
}

class _PlayGamePageState extends State<PlayGamePage> {
  _PlayGamePageState({this.user, this.gameName});

  final FirebaseUser user;
  final String gameName;

  Widget getTextWidgets(List<dynamic> strings) {
    return new Column(
        children: strings
            .map((item) => Row(
                  children: <Widget>[
                    StreamBuilder(
                      stream: collectionReference.document(item).snapshots(),
                      builder: (context, snapshot) {
                        return (snapshot.data == null)
                            ? Text("Loading..")
                            : Padding(
                                padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                                child: Material(
                                  color: Colors.transparent,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          SizedBox(
                                            width: 100,
                                          ),
                                          Container(
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: (snapshot.data[
                                                                'profile_picture'] ==
                                                            null)
                                                        ? AssetImage(
                                                            "assets/images/default-profile-picture.png")
                                                        : NetworkImage(snapshot
                                                                .data[
                                                            'profile_picture']))),
                                          ),
                                          Text(
                                            "${snapshot.data['name']}",
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                      },
                    )
                  ],
                ))
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: queueCollectionReference.document(gameName).collection('active').document('Zo93EvNtayzsuhy1H8Zq').snapshots(),
        builder: (context, snapshot) {
          return (snapshot.data == null)
              ? Text("Loading..")
              : Scaffold(
                  appBar: GradientAppBar(
                    title: Center(
                      child: Text("Queue"),
                    ),
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black87,
                          Colors.black38,
                          Colors.black12
                        ]),
                    automaticallyImplyLeading: true,
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
                    child: Column(
                      children: <Widget>[
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: Text(
                            "${snapshot.data['players'].length}/${snapshot.data['max_players']} players",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        getTextWidgets(snapshot.data['players']),
                        SizedBox(
                          height: 50,
                        ),
                      Center(
                        child: CountdownFormatted(
                          duration: Duration(hours: 1),
                          builder: (BuildContext ctx, String remaining) {
                            return Text("Game starts in $remaining", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),); // 01:00:00
                          },
                        ),
                      ),
                        SizedBox(
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                );
        });
  }
}
