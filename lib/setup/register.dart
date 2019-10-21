import 'package:bored/model/UserModel.dart';
import 'package:bored/setup/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

final db = Firestore.instance;

class Register extends StatefulWidget {
  Register({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          "assets/images/register2.jpg",
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          fit: BoxFit.cover,
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: GradientAppBar(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black87, Colors.black38, Colors.black12]),
            title: Text(widget.title),
          ),
          body: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black12,
                      Colors.black12,
                      Colors.black12,
                      Colors.black26,
                      Colors.black38,
                    ]
                )
            ),
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
                            padding:
                            EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(5)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(color: Colors.black, blurRadius: 2)
                                ]),
                            child: TextFormField(
                              // ignore: missing_return
                              validator: (input) {
                                if (input.isEmpty) {
                                  return 'Email required!';
                                }
                              },
                              onSaved: (input) => _email = input,
                              decoration: InputDecoration(
                                  icon: Icon(Icons.mail), hintText: 'Email'),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.only(top: 32),
                            child: Column(
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width / 1.2,
                                  height: 50,
                                  padding:
                                  EdgeInsets.only(top: 4, left: 16, right: 16, bottom: 4),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(5)),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black, blurRadius: 2)
                                      ]),
                                  child:  TextFormField(
                                    // ignore: missing_return
                                    validator: (input) {
                                      if (input.length < 8) {
                                        return 'Password required!';
                                      }
                                    },
                                    onSaved: (input) => _password = input,
                                    decoration: InputDecoration(
                                        icon: Icon(FontAwesomeIcons.key), hintText: 'Password'),
                                    obscureText: true,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20,),
                    RaisedButton(
                      onPressed: signUp,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      color: Colors.red,
                      child: new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            Icons.add_box,
                            color: Colors.white,
                          ),
                          new Container(
                              padding: EdgeInsets.only(left: 10.0, right: 10.0),
                              child: new Text(
                                "Register",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
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

  Future<void> signUp() async {
    final _formState = _formKey.currentState;
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
                0,
                0,
                0)
            .toJson());

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LoginPage(
                      title: 'Login',
                    )));
      } catch (e) {
        print(e);
      }
    }
  }
}
