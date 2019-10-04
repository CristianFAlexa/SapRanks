import 'package:bored/service/DatabaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  CollectionReference collectionReference = Firestore.instance.collection('users');
  DatabaseService databaseService = DatabaseService();
  FirebaseUser user;

  @override
  void initState() {
    super.initState();
    databaseService.getFirebaseUser().then((user){
      setState(() {
        this.user = user;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: CustomAppBar(user: user,collectionReference: collectionReference),
        body: StreamBuilder(
          stream: collectionReference.document(this.user.uid).snapshots(),
          builder: (context, snapshot) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Text(
                        "Contact",
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        "${snapshot.data['name']}", // todo: here should be email address
                        style: TextStyle(color: Colors.black, fontSize: 20),
                      ),
                    ],
                  ),
                ),

                /* Container(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.2,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            // Color.fromRGBO(255, 90, 0, 1),
                            Colors.deepOrange,
                            Color.fromRGBO(255, 173, 52, 1),
                          ]),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      )),
                  child: Center(
                    child: Text("...",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                      ),
                    ),
                  ),

                )*/ // todo maybe use for login as decoration
              ],
            );
          }
        )
    );
  }
}

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  CustomAppBar({this.user, this.collectionReference});

  final CollectionReference collectionReference;
  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MyClipper(),
      child: StreamBuilder(
        stream: collectionReference.document(this.user.uid).snapshots(),
        builder: (context, snapshot) {
          return Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      // Color.fromRGBO(255, 90, 0, 1),
                      Colors.deepOrange,
                      Color.fromRGBO(255, 173, 52, 1),
                    ]),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                )),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                      ),
                      onPressed: () {}, // todo : add fct for menu on profile
                    ),
                    Text(
                      "Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.notifications,
                        color: Colors.white,
                      ),
                      onPressed: () {}, // todo : add fct for notifications
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage(
                                    "assets/images/new-user-icon.jpg"), // todo : here should be user profile picture
                              )),
                        ),
                        Text(
                          "New User", // todo : here should be user name
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: <Widget>[
                        Text(
                          "Rank",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "${snapshot.data['rank']}",
                          style: TextStyle(fontSize: 24, color: Colors.white),
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
                          "90%", // todo: here should be actual rank of user
                          style: TextStyle(fontSize: 24, color: Colors.white),
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
                          "20", // todo: here should be actual rank of user
                          style: TextStyle(fontSize: 24, color: Colors.white),
                        )
                      ],
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          "Points",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "33K", // todo: here should be points
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 32,
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size(double.infinity, 250);
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - 0); // to change later if desired
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
