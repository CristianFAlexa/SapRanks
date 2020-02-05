import 'dart:async';

import 'package:bored/model/Constants.dart';
import 'package:bored/model/UserModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
     resizeToAvoidBottomPadding: true,
      body: Container(
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
                children: <Widget>[
                  FlatButton(
                   onPressed: (){
                    Navigator.of(context).pop();
                   },
                   child: Icon(Icons.arrow_back, color: Colors.white, size: 28,),
                  ),
                  Icon(Icons.people, color: Colors.white,),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text('${items.length}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.white),),
                  ),
                ],
               ),
              ),
             ),
           ),
           Container(
            decoration: BoxDecoration(
             color: Colors.white,
             borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))
            ),
            child: Row(
             children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 10, top: 15, left: 20),
                child: Text('Ranks, Users', style: TextStyle( fontSize: 20, color: Colors.grey[700]),),
              )
             ],
            ),
           ),
           Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [ BoxShadow(color: Colors.grey, offset: Offset(0,5), blurRadius: 5)]
            ),
             child: Padding(
               padding: const EdgeInsets.only(bottom: 200),
               child: ListView.builder(
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                 return InkWell(
                  onTap: () => visitProfile(context, items[index]),
                  child: Stack(
                   children: <Widget>[
                    Padding(
                     padding: const EdgeInsets.only(left: 10, right: 10, top: 4, bottom: 4),
                     child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 100.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [ BoxShadow(color: Colors.grey, offset: Offset(0,5), blurRadius: 5)]
                      ),
                      child: Padding(
                       padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                       child: Material(
                        color: Colors.transparent,
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
                                 style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                 "${items[index].email}",
                                 style: TextStyle(color: Colors.grey, fontSize: 14.0, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                 "${items[index].rank}",
                                 style: TextStyle(color: Colors.grey, fontSize: 13.0, fontWeight: FontWeight.bold),
                                ),
                               ],
                              ),
                             ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 35, right: 8),
                              child: Row(
                               children: <Widget>[
                                Icon(Icons.star, color: Constants.primaryColorLight,),
                                Text(
                                 "${items[index].xp}",
                                 style: TextStyle(color: Constants.primaryColorLight, fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                               ],
                              ),
                            ),
                           ],
                          ),
                         ),
                        ),
                       ),
                      ),
                     ),
                    ),
                   ],
                  ),
                 );
                },
               ),
             ),
           ),

          ],
        ),
      ),
    );
  }
}

void visitProfile(BuildContext context, UserModel user) {
  Navigator.push(context, MaterialPageRoute(builder: (context) => UsersProfilePage(user: user), fullscreenDialog: true));
}
