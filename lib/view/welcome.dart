import 'package:bored/model/UserModel.dart';
import 'package:bored/setup/login.dart';
import 'package:bored/setup/register.dart';
import 'package:bored/view/component/MainPage.dart';
import 'package:bored/view/component/message/MessageNotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_view.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
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
    final FirebaseUser user =
        (await firebaseAuth.signInWithCredential(credential)).user;

    final userDocument = db.collection('users').document(user.uid);
    userDocument.get().then((snapshot) async => {
          // ignore: sdk_version_ui_as_code
          if (!snapshot.exists)
            {
              await userDocument.setData(new UserModel(
                      user.uid,
                      user.email,
                      'newbie',
                      'user_role',
                      null,
                      user.email.substring(0, 3),
                      0,
                      0,
                      0,
                      new List<String>())
                  .toJson())
            }
        });
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MainPage(user: user)));
  }

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
          body: Builder(
          builder: (context) => Stack(
            children: <Widget>[
              new MessageNotification(),
              new Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black87,
                        Colors.black54,
                        Colors.black45,
                        Colors.black26,
                        Colors.black12,
                        Colors.black26,
                        Colors.black45,
                        Colors.black54,
                        Colors.black87,
                      ]),
                ),
              ),
              new Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SignInButton(Buttons.Google,
                        onPressed: () => _signWithGoogle(context)),
                    SignInButtonBuilder(
                      text: 'Sign in with Email',
                      icon: Icons.email,
                      onPressed: toLogin,
                      backgroundColor: Color.fromRGBO(255, 90, 0, 1),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SignInButtonBuilder(
                      text: 'Register now',
                      icon: Icons.person_add,
                      onPressed: toRegister,
                      backgroundColor: Color.fromRGBO(255, 90, 0, 1),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
      ]
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
