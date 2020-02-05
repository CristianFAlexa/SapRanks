import 'package:bored/model/Constants.dart';
import 'package:bored/model/Regex.dart';
import 'package:bored/model/UserModel.dart';
import 'package:bored/view/widget/Cutout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'LoginPage.dart';

final db = Firestore.instance;

class RegisterPage extends StatefulWidget {
  RegisterPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String _checkPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient:
            LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: Constants.appColors),
          ),
          child: Form(
            key: _formKey,
            child: ListView(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children: <Widget>[
                Container(
                  height: 120,
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
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3)
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 10,
                          left: 40
                        ),
                        child: Row(
                          children: <Widget>[
                            Text('Sign up details', style: TextStyle(fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                      Padding(padding: const EdgeInsets.only(left: 16, right: 16, top: 20, bottom: 5),
                        child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Email required!';
                            }
                            return null;
                          },
                          onSaved: (input) => _password = input,
                          decoration: InputDecoration(
                            enabledBorder:
                            new OutlineInputBorder(borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(3)),
                            focusedBorder:
                            new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(3)),
                            errorBorder: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(3)),
                            focusedErrorBorder:
                            new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(3)),
                            prefixIcon: Icon(Icons.mail),
                            hintText: 'user@domain.com',
                            labelText: 'Email',
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                        child: TextFormField(
                          validator: (input) {
                            _checkPassword = input;
                            if (input.isEmpty) {
                              return 'Password required!';
                            } else if(!Regex.password.hasMatch(input)){
                              return 'Invalid password!';
                            }
                            return null;
                          },
                          onSaved: (input) => _password = input,
                          decoration: InputDecoration(
                            enabledBorder:
                            new OutlineInputBorder(borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(3)),
                            focusedBorder:
                            new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(3)),
                            errorBorder: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(3)),
                            focusedErrorBorder:
                            new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(3)),
                            prefixIcon: Icon(FontAwesomeIcons.key),
                            labelText: 'Password',
                          ),
                          obscureText: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 5),
                        child: TextFormField(
                          validator: (input) {
                            if (input.isEmpty) {
                              return 'Check password required!';
                            } else if(_checkPassword.compareTo(input) != 0){
                              return 'Passwords do not match!';
                            }
                            return null;
                          },
                          onSaved: (input) => _password = input,
                          decoration: InputDecoration(
                            enabledBorder:
                            new OutlineInputBorder(borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(3)),
                            focusedBorder:
                            new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(3)),
                            errorBorder: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(3)),
                            focusedErrorBorder:
                            new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(3)),
                            prefixIcon: Icon(FontAwesomeIcons.key),
                            labelText: 'Check Password',
                          ),
                          obscureText: true,
                        ),
                      ),
                      InkWell(
                        onTap: () =>{
                          if (_formKey.currentState.validate())
                            signUp
                          else
                            Scaffold.of(context).showSnackBar(SnackBar(content: Text("Try again!")))
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 16, right: 16, top: 30, bottom: 5),
                          child: Container(
                            height: 50,
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              boxShadow: [ BoxShadow( color: Colors.grey, offset: Offset(0,5), blurRadius: 5) ],
                              borderRadius: BorderRadius.circular(3),
                              gradient: LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: Constants.appColors),
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.person_add,
                                    color: Colors.white,
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Register',
                                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage())),
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8, right: 16, top: 35),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              Icon(Icons.arrow_back),
                              Text('Back to Login')
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> signUp() async {
    final _formState = _formKey.currentState;
    final FirebaseMessaging _fcm = FirebaseMessaging();
    if (_formState.validate()) {
      _formState.save();
      try {
        FirebaseUser user = (await FirebaseAuth.instance
                .createUserWithEmailAndPassword(
                    email: _email, password: _password))
            .user;
        user.sendEmailVerification();

        await db.collection('users').document(user.uid).setData(new UserModel(
                user.uid,
                user.email,
                'newbie',
                'user_role',
                null,
                user.email.substring(0, 3),
                1,
                0,
                0,
                new List<String>())
            .toJson());
        _fcm.subscribeToTopic('games');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LoginPage()));
      } catch (e) {
        print(e);
      }
    }
  }
}
