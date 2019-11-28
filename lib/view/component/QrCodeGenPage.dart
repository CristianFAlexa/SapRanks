import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeGenPage extends StatelessWidget {
  QrCodeGenPage(this.documentId, this.gameName);
  final String documentId;
  final String gameName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR"),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
/*            Text(
              "Encoded with : \n $gameName $documentId",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
              ),
            ),*/
            QrImage(
              data: gameName+" "+documentId,
              gapless: true,
              size: 400,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            )
          ],
        ),
      ),
    );
  }
}
