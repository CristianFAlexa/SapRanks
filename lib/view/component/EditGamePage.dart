import 'dart:io';

import 'package:bored/model/GameModel.dart';
import 'package:bored/model/Regex.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool keepPhoto;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      keepPhoto = false;
    });
  }

  Future updateGame(BuildContext context) async {
    if (_image == null && documentSnapshot.data['picture'] != null)
      Scaffold.of(context).showSnackBar(SnackBar(
        content: Text('Keep current picture?'),
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () => {
            setState(() {
              keepPhoto = true;
            })
          },
        ),
      ));
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
      documentSnapshot.reference.updateData(
          {'picture': _downloadUrl, 'name': _name, 'xp': int.parse(_xp), 'min_players': int.parse(_minPlayers), 'max_players': int.parse(_maxPlayers)});
      Navigator.of(context).pop();
    }
    if (keepPhoto == true) {
      documentSnapshot.reference.updateData({
        'picture': documentSnapshot.data['picture'],
        'name': _name,
        'xp': int.parse(_xp),
        'min_players': int.parse(_minPlayers),
        'max_players': int.parse(_maxPlayers)
      });
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (game == null) game = GameModel.fromMap(documentSnapshot.data);
    return Scaffold(
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
                        begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color.fromRGBO(255, 90, 0, 1), Color.fromRGBO(236, 32, 77, 1)]),
                  ),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 100,
                        child: Row(
                          children: <Widget>[
                            IconButton(
                              icon: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            Text(
                              'Update game',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                      Material(
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                'Game Details',
                                style: TextStyle(color: Colors.black, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                        elevation: 10,
                        shadowColor: Color.fromRGBO(255, 90, 0, 1),
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
                            SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                initialValue: documentSnapshot.data['name'],
                                validator: (input) {
                                  if (input.isEmpty) {
                                    return 'Name required!';
                                  }
                                  return null;
                                },
                                onSaved: (input) => _name = input,
                                decoration: InputDecoration(
                                    enabledBorder: new OutlineInputBorder(
                                        borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(20)),
                                    focusedBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(20)),
                                    errorBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                    focusedErrorBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                    prefixIcon: Icon(Icons.gamepad),
                                    hintText: 'Football',
                                    labelText: 'Name',
                                    helperText: 'Choose a game name.'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                initialValue: documentSnapshot.data['min_players'].toString(),
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
                                        borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(20)),
                                    focusedBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(20)),
                                    errorBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                    focusedErrorBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                    prefixIcon: Icon(FontAwesomeIcons.minus),
                                    hintText: '2',
                                    labelText: 'Minimum',
                                    helperText: 'Minimum number of players.'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                initialValue: documentSnapshot.data['max_players'].toString(),
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
                                        borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(20)),
                                    focusedBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(20)),
                                    errorBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                    focusedErrorBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                    prefixIcon: Icon(Icons.add),
                                    hintText: '99',
                                    labelText: 'Maximum',
                                    helperText: 'Maximum number of players.'),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                initialValue: documentSnapshot.data['xp'].toString(),
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
                                        borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(20)),
                                    focusedBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(20)),
                                    errorBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                    focusedErrorBorder:
                                        new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                    prefixIcon: Icon(Icons.star),
                                    hintText: '200',
                                    labelText: 'Xp',
                                    helperText: 'Experience won per game.'),
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
                                              : (documentSnapshot.data['picture'] != null)
                                                  ? Image.network(documentSnapshot.data['picture'])
                                                  : Center(
                                                      child: Text('Choose photo'),
                                                    ) /*Image.asset(
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
              updateGame(context);
            else
              Scaffold.of(context).showSnackBar(SnackBar(content: Text("Cannot update game!")));
          },
          child: Icon(Icons.check),
          backgroundColor: Color.fromRGBO(255, 90, 0, 1),
          heroTag: 'updateGameFloatingActionButton',
        ),
      ),
    );
  }
}
