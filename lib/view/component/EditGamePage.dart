import 'dart:io';

import 'package:bored/model/GameModel.dart';
import 'package:bored/model/Regex.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class EditGamePage extends StatefulWidget {
  EditGamePage({this.documentSnapshot});

  final DocumentSnapshot documentSnapshot;

  @override
  _EditGamePageState createState() => _EditGamePageState(documentSnapshot: documentSnapshot);
}

class _EditGamePageState extends State<EditGamePage> {
  _EditGamePageState({this.documentSnapshot});

  final DocumentSnapshot documentSnapshot;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _downloadUrl;
  String _name;
  GameModel game;
  File _image;
  String _minPlayers;
  String _maxPlayers;
  String _xp;
  String _tmpMin;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future updateGame(BuildContext context) async {
    final _formState = _formKey.currentState;
    _formState.save();
    String fileName;
    if (_image != null) {
      fileName = basename(_image.path);
      StorageReference storageReference = FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        _downloadUrl = downloadUrl;
        print("Game picture updated.");
      });
      documentSnapshot.reference
          .updateData({'picture': _downloadUrl, 'name': _name, 'xp': _xp, 'min_players': _minPlayers, 'max_players': _maxPlayers});
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (game == null) game = GameModel.fromMap(documentSnapshot.data);
    return Scaffold(
      appBar: GradientAppBar(
        gradient: LinearGradient(colors: [Colors.black87, Colors.black38, Colors.black12]),
      ),
      body: Form(
        key: _formKey,
        child: Builder(
          builder: (context) => Center(
            child: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 32),
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: MediaQuery.of(context).size.width / 1.2,
                        height: 50,
                        padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Colors.white,
                            boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)]),
                        child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Name required!';
                            }
                            return null;
                          },
                          onSaved: (input) => _name = input,
                          decoration: InputDecoration(icon: Icon(Icons.update), hintText: 'Name'),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: 50,
                  padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)]),
                  child: TextFormField(
                    validator: (input) {
                      _tmpMin = input;
                      if (input.isEmpty) {
                        return 'Minimum required!';
                      } else if (!Regex.number.hasMatch(input)) {
                        return 'Number should be at most 2 digits long!';
                      }
                      return null;
                    },
                    onSaved: (input) => _minPlayers = input,
                    decoration: InputDecoration(icon: Icon(FontAwesomeIcons.minus), hintText: 'Min # of players'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: 50,
                  padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)]),
                  child: TextFormField(
                    validator: (input) {
                      if (input.isEmpty) {
                        return 'Maximum required!';
                      } else if (!Regex.number.hasMatch(input)) {
                        return 'Number should be at most 2 digits long!';
                      } else if (int.parse(_tmpMin) > int.parse(input)) {
                        return 'Maximum number of players must be greater than minimum!';
                      }
                      return null;
                    },
                    onSaved: (input) => _maxPlayers = input,
                    decoration: InputDecoration(icon: Icon(FontAwesomeIcons.plus), hintText: 'Max # of players'),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width / 1.2,
                  height: 50,
                  padding: EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.white,
                      boxShadow: [BoxShadow(color: Colors.black, blurRadius: 2)]),
                  child: TextFormField(
                    validator: (input) {
                      if (input.isEmpty) {
                        return 'Xp required!';
                      } else if (!Regex.xp.hasMatch(input)) {
                        return 'Number should be at most 3 digits long!';
                      }
                      return null;
                    },
                    onSaved: (input) => _xp = input,
                    decoration: InputDecoration(icon: Icon(Icons.star), hintText: 'Xp'),
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Align(
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 100,
                          backgroundColor: Colors.white,
                          child: ClipOval(
                            child: SizedBox(
                              width: 180.0,
                              height: 180.0,
                              child: (_image != null)
                                  ? Image.file(
                                      _image,
                                      fit: BoxFit.fill,
                                    )
                                  : Image.asset(
                                      "assets/images/icon-for-update-18.png",
                                      fit: BoxFit.fill,
                                    ),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 60.0),
                        child: IconButton(
                          icon: Icon(
                            FontAwesomeIcons.camera,
                            size: 30.0,
                          ),
                          onPressed: () {
                            getImage();
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Spacer(),
                RaisedButton(
                  onPressed: () {
                    if (_formKey.currentState.validate())
                      updateGame(context);
                    else
                      Scaffold.of(context).showSnackBar(SnackBar(content: Text("Cannot update game!")));
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  color: Colors.blueGrey,
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.update,
                        color: Colors.white,
                      ),
                      new Container(
                          padding: EdgeInsets.only(left: 10.0, right: 10.0),
                          child: new Text(
                            "All set up",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
