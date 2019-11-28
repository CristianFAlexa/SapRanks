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
              child: Text('Scan result: $qrText'),
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
              players = new List<String>.from(snap.data['players']);
              players.add(user.uid);
            });
            queueCollectionReference
                .document(qrList[0])
                .collection('active')
                .document(qrList[1])
                .updateData({'players': FieldValue.arrayUnion(players)});
          });
        }
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
