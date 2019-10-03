import 'package:bored/model/UserModel.dart';
import 'package:bored/setup/login.dart';
import 'package:bored/setup/register.dart';
import 'package:bored/view/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
final GoogleSignIn googleSignIn = GoogleSignIn();

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  final db = Firestore.instance;

  void _signWithGoogle(BuildContext context) async {
    Scaffold.of(context)
        .showSnackBar(new SnackBar(content: new Text('Sign in')));
    final GoogleSignInAccount googleUser = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: googleAuth.idToken, accessToken: googleAuth.accessToken);
    // todo: why doesn't it persist in fb
    final FirebaseUser user =
        (await firebaseAuth.signInWithCredential(credential)).user;
    await db.collection('users')
        .document(user.uid)
        .setData( new UserModel(user.uid, user.email, 'newbie', 'user_role').toJson());
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => Home(user: user)));
    //return user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Stack(
          children: <Widget>[
            new Container(
              decoration: new BoxDecoration(
                image: new DecorationImage(
                  image: new AssetImage("assets/images/pingpong.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            new Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: toLogin,
                    color: const Color(0xFFFFFFFF),
                    child: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.mailBulk,
                          color: Colors.deepOrange,
                        ),
                        new Container(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: new Text(
                              "Sign in",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: toRegister,
                    color: const Color(0xFFFFFFFF),
                    child: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.user,
                          color: Colors.deepOrange,
                        ),
                        new Container(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: new Text(
                              "Sign up",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                  RaisedButton(
                    onPressed: () => _signWithGoogle(context),
                        //.then((FirebaseUser user) => print(user))
                       // .catchError((e) => print(e)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: const Color(0xFFFFFFFF),
                    child: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.google,
                          color: Colors.deepOrange,
                        ),
                        new Container(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: new Text(
                              "Sign in with Google",
                              style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void toLogin() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginPage(
                  title: 'Login',
                ),
            fullscreenDialog: true));
  }

  void toRegister() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Register(
                  title: 'Register',
                ),
            fullscreenDialog: true));
  }
}
