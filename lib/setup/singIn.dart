import 'package:bored/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  String _email, _password;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
              TextFormField(
                // ignore: missing_return
                validator:  (input) {
                  if(input.isEmpty){
                    return 'Email required!';
                  }
                },
                onSaved: (input) => _email = input,
                decoration: InputDecoration(
                  labelText: 'Email'
                ),
              ),
            TextFormField(
              // ignore: missing_return
              validator:  (input) {
                if(input.length < 8){
                  return 'Password required!';
                }
              },
              onSaved: (input) => _password = input,
              decoration: InputDecoration(
                  labelText: 'Password'
              ),
              obscureText: true,
            ),
            RaisedButton(
              onPressed: signIn,
              child: Text('Sign in'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> signIn() async {
    final _formState  = _formKey.currentState;
    if(_formState.validate()){
      _formState.save();
      try{
        FirebaseUser user = (await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _email,
            password: _password
        )).user;
        Navigator.push(context, MaterialPageRoute(builder: (context) => Home()));
      }catch(e) {
          print(e);
      }

    }
  }
}
