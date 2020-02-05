import 'package:bored/model/Constants.dart';
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
  var qrFlag = false;
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
          Center(
            child: Column(
              children: <Widget>[
                (qrFlag == false)? CircularProgressIndicator() :
                Icon(Icons.check, color: Colors.green,),
                RaisedButton(
                  onPressed: () {
                    if (qrText != null) {
                      final List<String> qrList = qrText.split(" ");
                      List<String> players;
                      queueCollectionReference.document(qrList[0]).collection('active').document(qrList[1]).get().then((snap) {
                        setState(() {
                          players = new List<String>.from(snap.data['players']);
                          players.add(user.uid);
                        });
                        queueCollectionReference
                          .document(qrList[0])
                          .collection('active')
                          .document(qrList[1])
                          .updateData({'players': FieldValue.arrayUnion(players)});
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  color: Constants.primaryColor,
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Container(
                        padding: EdgeInsets.only(left: 10.0, right: 10.0),
                        child: new Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        )),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () => {
                    Navigator.of(context).pop(),
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8, right: 16, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Icon(Icons.arrow_back),
                        Text('Back to main screen')
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        qrText = scanData;
        qrFlag = true;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
