import 'package:bored/service/DatabaseService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrCodeScanPage extends StatefulWidget {
  QrCodeScanPage(this.user);

  final FirebaseUser user;

  @override
  _QrCodeScanPageState createState() => _QrCodeScanPageState(user);
}

class _QrCodeScanPageState extends State<QrCodeScanPage> {
  _QrCodeScanPageState(this.user);

  final FirebaseUser user;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  var qrText = "";
  var qrFlag = "NOT DONE";
  QRViewController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          Expanded(
            flex: 1,
            child: Center(
              child: Column(
                children: <Widget>[
                  Text('Scan result: $qrFlag'),
                  RaisedButton(
                    onPressed: () {
                      if (qrText != null) {
                        final List<String> qrList = qrText.split(" ");
                        List<String> players;
                        queueCollectionReference
                            .document(qrList[0])
                            .collection('active')
                            .document(qrList[1])
                            .get()
                            .then((snap) {
                          setState(() {
                            players =
                            new List<String>.from(snap.data['players']);
                            players.add(user.uid);
                          });
                          queueCollectionReference
                              .document(qrList[0])
                              .collection('active')
                              .document(qrList[1])
                              .updateData(
                              {'players': FieldValue.arrayUnion(players)});
                        });
                      }
                      Navigator.of(context).pop();
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: Colors.blueGrey,
                    child: new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.directions_run,
                          color: Colors.white,
                        ),
                        new Container(
                            padding: EdgeInsets.only(left: 10.0, right: 10.0),
                            child: new Text(
                              "ok",
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
        qrFlag = "SUCCESFUL";
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
