import 'package:bored/model/UserModel.dart';
import 'package:bored/setup/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

final db = Firestore.instance;

class Register extends StatefulWidget {
  Register({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _RegisterState createState() => _RegisterState();
}

// todo: check pass does not work as expected.

class _RegisterState extends State<Register> {
  String _email, _password;
  String _checkPassword;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          //title: Text(widget.title),
          ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            TextFormField(
              // ignore: missing_return
              validator: (input) {
                if (input.isEmpty) {
                  return 'Email required!';
                }
              },
              onSaved: (input) => _email = input,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              // ignore: missing_return
              validator: (input) {
                _checkPassword = input;
                if (input.length < 8) {
                  return 'Password must have at least 8 characters!';
                }
              },
              onSaved: (input) => _password = input,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            /*TextFormField(
              // ignore: missing_return
              validator: (input) {
                if (input == _checkPassword) {
                  return 'Passwords must match!';
                }
              },
              onSaved: (input) => _password = input,
              decoration: InputDecoration(labelText: 'Reenter password'),
              obscureText: true,
            ),*/
            RaisedButton(
              onPressed: signUp,
              child: Text('Register now'),
            )
          ],
        ),
      ),
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

        await db.collection('users')
        .document(user.uid)
        .setData( new UserModel(user.uid, user.email, 'newbie', 'user_role').toJson());

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
