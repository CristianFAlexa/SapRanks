import 'package:bored/model/UserModel.dart';
import 'package:bored/view/message/MessageNotification.dart';
import 'package:bored/view/setup/MainPage.dart';
import 'package:bored/view/widget/Cutout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final db = Firestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  void _signWithGoogle(BuildContext context) async {
    _fcm.subscribeToTopic('games');
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text('Sign in')));
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    final FirebaseUser user = (await firebaseAuth.signInWithCredential(credential)).user;

    final userDocument = db.collection('users').document(user.uid);
    userDocument.get().then((snapshot) async => {
      // ignore: sdk_version_ui_as_code
      if (!snapshot.exists)
        {
          await userDocument
            .setData(new UserModel(user.uid, user.email, 'newbie', 'user_role', null, user.email.substring(0, 3), 1, 1, 0, new List<String>()).toJson())
        }
    });
    _saveDeviceToken(user.uid);
    Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage(user: user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Stack(
          children: <Widget>[
            MessageNotification(),
            Container(
              decoration: BoxDecoration(
                gradient:
                LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [Color.fromRGBO(255, 90, 0, 1), Color.fromRGBO(236, 32, 77, 1)]),
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
                        borderRadius: BorderRadius.circular(10)
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
                                Text('Login information', style: TextStyle(fontWeight: FontWeight.bold),),
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
                                new OutlineInputBorder(borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(20)),
                                focusedBorder:
                                new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(20)),
                                errorBorder: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                focusedErrorBorder:
                                new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
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
                                if (input.length < 8) {
                                  return 'Password required!';
                                }
                                return null;
                              },
                              onSaved: (input) => _password = input,
                              decoration: InputDecoration(
                                enabledBorder:
                                new OutlineInputBorder(borderSide: new BorderSide(color: Colors.blueGrey[900]), borderRadius: BorderRadius.circular(20)),
                                focusedBorder:
                                new OutlineInputBorder(borderSide: new BorderSide(color: Colors.green[600]), borderRadius: BorderRadius.circular(20)),
                                errorBorder: new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                focusedErrorBorder:
                                new OutlineInputBorder(borderSide: new BorderSide(color: Colors.red[600]), borderRadius: BorderRadius.circular(20)),
                                prefixIcon: Icon(FontAwesomeIcons.key),
                                labelText: 'Password',
                              ),
                              obscureText: true,
                            ),
                          ),
                          InkWell(
                            onTap: signIn,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16, right: 16, top: 50, bottom: 5),
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  boxShadow: [ BoxShadow( color: Colors.grey, offset: Offset(0,5), blurRadius: 5) ],
                                  borderRadius: BorderRadius.circular(3),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [Color.fromRGBO(255, 90, 0, 1), Color.fromRGBO(236, 32, 77, 1)]),
                                ),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        FontAwesomeIcons.signInAlt,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Login',
                                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              top: 10,
                              left: 40
                            ),
                            child: Row(
                              children: <Widget>[
                                Text('New user?', style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16, top: 5, bottom: 50),
                            child: OutlineButton(
                              child: Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: <Widget>[
                                      Icon(
                                        Icons.person_add,
                                        color: Colors.grey[500],
                                        size: 20,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        'Sign Up',
                                        style: TextStyle(color: Colors.grey[500], fontSize: 24),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              onPressed: toRegister, //callback when button is clicked
                              borderSide: BorderSide(
                                color: Colors.grey[500], //Color of the border
                                style: BorderStyle.solid, //Style of the border
                                width: 1, //width of the border
                              ),
                            ),
                          ),
                          SizedBox(height: 25,)
                        ],
                      ),
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 2.5,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 30
                        ),
                        child: Column(
                          children: <Widget>[
                            Text('or sign in with', style: TextStyle(color: Colors.white),),
                            SignInButton(Buttons.Google, onPressed: () =>  _signWithGoogle(context)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void toRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegisterPage(
          title: 'Register',
        ),
        fullscreenDialog: true));
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
