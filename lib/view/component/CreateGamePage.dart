import 'dart:io';

import 'package:bored/model/GameModel.dart';
import 'package:bored/model/QueueModel.dart';
import 'package:bored/service/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';

class CreateGamePage extends StatefulWidget {
  @override
  _CreateGamePageState createState() => _CreateGamePageState();
}

class _CreateGamePageState extends State<CreateGamePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _name;
  String _downloadUrl;
  File _image;
  String _minPlayers;
  String _maxPlayers;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future saveNewGame(BuildContext context) async {
    // logic for updating profile picture
    final _formState = _formKey.currentState;
    _formState.save();
    String fileName;
    if (_image != null && _name != null) {
      fileName = basename(_image.path);
      StorageReference storageReference =
          FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      setState(() {
        _downloadUrl = downloadUrl;
        print("Game picture uploaded.");
      });
      var uid = Uuid().v4();
      Firestore.instance
          .collection('games').document('$uid')
          .setData(GameModel(_name, 0, _downloadUrl, uid, int.parse(_minPlayers),  int.parse(_maxPlayers)).toMap());
      // creating a queue for later use
      queueCollectionReference.document(_name)
          .setData(QueueModel(new Timestamp.now(),  new List<String>(), int.parse(_minPlayers), int.parse(_maxPlayers)).toMap());
      Navigator.of(context).pop();
    } else {
      Scaffold.of(context).showSnackBar(new SnackBar(
          content: new Text('You did not choose a picture and a name.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientAppBar(
        gradient:
            LinearGradient(colors: [Colors.green, Colors.lightGreenAccent]),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.only(top: 32),
                child: Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: 50,
                      padding: EdgeInsets.only(
                          top: 4, left: 16, right: 16, bottom: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black, blurRadius: 2)
                          ]),
                      child: TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Name required!';
                          }
                        },
                        onSaved: (input) => _name = input,
                        decoration: InputDecoration(
                            icon: Icon(Icons.gamepad),
                            hintText: 'Choose a name'),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: 50,
                      padding: EdgeInsets.only(
                          top: 4, left: 16, right: 16, bottom: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black, blurRadius: 2)
                          ]),
                      child: TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Minimum required!';
                          }
                        },
                        onSaved: (input) => _minPlayers = input,
                        decoration: InputDecoration(
                            icon: Icon(FontAwesomeIcons.minus),
                            hintText: 'Choose min # of players'),
                      ),
                    ),
                    SizedBox(height: 10,),
                    Container(
                      width: MediaQuery.of(context).size.width / 1.2,
                      height: 50,
                      padding: EdgeInsets.only(
                          top: 4, left: 16, right: 16, bottom: 4),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.black, blurRadius: 2)
                          ]),
                      child: TextFormField(
                        // ignore: missing_return
                        validator: (input) {
                          if (input.isEmpty) {
                            return 'Maximum required!';
                          }
                        },
                        onSaved: (input) => _maxPlayers = input,
                        decoration: InputDecoration(
                            icon: Icon(FontAwesomeIcons.plus),
                            hintText: 'Choose max # of players'),
                      ),
                    ),
                  ],
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
                                    "assets/images/add-icon.png",
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
                  saveNewGame(context);
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                color: Colors.green,
                child: new Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      FontAwesomeIcons.plusCircle,
                      color: Colors.white,
                    ),
                    new Container(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: new Text(
                          "Add game",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
