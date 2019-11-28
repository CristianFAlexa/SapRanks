import 'package:bored/view/component/QrCodeScanPage.dart';
import 'package:bored/view/widget/MenuListTile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gradient_app_bar/gradient_app_bar.dart';

class SettingsPage extends StatefulWidget {
  SettingsPage(this.user);
  final FirebaseUser user;

  @override
  _SettingsPageState createState() => _SettingsPageState(user);
}

class _SettingsPageState extends State<SettingsPage> {
  _SettingsPageState(this.user);
  final FirebaseUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  GradientAppBar(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black87, Colors.black38, Colors.black12]
          ),
        title: Text('Settings',
        style: TextStyle(color: Colors.white),),
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.blueGrey[800],
                Colors.blueGrey[700],
                Colors.blueGrey[700],
                Colors.blueGrey[800],
              ]),
        ),
        child: ListView(
          children: <Widget>[
            MenuListTile(
              FontAwesomeIcons.qrcode,
              "Scan QR Code",
                    () => {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => QrCodeScanPage(user),
                          fullscreenDialog: true))
                }
            ),
          ],
        ),
      ),
    );
  }

}
