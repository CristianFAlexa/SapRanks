import 'dart:io';

import 'package:bored/model/Constants.dart';
import 'package:bored/model/GameModel.dart';
import 'package:bored/model/Regex.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  String _xp;
  String _tmpMin;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future saveNewGame(BuildContext context) async {
    final _formState = _formKey.currentState;
    _formState.save();
    String fileName;
    if (_image != null) {
      fileName = basename(_image.path);
      StorageReference storageReference = FirebaseStorage.instance.ref().child(fileName);
      StorageUploadTask uploadTask = storageReference.putFile(_image);
      StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      if (!mounted) return;
      setState(() {
        _downloadUrl = downloadUrl;
        print("Game picture uploaded.");
      });
      var uid = Uuid().v4();
      Firestore.instance
          .collection('games')
          .document('$uid')
          .setData(GameModel(_name, 0, _downloadUrl, uid, int.parse(_maxPlayers), int.parse(_minPlayers), int.parse(_xp)).toMap());
      Navigator.of(context).pop();
    } else {
      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text('You did not choose a picture and a name.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      resizeToAvoidBottomPadding: true,
      body: Form(
        key: _formKey,
        child: Builder(
          builder: (context) => Center(
            child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: Constants.appColors),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 100,
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.arrow_back, color: Colors.white, ),
                              onPressed: (){
                                Navigator.of(context).pop();
                              },
                            ),
                            Text('Create new game', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),)
                          ],
                        ),
                      ),
                      Material(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text('Game Details', style: TextStyle(color: Colors.black, fontSize: 18),),
                            ),
                          ],
                        ),
                        elevation: 10,
                        shadowColor: Constants.primaryColor,
                         borderRadius: BorderRadius.only(
                           topLeft: Radius.circular(20),
                           topRight: Radius.circular(20),
                         ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                        ),
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                validator: (input) {
                                  if (input.isEmpty) {
                                    return 'Name required!';
                                  }
                                  return null;
                                },
                                onSaved: (input) => _name = input,
                                decoration: InputDecoration(
                                  enabledBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.blueGrey[900]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.green[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  errorBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.red[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  focusedErrorBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.red[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  prefixIcon: Icon(Icons.gamepad),
                                  hintText: 'Football',
                                  labelText: 'Name',
                                  helperText: 'Choose a game name.'
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                decoration: InputDecoration(
                                  enabledBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.blueGrey[900]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.green[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  errorBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.red[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  focusedErrorBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.red[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  prefixIcon: Icon(FontAwesomeIcons.minus),
                                  hintText: '2',
                                  labelText: 'Minimum',
                                  helperText: 'Minimum number of players.'
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                decoration: InputDecoration(
                                  enabledBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.blueGrey[900]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.green[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  errorBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.red[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  focusedErrorBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.red[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  prefixIcon: Icon(Icons.add),
                                  hintText: '99',
                                  labelText: 'Maximum',
                                  helperText: 'Maximum number of players.'
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
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
                                decoration: InputDecoration(
                                  enabledBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.blueGrey[900]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  focusedBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.green[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  errorBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.red[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  focusedErrorBorder: new OutlineInputBorder(
                                    borderSide: new BorderSide(color: Colors.red[600]),
                                    borderRadius: BorderRadius.circular(20)
                                  ),
                                  prefixIcon: Icon(Icons.star),
                                  hintText: '200',
                                  labelText: 'Xp',
                                  helperText: 'Experience won per game.'
                                ),
                              ),
                            ),
                            Row(
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
                                               : Center(
                                          child: Text('Choose photo'),
                                        )  /*Image.asset(
                                          "assets/images/add-icon.png",
                                          fit: BoxFit.fill,
                                        ),*/
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
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => FloatingActionButton(
          onPressed: () {
            if (_formKey.currentState.validate())
              saveNewGame(context);
            else
              Scaffold.of(context).showSnackBar(SnackBar(content: Text("Cannot create game!")));
          },
          child: Icon(Icons.check),
          backgroundColor: Constants.primaryColor,
          heroTag: 'createGameFloatingActionButton',
        ),
      ),
    );
  }
}
