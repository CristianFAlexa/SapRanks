import 'dart:io';

import 'package:bored/service/DatabaseService.dart';
import 'package:bored/view/widget/Cutout.dart';
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
      final _formState = _formKey.currentState;
      String fileName;
      if (_image != null) {
        fileName = basename(_image.path);
        StorageReference storageReference = FirebaseStorage.instance.ref().child(fileName);
        StorageUploadTask uploadTask = storageReference.putFile(_image);
        StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
        String downloadUrl = await taskSnapshot.ref.getDownloadURL();
        setState(() {
          _downloadUrl = downloadUrl;
          print("Profile picture uploaded.");
        });
        collectionReference.document(user.uid).updateData({'profile_picture': _downloadUrl});
      } else {
        Scaffold.of(context).showSnackBar(new SnackBar(content: new Text('You did not choose a profile picture.')));
        Navigator.of(context).pop();
      }
      _formState.save();

      if (_name != null) {
        collectionReference.document(user.uid).updateData({'name': _name});
        _editNameState = !_editNameState;
      } else
        Scaffold.of(context).showSnackBar(new SnackBar(content: new Text('You did not choose a new name.')));
    }

    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [Color.fromRGBO(255, 90, 0, 1), Color.fromRGBO(236, 32, 77, 1)]),
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
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.settings,
                            color: Colors.white,
                            size: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Text(
                              'Settings',
                              style: TextStyle( fontSize: 15, color: Colors.white),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(border: Border(left: BorderSide(color: Colors.white), right: BorderSide(color: Colors.white))),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10, right: 10),
                              child: Container(
                                height: 60,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                                      child: Center(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(3),
                                          child: Cutout(
                                            color: Colors.white,
                                            child: Image.asset('assets/images/rsz_spacemandraw.png'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                          Padding(
                            padding: const EdgeInsets.only(left: 10, right: 10),
                            child: Text(
                              'User',
                              style: TextStyle(fontSize: 15, color: Colors.white),
                              maxLines: 4,
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 15, left: 20),
                    child: Text(
                      'User, Settings',
                      style: TextStyle(fontSize: 20, color: Colors.grey[700]),
                    ),
                  )
                ],
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.height / 1.2,
              color: Colors.white,
              child: ListView(
                physics: ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: StreamBuilder(
                        stream: collectionReference.document(user.uid).snapshots(),
                        builder: (context, snapshot) {
                          return (snapshot.data == null)
                              ? CircularProgressIndicator()
                              : Builder(
                                  builder: (context) => Column(
                                    children: <Widget>[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: <Widget>[
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
                                                         : (snapshot.data['profile_picture'] != null)
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
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: TextFormField(
                                          initialValue: snapshot.data['name'],
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
                                            prefixIcon: Icon(Icons.description),
                                            hintText: 'John',
                                            labelText: 'User Name',
                                            helperText: 'Change your username.'),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                        }),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) => Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8, right: 8,left: 32),
                child: FloatingActionButton(
                  heroTag: "cancelEditProfile",
                  onPressed: () => Navigator.of(context).pop(),
                  child: Icon(Icons.cancel),
                  backgroundColor: Colors.red,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: FloatingActionButton(
                  heroTag: "submitEditProfile",
                  onPressed: () => {
                    if (_formKey.currentState.validate())
                      updateProfile(context)
                    else
                      Scaffold.of(context).showSnackBar(new SnackBar(content: new Text('You did not choose a new name.')))
                  },
                  child: Icon(Icons.check),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
