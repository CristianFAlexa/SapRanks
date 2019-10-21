import 'dart:io';

import 'package:bored/service/DatabaseService.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';

class EditProfilePage extends StatefulWidget {
  EditProfilePage({this.user});

  final FirebaseUser user;

  @override
  _EditProfilePageState createState() => _EditProfilePageState(user: user);
}

class _EditProfilePageState extends State<EditProfilePage> {
  _EditProfilePageState({this.user});

  final FirebaseUser user;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _editNameState = true;
  File _image;
  String _downloadUrl;
  String _name;

  @override
  Widget build(BuildContext context) {
    Future setNameState(bool state) async {
      setState(() {
        _editNameState = !_editNameState;
      });
    }

    Future getImage() async {
      var image = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
      });
    }

    Future updateProfile(BuildContext context) async {
      // logic for updating profile picture
      final _formState = _formKey.currentState;
      String fileName;
      if (_image != null) {
        fileName = basename(_image.path);
        StorageReference storageReference =
            FirebaseStorage.instance.ref().child(fileName);
        StorageUploadTask uploadTask = storageReference.putFile(_image);
        StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        setState(() {
          _downloadUrl = downloadUrl;
          print("Profile picture uploaded.");
        });
        collectionReference
            .document(user.uid)
            .updateData({'profile_picture': _downloadUrl});
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(
            content: new Text('You did not choose a profile picture.')));
      }

      _formState.save();
      if (_name != null) {
        collectionReference.document(user.uid).updateData({'name': _name});
        _editNameState = !_editNameState;
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text('You did not choose a new name.')));
      }
    }

    return Scaffold(
        appBar: GradientAppBar(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Color.fromRGBO(255, 90, 0, 1),
                Color.fromRGBO(236, 32, 77, 1)
              ]),
        ),
        body: Form(
          key: _formKey,
          child: StreamBuilder(
              stream: collectionReference.document(user.uid).snapshots(),
              builder: (context, snapshot) {
                return Builder(
                  builder: (context) => Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 15.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(
                              width: 25,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: CircleAvatar(
                                radius: 80,
                                backgroundColor: Color.fromRGBO(255, 90, 0, 1),
                                child: ClipOval(
                                  child: SizedBox(
                                    width: 150.0,
                                    height: 150.0,
                                    child: (_image != null)
                                        ? Image.file(
                                            _image,
                                            fit: BoxFit.fill,
                                          )
                                        : (snapshot.data['profile_picture'] !=
                                                null)
                                            ? Image.network(
                                                "${snapshot.data['profile_picture']}",
                                                fit: BoxFit.cover,
                                              )
                                            : Image.asset(
                                                "assets/images/default-profile-picture.png",
                                                fit: BoxFit.cover,
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
                        SizedBox(
                          height: 20.0,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                child: Column(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        "Username",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: (_editNameState)
                                          ? Text(
                                              "${snapshot.data['name']}",
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 18.0,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Container(
                                              padding: EdgeInsets.only(
                                                  top: 10, left: 45),
                                              child: Column(
                                                children: <Widget>[
                                                  Container(
                                                    width: 250,
                                                    height: 40,
                                                    padding: EdgeInsets.only(
                                                        top: 4,
                                                        left: 16,
                                                        right: 16,
                                                        bottom: 4),
                                                    decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                                Radius.circular(
                                                                    5)),
                                                        color: Colors.white,
                                                        boxShadow: [
                                                          BoxShadow(
                                                              color:
                                                                  Colors.black,
                                                              blurRadius: 2)
                                                        ]),
                                                    child: TextFormField(
                                                      // ignore: missing_return
                                                      onSaved: (input) =>
                                                          _name = input,
                                                      decoration: InputDecoration(
                                                          icon:
                                                              Icon(Icons.input),
                                                          hintText:
                                                              '${snapshot.data['name']}'),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                  child: IconButton(
                                onPressed: () => setNameState(_editNameState),
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.orange,
                                ),
                              )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              RaisedButton(
                                color: Colors.red,
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                elevation: 4.0,
                                splashColor: Colors.orange,
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                ),
                              ),
                              SizedBox(
                                width: 20,
                              ),
                              RaisedButton(
                                color: Colors.green,
                                onPressed: () {
                                  updateProfile(context);
                                },
                                elevation: 4.0,
                                splashColor: Colors.orange,
                                child: Text(
                                  "Submit",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16.0),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                );
              }),
        ));
  }
}
