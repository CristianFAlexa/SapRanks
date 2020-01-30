import 'package:bored/view/setup/MainPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          "assets/images/spaceman.jpg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: GradientAppBar(
            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.black87, Colors.black38, Colors.black12]),
            title: Text(widget.title),
          ),
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [
              Colors.black87,
              Colors.black54,
              Colors.black45,
              Colors.black26,
              Colors.black12,
              Colors.black26,
              Colors.black45,
              Colors.black54,
              Colors.black87,
            ])),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                              // ignore: missing_return
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'Email required!';
                                }
                              },
                              onSaved: (input) => _email = input,
                              decoration: InputDecoration(icon: Icon(Icons.mail), hintText: 'Email'),
                            ),
                          ),
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
                                    // ignore: missing_return
                                    validator: (input) {
                                      if (input.length < 8) {
                                        return 'Password required!';
                                      }
                                    },
                                    onSaved: (input) => _password = input,
                                    decoration: InputDecoration(icon: Icon(FontAwesomeIcons.key), hintText: 'Password'),
                                    obscureText: true,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    RaisedButton(
                      onPressed: signIn,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      color: Color.fromRGBO(255, 90, 0, 1),
                      child: new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            FontAwesomeIcons.signInAlt,
                            color: Colors.white,
                          ),
                          new Container(
                              padding: EdgeInsets.only(left: 10.0, right: 10.0),
                              child: new Text(
                                "Sign in",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Get the token, save it to the database for current user
  _saveDeviceToken(String uid) async {
    // Get the token for this device
    String fcmToken = await _fcm.getToken();

    // Save it to Firestore
    if (fcmToken != null) {
      var tokens = db.collection('users').document(uid).collection('tokens').document(fcmToken);

      await tokens.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
      });
    }
  }

  Future<void> signIn() async {
    final _formState = _formKey.currentState;
    if (_formState.validate()) {
      _formState.save();
      try {
        FirebaseUser user = (await FirebaseAuth.instance.signInWithEmailAndPassword(email: _email, password: _password)).user;
        _saveDeviceToken(user.uid);
        Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage(user: user)));
      } catch (e) {
        print(e);
      }
    }
  }
}
