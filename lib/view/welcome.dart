import 'package:bored/setup/login.dart';
import 'package:bored/setup/register.dart';
import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Welcome to Sap Ranks!'),
        backgroundColor: Color.fromRGBO(255, 140, 0, 1),
      ),
      body: new Stack(
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
                  onPressed: toLogin,
                  child: Text(
                    "Sign in",
                    style: new TextStyle(
                      fontSize: 30.0,
                    ),
                  ),
                  color: Color.fromRGBO(255, 140, 0, 0.5),
                ),
                RaisedButton(
                  onPressed: toRegister,
                  child: Text("Sign up",
                  style: new TextStyle(
                    fontSize: 30.0,
                  ),),
                  color: Color.fromRGBO(255, 140, 0, 0.5),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void toLogin() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LoginPage(
                  title: 'Login',
                ),
            fullscreenDialog: true));
  }

  void toRegister() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Register(
                  title: 'Register',
                ),
            fullscreenDialog: true));
  }
}
